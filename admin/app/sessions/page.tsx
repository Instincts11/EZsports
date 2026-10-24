"use client";

import { FormEvent, useEffect, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DateInput } from "@/components/date-input";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import type { Batch, Coach, TrainingSession } from "@/lib/types";

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

function SessionDesk() {
  const [sessions, setSessions] = useState<TrainingSession[]>([]);
  const [batches, setBatches] = useState<Batch[]>([]);
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [drafts, setDrafts] = useState<Record<number, Draft>>({});
  const [assignChoice, setAssignChoice] = useState<Record<number, string>>({});
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

  return (
    <DeskShell active="sessions" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">ACADEMY SETUP</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">Sessions</h1>
        <p className="mt-2 max-w-xl text-sm text-muted">
          Add a session, update the ground and note, and assign or remove coaches.
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

        <div className="mt-6 flex max-w-3xl flex-col gap-4 min-[1300px]:max-w-none">
          {sessions.map((session) => {
            const draft = drafts[session.session_id] ?? toDraft(session);
            const assigned = new Set(session.coaches.map((coach) => coach.coach_id));
            const available = coaches.filter((coach) => !assigned.has(coach.coach_id));
            return (
              <div key={session.session_id} className="grid gap-3 rounded-2xl border border-line bg-card p-4 sm:grid-cols-2">
                <p className="font-serif text-2xl sm:col-span-2">{session.batch_name || "Session"}</p>
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
                  <p className="mb-2 text-xs font-semibold tracking-wide text-muted">Assigned coaches</p>
                  {session.coaches.length === 0 ? <p className="text-sm text-muted">No coach assigned</p> : null}
                  <ul className="flex flex-col gap-2">
                    {session.coaches.map((coach) => (
                      <li key={coach.assignment_id} className="flex items-center justify-between gap-3 text-sm">
                        <span>{coach.coach_name || "Coach"}</span>
                        <button
                          type="button"
                          onClick={() => unassign(session.session_id, coach.assignment_id)}
                          className="font-semibold text-terracotta"
                        >
                          Remove
                        </button>
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
    </DeskShell>
  );
}
