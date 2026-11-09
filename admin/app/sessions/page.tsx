"use client";

import { FormEvent, useEffect, useState } from "react";
import Link from "next/link";
import { AuthGate } from "@/components/auth-gate";
import { DateInput } from "@/components/date-input";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import type { Batch, Coach, SessionRosterStudent, TrainingSession } from "@/lib/types";

const fieldClass =
  "w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm text-ink-text outline-none focus:border-terracotta";
const buttonClass = "rounded-xl bg-terracotta px-4 py-2 text-sm font-bold text-white disabled:opacity-60";

type Draft = {
  batch_id: string;
  date: string;
  start: string;
  end: string;
  ground: string;
  note: string;
};


function clock(value: string) {
  return value ? value.slice(0, 5) : "";
}

export function sessionGroupKey(session: TrainingSession) {
  return String(session.batch_id);
}

function sessionStart(session: TrainingSession) {
  return new Date(`${session.date.slice(0, 10)}T${clock(session.start) || "00:00"}`).getTime();
}

function sessionEnd(session: TrainingSession) {
  const start = sessionStart(session);
  let end = new Date(`${session.date.slice(0, 10)}T${clock(session.end) || "23:59"}`).getTime();
  if (Number.isNaN(end)) return start;
  if (end < start) end += 24 * 60 * 60 * 1000;
  return end;
}

function markedSessions(sessions: TrainingSession[], now = Date.now()) {
  if (sessions.length === 0) return { currentId: null as number | null, latestId: null as number | null };
  const latest = sessions.reduce((best, session) => (sessionStart(session) > sessionStart(best) ? session : best));
  const ongoing = sessions.find((session) => sessionStart(session) <= now && now <= sessionEnd(session));
  const started = sessions
    .filter((session) => sessionStart(session) <= now)
    .sort((left, right) => sessionStart(right) - sessionStart(left));
  const upcoming = sessions
    .filter((session) => sessionStart(session) > now)
    .sort((left, right) => sessionStart(left) - sessionStart(right));
  const current = ongoing ?? started[0] ?? upcoming[0] ?? latest;
  return { currentId: current.session_id, latestId: latest.session_id };
}

type SessionGroup = {
  key: string;
  label: string;
  centre: string;
  sessions: TrainingSession[];
};

const noCentre = "No centre set";

function groupSessions(sessions: TrainingSession[]): SessionGroup[] {
  const grouped = new Map<string, TrainingSession[]>();
  for (const session of sessions) {
    const key = sessionGroupKey(session);
    const rows = grouped.get(key) ?? [];
    rows.push(session);
    grouped.set(key, rows);
  }
  return [...grouped.entries()]
    .map(([key, rows]) => {
      const ordered = [...rows].sort((left, right) => sessionStart(right) - sessionStart(left));
      const sample = ordered[0];
      return {
        key,
        label: sample.batch_name || "Session",
        centre: sample.centre?.trim() || noCentre,
        sessions: ordered,
      };
    })
    .sort((left, right) => left.label.localeCompare(right.label));
}

function toDraft(session: TrainingSession): Draft {
  return {
    batch_id: String(session.batch_id),
    date: session.date.slice(0, 10),
    start: clock(session.start),
    end: clock(session.end),
    ground: session.ground ?? "",
    note: session.note ?? "",
  };
}

const emptyNew = {
  batch_id: "",
  date: "",
  start: "16:00",
  end: "17:00",
  ground: "",
  note: "",
};

export default function SessionsPage() {
  return (
    <AuthGate allow="super_admin">
      <SessionDesk />
    </AuthGate>
  );
}

export function SessionDesk({ group }: { group?: string }) {
  const [sessions, setSessions] = useState<TrainingSession[]>([]);
  const [batches, setBatches] = useState<Batch[]>([]);
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [drafts, setDrafts] = useState<Record<number, Draft>>({});
  const [assignChoice, setAssignChoice] = useState<Record<number, string>>({});
  const [rosters, setRosters] = useState<Record<number, SessionRosterStudent[] | "loading">>({});
  const [creating, setCreating] = useState(emptyNew);
  const [loading, setLoading] = useState(true);
  const [pendingId, setPendingId] = useState<number | "new" | null>(null);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");

  function apply(rows: TrainingSession[]) {
    setSessions(rows);
    setDrafts(Object.fromEntries(rows.map((session) => [session.session_id, toDraft(session)])));
  }

  function reload() {
    return api<TrainingSession[]>("/sessions").then(apply);
  }

  useEffect(() => {
    Promise.all([api<TrainingSession[]>("/sessions"), api<Batch[]>("/batches"), api<Coach[]>("/coaches")])
      .then(([nextSessions, nextBatches, nextCoaches]) => {
        apply(nextSessions);
        setBatches(nextBatches);
        setCoaches(nextCoaches);
        setCreating((current) => ({
          ...current,
          batch_id: current.batch_id || (nextBatches[0] ? String(nextBatches[0].batch_id) : ""),
        }));
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Sessions could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  function fail(cause: unknown, fallback: string) {
    setNotice("");
    setError(cause instanceof ApiError ? cause.message : fallback);
  }

  function patch(id: number, change: Partial<Draft>) {
    setDrafts((current) => ({ ...current, [id]: { ...current[id], ...change } }));
    setNotice("");
    setError("");
  }

  async function save(session: TrainingSession) {
    const draft = drafts[session.session_id];
    if (!draft?.date || !draft.start || !draft.end || !draft.batch_id) {
      setError("Batch, date, start, and end are required.");
      return;
    }
    setPendingId(session.session_id);
    setError("");
    try {
      await api(`/sessions/${session.session_id}`, {
        method: "PATCH",
        body: JSON.stringify({
          batch_id: Number(draft.batch_id),
          date: draft.date,
          start: draft.start,
          end: draft.end,
          ground: draft.ground.trim() || null,
          note: draft.note.trim() || null,
        }),
      });
      await reload();
      setNotice("Saved");
    } catch (cause) {
      fail(cause, "The session could not be saved.");
    } finally {
      setPendingId(null);
    }
  }

  async function remove(session: TrainingSession) {
    const label = session.batch_name || "this session";
    if (!window.confirm(`Delete the ${label} session on ${session.date.slice(0, 10)}?`)) return;
    setPendingId(session.session_id);
    setError("");
    try {
      await api(`/sessions/${session.session_id}`, { method: "DELETE" });
      setSessions((rows) => rows.filter((row) => row.session_id !== session.session_id));
      setNotice("Deleted");
    } catch (cause) {
      fail(cause, "The session could not be deleted.");
    } finally {
      setPendingId(null);
    }
  }

  async function assign(session: TrainingSession) {
    const coachId = assignChoice[session.session_id];
    if (!coachId) return;
    setPendingId(session.session_id);
    setError("");
    try {
      await api("/sessions/assignments", {
        method: "POST",
        body: JSON.stringify({ session_id: session.session_id, coach_id: Number(coachId) }),
      });
      setAssignChoice((current) => ({ ...current, [session.session_id]: "" }));
      await reload();
      setNotice("Saved");
    } catch (cause) {
      fail(cause, "The coach could not be assigned.");
    } finally {
      setPendingId(null);
    }
  }

  async function markCoach(session: TrainingSession, coachId: number, status: "present" | "absent") {
    setPendingId(session.session_id);
    setError("");
    try {
      await api(`/sessions/${session.session_id}/coach-attendance?coach_id=${coachId}`, {
        method: "POST",
        body: JSON.stringify({ status }),
      });
      setSessions((rows) =>
        rows.map((row) =>
          row.session_id === session.session_id
            ? {
                ...row,
                coaches: row.coaches.map((coach) =>
                  coach.coach_id === coachId ? { ...coach, attendance_status: status } : coach,
                ),
              }
            : row,
        ),
      );
      setNotice("Saved");
    } catch (cause) {
      fail(cause, "The coach attendance could not be saved.");
    } finally {
      setPendingId(null);
    }
  }

  async function toggleRoster(session: TrainingSession) {
    const id = session.session_id;
    const close = () =>
      setRosters((current) => {
        const next = { ...current };
        delete next[id];
        return next;
      });
    if (rosters[id]) {
      close();
      return;
    }
    setRosters((current) => ({ ...current, [id]: "loading" }));
    try {
      const rows = await api<SessionRosterStudent[]>(`/sessions/${id}/students`);
      setRosters((current) => ({ ...current, [id]: rows }));
    } catch (cause) {
      close();
      fail(cause, "The players for this session could not be loaded.");
    }
  }

  async function unassign(sessionId: number, assignmentId: number) {
    setPendingId(sessionId);
    setError("");
    try {
      await api(`/sessions/assignments/${assignmentId}`, { method: "DELETE" });
      await reload();
      setNotice("Saved");
    } catch (cause) {
      fail(cause, "The coach could not be removed.");
    } finally {
      setPendingId(null);
    }
  }

  async function create(event: FormEvent) {
    event.preventDefault();
    if (!creating.batch_id || !creating.date) {
      setError("Batch and date are required.");
      return;
    }
    setPendingId("new");
    setError("");
    try {
      await api("/sessions", {
        method: "POST",
        body: JSON.stringify({
          batch_id: Number(creating.batch_id),
          date: creating.date,
          start: creating.start,
          end: creating.end,
          ground: creating.ground.trim() || null,
          note: creating.note.trim() || null,
        }),
      });
      await reload();
      setCreating((current) => ({ ...emptyNew, batch_id: current.batch_id }));
      setNotice("Saved");
    } catch (cause) {
      fail(cause, "The session could not be added.");
    } finally {
      setPendingId(null);
    }
  }

  const groups = groupSessions(sessions);
  const selected = group ? groups.find((item) => item.key === group) : undefined;
  const marks = markedSessions(selected?.sessions ?? []);

  return (
    <DeskShell active="sessions" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">ACADEMY SETUP</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">Sessions</h1>
        <p className="mt-2 max-w-xl text-sm text-muted">
          Batches are grouped by centre. Open a batch to see every date, mark coach attendance, and see its players.
          Current and latest dates are highlighted.
        </p>
        {loading ? <p className="mt-6 text-sm text-muted">Loading sessions</p> : null}
        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}
        {notice ? <p className="mt-4 text-sm text-success">{notice}</p> : null}

        <form onSubmit={create} className="mt-6 grid max-w-3xl gap-3 rounded-2xl border border-line bg-card p-4 sm:grid-cols-2 min-[1300px]:max-w-none">
          <p className="font-serif text-2xl sm:col-span-2">Add session</p>
          <label className="block sm:col-span-2">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
            <select
              value={creating.batch_id}
              onChange={(event) => setCreating({ ...creating, batch_id: event.target.value })}
              className={fieldClass}
            >
              {batches.map((batch) => (
                <option key={batch.batch_id} value={batch.batch_id}>
                  {batch.name}
                </option>
              ))}
            </select>
          </label>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Date</span>
            <DateInput
              required
              value={creating.date}
              onChange={(value) => setCreating({ ...creating, date: value })}
              className={fieldClass}
            />
          </label>
          <div className="grid grid-cols-2 gap-3">
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Start</span>
              <input
                type="time"
                required
                value={creating.start}
                onChange={(event) => setCreating({ ...creating, start: event.target.value })}
                className={fieldClass}
              />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">End</span>
              <input
                type="time"
                required
                value={creating.end}
                onChange={(event) => setCreating({ ...creating, end: event.target.value })}
                className={fieldClass}
              />
            </label>
          </div>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Ground</span>
            <input
              value={creating.ground}
              onChange={(event) => setCreating({ ...creating, ground: event.target.value })}
              className={fieldClass}
            />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Note</span>
            <input
              value={creating.note}
              onChange={(event) => setCreating({ ...creating, note: event.target.value })}
              className={fieldClass}
            />
          </label>
          <div className="sm:col-span-2">
            <button type="submit" disabled={pendingId === "new" || batches.length === 0} className={buttonClass}>
              {pendingId === "new" ? "Saving" : "Add session"}
            </button>
          </div>
        </form>

        <div className="mt-6 max-w-3xl overflow-hidden rounded-2xl border border-line bg-card min-[1300px]:max-w-none">
        <SessionTabs groups={groups} selected={group} />

        <div className="flex flex-col gap-4 p-4">
          {!group ? <p className="text-sm text-muted">Choose a session to see its dates.</p> : null}
          {group && !selected && !loading ? <p className="text-sm text-muted">This session was not found.</p> : null}
          {(selected?.sessions ?? []).map((session) => {
            const draft = drafts[session.session_id] ?? toDraft(session);
            const assigned = new Set(session.coaches.map((coach) => coach.coach_id));
            const available = coaches.filter((coach) => !assigned.has(coach.coach_id));
            const badges = [
              session.session_id === marks.currentId ? "Current" : "",
              session.session_id === marks.latestId ? "Latest" : "",
            ].filter(Boolean);
            return (
              <div
                key={session.session_id}
                className={`grid gap-3 rounded-2xl border p-4 sm:grid-cols-2 ${
                  badges.length > 0 ? "border-terracotta bg-cream ring-2 ring-terracotta/30" : "border-line bg-card"
                }`}
              >
                <div className="flex flex-wrap items-center gap-2 sm:col-span-2">
                  <p className="font-serif text-2xl">{session.batch_name || "Session"}</p>
                  <p className="text-sm text-muted">
                    {draft.date} · {draft.start}–{draft.end}
                    {session.centre ? ` · ${session.centre}` : ""}
                  </p>
                  {badges.map((badge) => (
                    <span key={badge} className="rounded-full bg-terracotta px-2.5 py-0.5 text-xs font-bold text-white">
                      {badge}
                    </span>
                  ))}
                </div>
                <label className="block sm:col-span-2">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
                  <select
                    value={draft.batch_id}
                    onChange={(event) => patch(session.session_id, { batch_id: event.target.value })}
                    className={fieldClass}
                  >
                    {batches.map((batch) => (
                      <option key={batch.batch_id} value={batch.batch_id}>
                        {batch.name}
                      </option>
                    ))}
                  </select>
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Date</span>
                  <DateInput
                    value={draft.date}
                    onChange={(value) => patch(session.session_id, { date: value })}
                    className={fieldClass}
                  />
                </label>
                <div className="grid grid-cols-2 gap-3">
                  <label className="block">
                    <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Start</span>
                    <input
                      type="time"
                      value={draft.start}
                      onChange={(event) => patch(session.session_id, { start: event.target.value })}
                      className={fieldClass}
                    />
                  </label>
                  <label className="block">
                    <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">End</span>
                    <input
                      type="time"
                      value={draft.end}
                      onChange={(event) => patch(session.session_id, { end: event.target.value })}
                      className={fieldClass}
                    />
                  </label>
                </div>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Ground</span>
                  <input
                    value={draft.ground}
                    onChange={(event) => patch(session.session_id, { ground: event.target.value })}
                    className={fieldClass}
                  />
                </label>
                <label className="block">
                  <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Note</span>
                  <input
                    value={draft.note}
                    onChange={(event) => patch(session.session_id, { note: event.target.value })}
                    className={fieldClass}
                  />
                </label>
                <div className="sm:col-span-2">
                  <p className="mb-2 text-xs font-semibold tracking-wide text-muted">Assigned coaches and attendance</p>
                  {session.coaches.length === 0 ? <p className="text-sm text-muted">No coach assigned</p> : null}
                  <ul className="flex flex-col gap-2">
                    {session.coaches.map((coach) => (
                      <li key={coach.assignment_id} className="flex flex-wrap items-center justify-between gap-3 text-sm">
                        <span>{coach.coach_name || "Coach"}</span>
                        <span className="flex items-center gap-2">
                          {(["present", "absent"] as const).map((status) => (
                            <button
                              key={status}
                              type="button"
                              disabled={pendingId === session.session_id}
                              aria-pressed={coach.attendance_status === status}
                              onClick={() => markCoach(session, coach.coach_id, status)}
                              className={`rounded-full px-3 py-1 text-xs font-bold capitalize disabled:opacity-60 ${
                                coach.attendance_status === status
                                  ? status === "present"
                                    ? "bg-teal text-white"
                                    : "bg-terracotta text-white"
                                  : "border border-line bg-cream text-ink-text hover:border-terracotta"
                              }`}
                            >
                              {status}
                            </button>
                          ))}
                          <button
                            type="button"
                            onClick={() => unassign(session.session_id, coach.assignment_id)}
                            className="ml-1 font-semibold text-terracotta"
                          >
                            Remove
                          </button>
                        </span>
                      </li>
                    ))}
                  </ul>
                  {available.length > 0 ? (
                    <div className="mt-3 flex flex-wrap items-center gap-3">
                      <select
                        value={assignChoice[session.session_id] ?? ""}
                        onChange={(event) =>
                          setAssignChoice((current) => ({ ...current, [session.session_id]: event.target.value }))
                        }
                        className={`${fieldClass} max-w-xs`}
                      >
                        <option value="">Choose a coach</option>
                        {available.map((coach) => (
                          <option key={coach.coach_id} value={coach.coach_id}>
                            {coach.name}
                          </option>
                        ))}
                      </select>
                      <button type="button" onClick={() => assign(session)} className={buttonClass}>
                        Assign
                      </button>
                    </div>
                  ) : null}
                </div>
                <div className="sm:col-span-2">
                  <button
                    type="button"
                    onClick={() => toggleRoster(session)}
                    className="text-sm font-semibold text-terracotta"
                  >
                    {rosters[session.session_id] ? "Hide players" : `Show players (${session.student_count})`}
                  </button>
                  <SessionRoster rows={rosters[session.session_id]} />
                </div>
                <div className="flex items-center gap-3 sm:col-span-2">
                  <button
                    type="button"
                    disabled={pendingId === session.session_id}
                    onClick={() => save(session)}
                    className={buttonClass}
                  >
                    {pendingId === session.session_id ? "Saving" : "Update"}
                  </button>
                  <button type="button" onClick={() => remove(session)} className="text-sm font-semibold text-terracotta">
                    Delete
                  </button>
                </div>
              </div>
            );
          })}
        </div>
        </div>
      </div>
    </DeskShell>
  );
}

function SessionRoster({ rows }: { rows?: SessionRosterStudent[] | "loading" }) {
  if (!rows) return null;
  if (rows === "loading") return <p className="mt-2 text-sm text-muted">Loading players</p>;
  if (rows.length === 0) return <p className="mt-2 text-sm text-muted">No players in this batch yet.</p>;
  const present = rows.filter((row) => row.attendance_status === "present").length;
  return (
    <div className="mt-3 overflow-hidden rounded-xl border border-line">
      <p className="border-b border-line bg-cream/60 px-3 py-2 text-xs font-semibold text-muted">
        {present} of {rows.length} marked present
      </p>
      <ul className="divide-y divide-line">
        {rows.map((row) => (
          <li key={row.student_id} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
            <span className="font-semibold">{row.name}</span>
            <span className="flex flex-wrap items-center gap-2 text-xs">
              <span className="text-muted">
                {row.skip_reason ? `Skipping: ${row.skip_reason}` : row.checked_in ? "Checked in" : ""}
              </span>
              <span
                className={`rounded-full px-2 py-0.5 font-bold ${
                  row.attendance_status === "present"
                    ? "bg-teal text-white"
                    : row.attendance_status === "absent"
                      ? "bg-terracotta text-white"
                      : "bg-cream text-muted"
                }`}
              >
                {row.attendance_status === "present" ? "Present" : row.attendance_status === "absent" ? "Absent" : "Not marked"}
              </span>
              <span className="rounded-full border border-line px-2 py-0.5 capitalize text-muted">Fee {row.fee_status}</span>
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

function SessionTabs({ groups, selected }: { groups: SessionGroup[]; selected?: string }) {
  if (groups.length === 0) return null;
  const centres = new Map<string, SessionGroup[]>();
  for (const item of groups) {
    centres.set(item.centre, [...(centres.get(item.centre) ?? []), item]);
  }
  const ordered = [...centres.entries()].sort(([left], [right]) => {
    if (left === noCentre) return 1;
    if (right === noCentre) return -1;
    return left.localeCompare(right);
  });
  return (
    <div className="flex flex-col gap-3 border-b border-line bg-cream/60 p-3" role="tablist" aria-label="Sessions">
      {ordered.map(([centre, items]) => (
        <div key={centre}>
          <p className="mb-2 text-xs font-bold tracking-[0.14em] text-muted uppercase">{centre}</p>
          <div className="flex flex-wrap gap-2">
            {items.map((item) => {
              const active = item.key === selected;
              return (
                <Link
                  key={item.key}
                  href={`/sessions/${item.key}`}
                  role="tab"
                  aria-selected={active}
                  className={`rounded-full px-4 py-2 text-sm font-semibold ${
                    active ? "bg-terracotta text-white" : "border border-line bg-card text-ink-text hover:border-terracotta"
                  }`}
                >
                  {item.label}
                  <span className={active ? "text-white/80" : "text-muted"}> {item.sessions.length}</span>
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
