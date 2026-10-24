"use client";

import { FormEvent, useEffect, useState } from "react";
import { DateInput } from "@/components/date-input";
import { Section } from "@/components/fields";
import { ApiError, api } from "@/lib/api";
import type { Batch, Bill, Enrollment, Fixture, Leave, TrainingSession } from "@/lib/types";

type Kind = "player" | "coach";

type SessionDraft = {
  session_id: number;
  batch_id: string;
  date: string;
  start: string;
  end: string;
  ground: string;
  note: string;
  attendance: string;
};

type FixtureDraft = {
  match_id: number;
  batch_id: string;
  title: string;
  opponent: string;
  date: string;
  start: string;
  end: string;
  status: string;
  venue: string;
  result: string;
};

type FeeDraft = {
  bill_id: number | null;
  amount: string;
  due_date: string;
  status: string;
};

const fieldClass =
  "w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm text-ink-text outline-none focus:border-terracotta";
const buttonClass = "rounded-xl bg-terracotta px-4 py-2 text-sm font-bold text-white disabled:opacity-60";

function clock(value: string) {
  return value ? value.slice(0, 5) : "";
}

function day(value: string) {
  return value ? value.slice(0, 10) : "";
}

type Panel = "batch" | "sessions" | "fixtures" | "fee" | "leave";

export function PageContent({
  kind,
  personId,
  onChanged,
  panels,
  titles,
  hints,
}: {
  kind: Kind;
  personId: number;
  onChanged: () => void;
  panels?: Panel[];
  titles?: Partial<Record<Panel, string>>;
  hints?: Partial<Record<Panel, string>>;
}) {
  const [batches, setBatches] = useState<Batch[]>([]);
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [sessions, setSessions] = useState<SessionDraft[]>([]);
  const [openSessions, setOpenSessions] = useState<TrainingSession[]>([]);
  const [fixtures, setFixtures] = useState<FixtureDraft[]>([]);
  const [leaves, setLeaves] = useState<Leave[]>([]);
  const [fee, setFee] = useState<FeeDraft>({ bill_id: null, amount: "", due_date: "", status: "due" });
  const [batchChoice, setBatchChoice] = useState("");
  const [sessionChoice, setSessionChoice] = useState("");
  const [newSession, setNewSession] = useState({ batch_id: "", date: "", start: "", end: "", ground: "", note: "" });
  const [newFixture, setNewFixture] = useState({
    batch_id: "",
    title: "",
    opponent: "",
    venue: "",
    result: "",
    date: "",
    start: "",
    end: "",
    status: "upcoming",
  });
  const [loading, setLoading] = useState(true);
  const [version, setVersion] = useState(0);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let ignore = false;

    async function load() {
      setLoading(true);
      setError("");
      try {
        const [nextBatches, nextSessions, nextFixtures, nextBills, nextEnrollments, nextLeaves] = await Promise.all([
          api<Batch[]>("/batches"),
          api<TrainingSession[]>("/sessions"),
          api<Fixture[]>("/matches"),
          api<Bill[]>(kind === "player" ? `/bills?student_id=${personId}` : `/bills?coach_id=${personId}`),
          kind === "player" ? api<Enrollment[]>(`/batches/enrollments?student_id=${personId}`) : Promise.resolve([]),
          kind === "coach" ? api<Leave[]>("/leaves") : Promise.resolve([]),
        ]);
        if (ignore) return;
        const batchIds = new Set(nextEnrollments.map((row) => row.batch_id));
        const visibleSessions =
          kind === "player"
            ? nextSessions.filter((session) => batchIds.has(session.batch_id))
            : nextSessions.filter((session) => session.coaches.some((coach) => coach.coach_id === personId));
        const marks = await Promise.all(
          visibleSessions.map((session) =>
            kind === "player"
              ? api<{ student_id: number; status: string }[]>(`/sessions/${session.session_id}/student-attendance`)
              : api<{ coach_id: number; status: string }[]>(`/sessions/${session.session_id}/coach-attendance`),
          ),
        );
        if (ignore) return;
        setBatches(nextBatches);
        setEnrollments(nextEnrollments);
        setOpenSessions(kind === "coach" ? nextSessions : []);
        setSessions(
          visibleSessions.map((session, index) => {
            const rows = marks[index] ?? [];
            const mark =
              kind === "player"
                ? (rows as { student_id: number; status: string }[]).find((row) => row.student_id === personId)
                : (rows as { coach_id: number; status: string }[]).find((row) => row.coach_id === personId);
            return {
              session_id: session.session_id,
              batch_id: String(session.batch_id),
              date: day(session.date),
              start: clock(session.start),
              end: clock(session.end),
              ground: session.ground ?? "",
              note: session.note ?? "",
              attendance: mark?.status ?? "",
            };
          }),
        );
        setFixtures(
          nextFixtures.map((fixture) => ({
            match_id: fixture.match_id,
            batch_id: String(fixture.batch_id),
            title: fixture.title,
            opponent: fixture.opponent ?? "",
            date: day(fixture.date),
            start: clock(fixture.start),
            end: clock(fixture.end),
            status: fixture.status,
            venue: fixture.venue ?? "",
            result: fixture.result ?? "",
          })),
        );
        setLeaves(nextLeaves.filter((leave) => leave.coach_id === personId));
        const latest = nextBills[0];
        setFee(
          latest
            ? {
                bill_id: latest.bill_id,
                amount: String(latest.amount),
                due_date: day(latest.due_date),
                status: latest.status,
              }
            : { bill_id: null, amount: "", due_date: "", status: "due" },
        );
        setBatchChoice(nextBatches[0] ? String(nextBatches[0].batch_id) : "");
        setNewSession((current) => ({
          ...current,
          batch_id: current.batch_id || (nextEnrollments[0] ? String(nextEnrollments[0].batch_id) : nextBatches[0] ? String(nextBatches[0].batch_id) : ""),
        }));
        setNewFixture((current) => ({
          ...current,
          batch_id: current.batch_id || (nextBatches[0] ? String(nextBatches[0].batch_id) : ""),
        }));
      } catch (cause) {
        if (!ignore) setError(cause instanceof ApiError ? cause.message : "This content could not be loaded.");
      } finally {
        if (!ignore) setLoading(false);
      }
    }

    load();
    return () => {
      ignore = true;
    };
  }, [kind, personId, version]);

  function saved() {
    setNotice("Saved");
    setError("");
    setVersion((current) => current + 1);
    onChanged();
  }

  function fail(cause: unknown) {
    setNotice("");
    setError(cause instanceof ApiError ? cause.message : "The change could not be saved.");
  }

  async function addBatch() {
    if (!batchChoice) return;
    try {
      await api("/batches/enrollments", {
        method: "POST",
        body: JSON.stringify({ batch_id: Number(batchChoice), student_id: personId }),
      });
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function removeBatch(enrollmentId: number) {
    try {
      await api(`/batches/enrollments/${enrollmentId}`, { method: "DELETE" });
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function saveBatch(event: FormEvent<HTMLFormElement>, batch: Batch) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    try {
      await api(`/batches/${batch.batch_id}`, {
        method: "PATCH",
        body: JSON.stringify({
          name: String(data.get("name") ?? ""),
          days: String(data.get("days") ?? ""),
          sport: String(data.get("sport") ?? ""),
          meeting_point: String(data.get("meeting_point") ?? "") || null,
          focus: String(data.get("focus") ?? "") || null,
          kit: String(data.get("kit") ?? "") || null,
        }),
      });
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function deleteBatch(batch: Batch) {
    if (!window.confirm(`Delete ${batch.name}? Sessions and fixtures in this batch are removed too.`)) return;
    try {
      await api(`/batches/${batch.batch_id}`, { method: "DELETE" });
      saved();
    } catch (cause) {
      fail(cause);
    }
  }

  async function saveSession(session: SessionDraft) {
    try {
      await api(`/sessions/${session.session_id}`, {
        method: "PATCH",
        body: JSON.stringify({
          batch_id: Number(session.batch_id),
          date: session.date,
          start: session.start,
          end: session.end,
          ground: session.ground || null,
          note: session.note || null,
        }),
      });
      if (session.attendance) {
        if (kind === "player") {
          await api(`/sessions/${session.session_id}/student-attendance`, {
            method: "POST",
            body: JSON.stringify({ student_id: personId, status: session.attendance }),
          });
        } else {
          await api(`/sessions/${session.session_id}/coach-attendance?coach_id=${personId}`, {
            method: "POST",
            body: JSON.stringify({ status: session.attendance }),
          });
        }
      }
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function createSession(event: FormEvent) {
    event.preventDefault();
    try {
      const created = await api<TrainingSession>("/sessions", {
        method: "POST",
        body: JSON.stringify({
          batch_id: Number(newSession.batch_id),
          date: newSession.date,
          start: newSession.start,
          end: newSession.end,
          ground: newSession.ground || null,
          note: newSession.note || null,
        }),
      });
      if (kind === "coach") {
        await api("/sessions/assignments", {
          method: "POST",
          body: JSON.stringify({ session_id: created.session_id, coach_id: personId }),
        });
      }
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function assignSession() {
    if (!sessionChoice) return;
    try {
      await api("/sessions/assignments", {
        method: "POST",
        body: JSON.stringify({ session_id: Number(sessionChoice), coach_id: personId }),
      });
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function saveFixture(fixture: FixtureDraft) {
    try {
      await api(`/matches/${fixture.match_id}`, {
        method: "PATCH",
        body: JSON.stringify({
          batch_id: Number(fixture.batch_id),
          title: fixture.title,
          opponent: fixture.opponent || null,
          date: fixture.date,
          start: fixture.start,
          end: fixture.end,
          status: fixture.status,
          venue: fixture.venue || null,
          result: fixture.result || null,
        }),
      });
      saved();
    } catch (cause) {
      fail(cause);
    }
  }

  async function deleteSession(session: SessionDraft) {
    if (!window.confirm("Delete this session?")) return;
    try {
      await api(`/sessions/${session.session_id}`, { method: "DELETE" });
      saved();
    } catch (cause) {
      fail(cause);
    }
  }

  async function deleteFixture(fixture: FixtureDraft) {
    if (!window.confirm(`Delete ${fixture.title}?`)) return;
    try {
      await api(`/matches/${fixture.match_id}`, { method: "DELETE" });
      saved();
    } catch (cause) {
      fail(cause);
    }
  }

  async function createFixture(event: FormEvent) {
    event.preventDefault();
    try {
      await api("/matches", {
        method: "POST",
        body: JSON.stringify({
          batch_id: Number(newFixture.batch_id),
          title: newFixture.title,
          opponent: newFixture.opponent || null,
          date: newFixture.date,
          start: newFixture.start,
          end: newFixture.end,
          status: newFixture.status,
          venue: newFixture.venue || null,
          result: newFixture.result || null,
        }),
      });
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function saveFee(event: FormEvent) {
    event.preventDefault();
    const body = {
      amount: fee.amount,
      due_date: fee.due_date,
      status: fee.status,
    };
    try {
      if (fee.bill_id) {
        await api(`/bills/${fee.bill_id}`, { method: "PATCH", body: JSON.stringify(body) });
      } else {
        await api("/bills", {
          method: "POST",
          body: JSON.stringify({
            ...body,
            student_id: kind === "player" ? personId : null,
            coach_id: kind === "coach" ? personId : null,
          }),
        });
      }
      saved();
      onChanged();
    } catch (cause) {
      fail(cause);
    }
  }

  async function saveLeave(leave: Leave) {
    try {
      await api(`/leaves/${leave.leave_id}`, {
        method: "PATCH",
        body: JSON.stringify({
          from_date: day(leave.from_date),
          to_date: day(leave.to_date),
          reason: leave.reason,
          status: leave.status,
        }),
      });
      saved();
    } catch (cause) {
      fail(cause);
    }
  }

  function patchSession(sessionId: number, patch: Partial<SessionDraft>) {
    setSessions((rows) => rows.map((row) => (row.session_id === sessionId ? { ...row, ...patch } : row)));
  }

  function patchFixture(matchId: number, patch: Partial<FixtureDraft>) {
    setFixtures((rows) => rows.map((row) => (row.match_id === matchId ? { ...row, ...patch } : row)));
  }

  if (loading) {
    return <p className="text-sm text-muted">Loading sessions, fixtures, and fees</p>;
  }

  const enrolledBatches = batches.filter((batch) => enrollments.some((row) => row.batch_id === batch.batch_id));
  const show = (panel: Panel) => (panels ? panels.includes(panel) : panel !== "batch" || kind === "player");
  const coachBatches = batches.filter((batch) => sessions.some((session) => Number(session.batch_id) === batch.batch_id));
  const listedFixtures =
    kind === "player"
      ? fixtures.filter((fixture) => enrollments.some((row) => String(row.batch_id) === fixture.batch_id))
      : fixtures;

  return (
    <div className="flex flex-col gap-4">
      {error ? <p className="text-sm text-terracotta">{error}</p> : null}
      {notice ? <p className="text-sm text-success">{notice}</p> : null}

      {show("batch") && kind === "player" ? (
        <Section title={titles?.batch ?? "Batch"}>
          {hints?.batch ? <p className="text-sm text-muted sm:col-span-2">{hints.batch}</p> : null}
          <div className="sm:col-span-2 flex flex-col gap-3">
            {enrollments.length === 0 ? <p className="text-sm text-muted">This player is not in a batch yet.</p> : null}
            {enrollments.map((enrollment) => (
              <div key={enrollment.enrollment_id} className="flex items-center justify-between gap-3">
                <p className="text-sm font-semibold">{enrollment.batch_name || "Batch"}</p>
                <button type="button" onClick={() => removeBatch(enrollment.enrollment_id)} className="text-sm font-semibold text-terracotta">
                  Remove
                </button>
              </div>
            ))}
            <div className="flex flex-wrap items-center gap-2">
              <select value={batchChoice} onChange={(event) => setBatchChoice(event.target.value)} className={fieldClass}>
                {batches.map((batch) => (
                  <option key={batch.batch_id} value={batch.batch_id}>
                    {batch.name}
                  </option>
                ))}
              </select>
              <button type="button" onClick={addBatch} className={buttonClass}>
                Add to batch
              </button>
            </div>
          </div>
          {enrolledBatches.map((batch) => (
            <form key={batch.batch_id} onSubmit={(event) => saveBatch(event, batch)} className="sm:col-span-2 grid gap-3 sm:grid-cols-2">
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch name</span>
                <input name="name" defaultValue={batch.name} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Days</span>
                <input name="days" defaultValue={batch.days} className={fieldClass} />
              </label>
              <label className="block sm:col-span-2">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Sport</span>
                <input name="sport" defaultValue={batch.sport} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Meeting point</span>
                <input name="meeting_point" defaultValue={batch.meeting_point ?? ""} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Training focus</span>
                <input name="focus" defaultValue={batch.focus ?? ""} className={fieldClass} />
              </label>
              <label className="block sm:col-span-2">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Kit shown on the session card</span>
                <input name="kit" defaultValue={batch.kit ?? ""} className={fieldClass} />
              </label>
              <div className="flex items-center gap-3">
                <button type="submit" className={buttonClass}>
                  Save batch
                </button>
                <button type="button" onClick={() => deleteBatch(batch)} className="text-sm font-semibold text-terracotta">
                  Delete
                </button>
              </div>
            </form>
          ))}
        </Section>
      ) : null}

      {show("batch") && kind === "coach" ? (
        <Section title={titles?.batch ?? "Batch on the session card"}>
          {hints?.batch ? <p className="text-sm text-muted sm:col-span-2">{hints.batch}</p> : null}
          <div className="flex flex-col gap-4 sm:col-span-2">
            {coachBatches.length === 0 ? <p className="text-sm text-muted">Assign a session before editing its batch.</p> : null}
            {coachBatches.map((batch) => (
              <form key={batch.batch_id} onSubmit={(event) => saveBatch(event, batch)} className="grid gap-3 sm:grid-cols-2">
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch name</span>
                  <input name="name" defaultValue={batch.name} className={fieldClass} />
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Days</span>
                  <input name="days" defaultValue={batch.days} className={fieldClass} />
                </label>
                <label className="block sm:col-span-2">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Sport</span>
                  <input name="sport" defaultValue={batch.sport} className={fieldClass} />
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Meeting point</span>
                  <input name="meeting_point" defaultValue={batch.meeting_point ?? ""} className={fieldClass} />
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Training focus</span>
                  <input name="focus" defaultValue={batch.focus ?? ""} className={fieldClass} />
                </label>
                <label className="block sm:col-span-2">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Kit shown on the session card</span>
                  <input name="kit" defaultValue={batch.kit ?? ""} className={fieldClass} />
                </label>
                <div className="flex items-center gap-3">
                  <button type="submit" className={buttonClass}>
                    Save batch
                  </button>
                  <button type="button" onClick={() => deleteBatch(batch)} className="text-sm font-semibold text-terracotta">
                    Delete
                  </button>
                </div>
              </form>
            ))}
          </div>
        </Section>
      ) : null}

      {show("sessions") ? (
      <Section title={titles?.sessions ?? "Sessions"}>
        {hints?.sessions ? <p className="text-sm text-muted sm:col-span-2">{hints.sessions}</p> : null}
        <div className="sm:col-span-2 flex flex-col gap-4">
          {sessions.length === 0 ? <p className="text-sm text-muted">No sessions on this schedule yet.</p> : null}
          {sessions.map((session) => (
            <div key={session.session_id} className="grid gap-3 rounded-2xl border border-line bg-card px-4 py-4 sm:grid-cols-2">
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Date</span>
                <DateInput value={session.date} onChange={(value) => patchSession(session.session_id, { date: value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
                <select value={session.batch_id} onChange={(event) => patchSession(session.session_id, { batch_id: event.target.value })} className={fieldClass}>
                  {batches.map((batch) => (
                    <option key={batch.batch_id} value={batch.batch_id}>
                      {batch.name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Start</span>
                <input type="time" value={session.start} onChange={(event) => patchSession(session.session_id, { start: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">End</span>
                <input type="time" value={session.end} onChange={(event) => patchSession(session.session_id, { end: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Ground</span>
                <input value={session.ground} onChange={(event) => patchSession(session.session_id, { ground: event.target.value })} className={fieldClass} />
              </label>
              <label className="block sm:col-span-2">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Note for players and coaches</span>
                <input value={session.note} onChange={(event) => patchSession(session.session_id, { note: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Attendance</span>
                <select value={session.attendance} onChange={(event) => patchSession(session.session_id, { attendance: event.target.value })} className={fieldClass}>
                  <option value="">Not marked</option>
                  <option value="present">Present</option>
                  <option value="absent">Absent</option>
                </select>
              </label>
              <div className="flex items-end gap-3">
                <button type="button" onClick={() => saveSession(session)} className={buttonClass}>
                  Save session
                </button>
                <button type="button" onClick={() => deleteSession(session)} className="text-sm font-semibold text-terracotta">
                  Delete
                </button>
              </div>
            </div>
          ))}
          <form onSubmit={createSession} className="grid gap-3 sm:grid-cols-2">
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">New session date</span>
              <DateInput required value={newSession.date} onChange={(value) => setNewSession({ ...newSession, date: value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
              <select required value={newSession.batch_id} onChange={(event) => setNewSession({ ...newSession, batch_id: event.target.value })} className={fieldClass}>
                {batches.map((batch) => (
                  <option key={batch.batch_id} value={batch.batch_id}>
                    {batch.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Start</span>
              <input type="time" required value={newSession.start} onChange={(event) => setNewSession({ ...newSession, start: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">End</span>
              <input type="time" required value={newSession.end} onChange={(event) => setNewSession({ ...newSession, end: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Ground</span>
              <input value={newSession.ground} onChange={(event) => setNewSession({ ...newSession, ground: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Note</span>
              <input value={newSession.note} onChange={(event) => setNewSession({ ...newSession, note: event.target.value })} className={fieldClass} />
            </label>
            <button type="submit" className={buttonClass}>
              Add session
            </button>
          </form>
          {kind === "coach" ? (
            <div className="flex flex-wrap items-center gap-2">
              <select value={sessionChoice} onChange={(event) => setSessionChoice(event.target.value)} className={fieldClass}>
                <option value="">Assign an existing session</option>
                {openSessions
                  .filter((session) => !session.coaches.some((coach) => coach.coach_id === personId))
                  .map((session) => (
                    <option key={session.session_id} value={session.session_id}>
                      {day(session.date)} · {session.batch_name || "Session"} · {clock(session.start)}
                    </option>
                  ))}
              </select>
              <button type="button" onClick={assignSession} className={buttonClass}>
                Assign
              </button>
            </div>
          ) : null}
        </div>
      </Section>
      ) : null}

      {show("fixtures") ? (
      <Section title={titles?.fixtures ?? "Fixtures"}>
        {hints?.fixtures ? <p className="text-sm text-muted sm:col-span-2">{hints.fixtures}</p> : null}
        <div className="sm:col-span-2 flex flex-col gap-4">
          {listedFixtures.length === 0 ? <p className="text-sm text-muted">No fixtures yet.</p> : null}
          {listedFixtures.map((fixture) => (
            <div key={fixture.match_id} className="grid gap-3 rounded-2xl border border-line bg-card px-4 py-4 sm:grid-cols-2">
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Title</span>
                <input value={fixture.title} onChange={(event) => patchFixture(fixture.match_id, { title: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Opponent</span>
                <input value={fixture.opponent} onChange={(event) => patchFixture(fixture.match_id, { opponent: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Venue</span>
                <input value={fixture.venue} onChange={(event) => patchFixture(fixture.match_id, { venue: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Result</span>
                <input value={fixture.result} onChange={(event) => patchFixture(fixture.match_id, { result: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Date</span>
                <DateInput value={fixture.date} onChange={(value) => patchFixture(fixture.match_id, { date: value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Status</span>
                <select value={fixture.status} onChange={(event) => patchFixture(fixture.match_id, { status: event.target.value })} className={fieldClass}>
                  <option value="upcoming">Upcoming</option>
                  <option value="ongoing">Ongoing</option>
                  <option value="previous">Previous</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Start</span>
                <input type="time" value={fixture.start} onChange={(event) => patchFixture(fixture.match_id, { start: event.target.value })} className={fieldClass} />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">End</span>
                <input type="time" value={fixture.end} onChange={(event) => patchFixture(fixture.match_id, { end: event.target.value })} className={fieldClass} />
              </label>
              <label className="block sm:col-span-2">
                <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
                <select value={fixture.batch_id} onChange={(event) => patchFixture(fixture.match_id, { batch_id: event.target.value })} className={fieldClass}>
                  {batches.map((batch) => (
                    <option key={batch.batch_id} value={batch.batch_id}>
                      {batch.name}
                    </option>
                  ))}
                </select>
              </label>
              <div className="flex items-end gap-3">
                <button type="button" onClick={() => saveFixture(fixture)} className={buttonClass}>
                  Save fixture
                </button>
                <button type="button" onClick={() => deleteFixture(fixture)} className="text-sm font-semibold text-terracotta">
                  Delete
                </button>
              </div>
            </div>
          ))}
          <form onSubmit={createFixture} className="grid gap-3 sm:grid-cols-2">
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">New fixture</span>
              <input required value={newFixture.title} onChange={(event) => setNewFixture({ ...newFixture, title: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Opponent</span>
              <input value={newFixture.opponent} onChange={(event) => setNewFixture({ ...newFixture, opponent: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Venue</span>
              <input value={newFixture.venue} onChange={(event) => setNewFixture({ ...newFixture, venue: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Result</span>
              <input value={newFixture.result} onChange={(event) => setNewFixture({ ...newFixture, result: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Date</span>
              <DateInput required value={newFixture.date} onChange={(value) => setNewFixture({ ...newFixture, date: value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
              <select required value={newFixture.batch_id} onChange={(event) => setNewFixture({ ...newFixture, batch_id: event.target.value })} className={fieldClass}>
                {batches.map((batch) => (
                  <option key={batch.batch_id} value={batch.batch_id}>
                    {batch.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Start</span>
              <input type="time" required value={newFixture.start} onChange={(event) => setNewFixture({ ...newFixture, start: event.target.value })} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">End</span>
              <input type="time" required value={newFixture.end} onChange={(event) => setNewFixture({ ...newFixture, end: event.target.value })} className={fieldClass} />
            </label>
            <button type="submit" className={buttonClass}>
              Add fixture
            </button>
          </form>
        </div>
      </Section>
      ) : null}

      {show("fee") ? (
      <Section title={titles?.fee ?? "Fee"}>
        {hints?.fee ? <p className="text-sm text-muted sm:col-span-2">{hints.fee}</p> : null}
        <form onSubmit={saveFee} className="sm:col-span-2 grid gap-3 sm:grid-cols-2">
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Amount</span>
            <input required value={fee.amount} onChange={(event) => setFee({ ...fee, amount: event.target.value })} className={fieldClass} />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Due date</span>
            <DateInput required value={fee.due_date} onChange={(value) => setFee({ ...fee, due_date: value })} className={fieldClass} />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Status</span>
            <select value={fee.status} onChange={(event) => setFee({ ...fee, status: event.target.value })} className={fieldClass}>
              <option value="due">Due</option>
              <option value="paid">Paid</option>
              <option value="overdue">Overdue</option>
            </select>
          </label>
          <div className="flex items-end">
            <button type="submit" className={buttonClass}>
              Save fee
            </button>
          </div>
        </form>
      </Section>
      ) : null}

      {show("leave") && kind === "coach" && leaves.length > 0 ? (
        <Section title={titles?.leave ?? "Leave"}>
          {hints?.leave ? <p className="text-sm text-muted sm:col-span-2">{hints.leave}</p> : null}
          <div className="sm:col-span-2 flex flex-col gap-4">
            {leaves.map((leave) => (
              <div key={leave.leave_id} className="grid gap-3 rounded-2xl border border-line bg-card px-4 py-4 sm:grid-cols-2">
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">From</span>
                  <DateInput range={false} value={day(leave.from_date)} onChange={(value) => setLeaves((rows) => rows.map((row) => (row.leave_id === leave.leave_id ? { ...row, from_date: value } : row)))} className={fieldClass} />
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">To</span>
                  <DateInput range={false} value={day(leave.to_date)} onChange={(value) => setLeaves((rows) => rows.map((row) => (row.leave_id === leave.leave_id ? { ...row, to_date: value } : row)))} className={fieldClass} />
                </label>
                <label className="block sm:col-span-2">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Reason</span>
                  <input value={leave.reason} onChange={(event) => setLeaves((rows) => rows.map((row) => (row.leave_id === leave.leave_id ? { ...row, reason: event.target.value } : row)))} className={fieldClass} />
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Status</span>
                  <select value={leave.status} onChange={(event) => setLeaves((rows) => rows.map((row) => (row.leave_id === leave.leave_id ? { ...row, status: event.target.value } : row)))} className={fieldClass}>
                    <option value="pending">Pending</option>
                    <option value="approved">Approved</option>
                    <option value="rejected">Rejected</option>
                  </select>
                </label>
                <div className="flex items-end">
                  <button type="button" onClick={() => saveLeave(leave)} className={buttonClass}>
                    Save leave
                  </button>
                </div>
              </div>
            ))}
          </div>
        </Section>
      ) : null}
    </div>
  );
}
