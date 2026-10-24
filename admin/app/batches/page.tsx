"use client";

import { FormEvent, useEffect, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import type { Batch } from "@/lib/types";

const fieldClass =
  "w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm text-ink-text outline-none focus:border-terracotta";
const buttonClass = "rounded-xl bg-terracotta px-4 py-2 text-sm font-bold text-white disabled:opacity-60";

type Draft = {
  name: string;
  days: string;
  sport: string;
  meeting_point: string;
  focus: string;
  kit: string;
};

const emptyDraft: Draft = {
  name: "",
  days: "",
  sport: "Multi-sport",
  meeting_point: "",
  focus: "",
  kit: "",
};

function toDraft(batch: Batch): Draft {
  return {
    name: batch.name,
    days: batch.days,
    sport: batch.sport,
    meeting_point: batch.meeting_point ?? "",
    focus: batch.focus ?? "",
    kit: batch.kit ?? "",
  };
}

export default function BatchesPage() {
  return (
    <AuthGate allow="super_admin">
      <BatchDesk />
    </AuthGate>
  );
}

function BatchDesk() {
  const [batches, setBatches] = useState<Batch[]>([]);
  const [drafts, setDrafts] = useState<Record<number, Draft>>({});
  const [creating, setCreating] = useState<Draft>(emptyDraft);
  const [loading, setLoading] = useState(true);
  const [pendingId, setPendingId] = useState<number | "new" | null>(null);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");

  function apply(rows: Batch[]) {
    setBatches(rows);
    setDrafts(Object.fromEntries(rows.map((batch) => [batch.batch_id, toDraft(batch)])));
  }

  useEffect(() => {
    api<Batch[]>("/batches")
      .then(apply)
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Batches could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  function patch(id: number, change: Partial<Draft>) {
    setDrafts((current) => ({ ...current, [id]: { ...current[id], ...change } }));
    setNotice("");
    setError("");
  }

  async function save(batch: Batch) {
    const draft = drafts[batch.batch_id];
    if (!draft?.name.trim() || !draft.days.trim() || !draft.sport.trim()) {
      setError("Name, days, and sport are required.");
      setNotice("");
      return;
    }
    setPendingId(batch.batch_id);
    setError("");
    try {
      const saved = await api<Batch>(`/batches/${batch.batch_id}`, {
        method: "PATCH",
        body: JSON.stringify({
          name: draft.name.trim(),
          days: draft.days.trim(),
          sport: draft.sport.trim(),
          meeting_point: draft.meeting_point.trim() || null,
          focus: draft.focus.trim() || null,
          kit: draft.kit.trim() || null,
        }),
      });
      setBatches((rows) => rows.map((row) => (row.batch_id === saved.batch_id ? saved : row)));
      setDrafts((current) => ({ ...current, [saved.batch_id]: toDraft(saved) }));
      setNotice("Saved");
    } catch (cause) {
      setNotice("");
      setError(cause instanceof ApiError ? cause.message : "The batch could not be saved.");
    } finally {
      setPendingId(null);
    }
  }

  async function remove(batch: Batch) {
    if (!window.confirm(`Delete ${batch.name}? Sessions and fixtures in this batch are removed too.`)) return;
    setPendingId(batch.batch_id);
    setError("");
    try {
      await api(`/batches/${batch.batch_id}`, { method: "DELETE" });
      setBatches((rows) => rows.filter((row) => row.batch_id !== batch.batch_id));
      setNotice("Deleted");
    } catch (cause) {
      setNotice("");
      setError(cause instanceof ApiError ? cause.message : "The batch could not be deleted.");
    } finally {
      setPendingId(null);
    }
  }

  async function create(event: FormEvent) {
    event.preventDefault();
    if (!creating.name.trim() || !creating.days.trim() || !creating.sport.trim()) {
      setError("Name, days, and sport are required.");
      setNotice("");
      return;
    }
    setPendingId("new");
    setError("");
    try {
      const saved = await api<Batch>("/batches", {
        method: "POST",
        body: JSON.stringify({
          name: creating.name.trim(),
          days: creating.days.trim(),
          sport: creating.sport.trim(),
        }),
      });
      const withDetails =
        creating.meeting_point.trim() || creating.focus.trim() || creating.kit.trim()
          ? await api<Batch>(`/batches/${saved.batch_id}`, {
              method: "PATCH",
              body: JSON.stringify({
                meeting_point: creating.meeting_point.trim() || null,
                focus: creating.focus.trim() || null,
                kit: creating.kit.trim() || null,
              }),
            })
          : saved;
      setBatches((rows) => [...rows, withDetails]);
      setDrafts((current) => ({ ...current, [withDetails.batch_id]: toDraft(withDetails) }));
      setCreating(emptyDraft);
      setNotice("Saved");
    } catch (cause) {
      setNotice("");
      setError(cause instanceof ApiError ? cause.message : "The batch could not be added.");
    } finally {
      setPendingId(null);
    }
  }

  return (
    <DeskShell active="batches" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">ACADEMY SETUP</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">Batches</h1>
        <p className="mt-2 max-w-xl text-sm text-muted">
          Meeting point, focus, and kit show on the coach and player session cards.
        </p>
        {loading ? <p className="mt-6 text-sm text-muted">Loading batches</p> : null}
        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}
        {notice ? <p className="mt-4 text-sm text-success">{notice}</p> : null}

        <form onSubmit={create} className="mt-6 grid max-w-3xl gap-3 rounded-2xl border border-line bg-card p-4 sm:grid-cols-2 min-[1300px]:max-w-none">
          <p className="font-serif text-2xl sm:col-span-2">Add batch</p>
          <Labeled label="Name" value={creating.name} onChange={(value) => setCreating({ ...creating, name: value })} />
          <Labeled label="Days" value={creating.days} onChange={(value) => setCreating({ ...creating, days: value })} />
          <Labeled label="Sport" value={creating.sport} onChange={(value) => setCreating({ ...creating, sport: value })} />
          <Labeled
            label="Meeting point"
            value={creating.meeting_point}
            onChange={(value) => setCreating({ ...creating, meeting_point: value })}
          />
          <Labeled label="Focus" value={creating.focus} onChange={(value) => setCreating({ ...creating, focus: value })} />
          <Labeled label="Kit" value={creating.kit} onChange={(value) => setCreating({ ...creating, kit: value })} />
          <div className="sm:col-span-2">
            <button type="submit" disabled={pendingId === "new"} className={buttonClass}>
              {pendingId === "new" ? "Saving" : "Add batch"}
            </button>
          </div>
        </form>

        <div className="mt-6 flex max-w-3xl flex-col gap-4 min-[1300px]:max-w-none">
          {batches.map((batch) => {
            const draft = drafts[batch.batch_id] ?? toDraft(batch);
            return (
              <div key={batch.batch_id} className="grid gap-3 rounded-2xl border border-line bg-card p-4 sm:grid-cols-2">
                <p className="text-sm text-muted sm:col-span-2">{batch.student_count} players</p>
                <Labeled label="Name" value={draft.name} onChange={(value) => patch(batch.batch_id, { name: value })} />
                <Labeled label="Days" value={draft.days} onChange={(value) => patch(batch.batch_id, { days: value })} />
                <Labeled label="Sport" value={draft.sport} onChange={(value) => patch(batch.batch_id, { sport: value })} />
                <Labeled
                  label="Meeting point"
                  value={draft.meeting_point}
                  onChange={(value) => patch(batch.batch_id, { meeting_point: value })}
                />
                <Labeled label="Focus" value={draft.focus} onChange={(value) => patch(batch.batch_id, { focus: value })} />
                <Labeled label="Kit" value={draft.kit} onChange={(value) => patch(batch.batch_id, { kit: value })} />
                <div className="flex items-center gap-3 sm:col-span-2">
                  <button
                    type="button"
                    disabled={pendingId === batch.batch_id}
                    onClick={() => save(batch)}
                    className={buttonClass}
                  >
                    {pendingId === batch.batch_id ? "Saving" : "Update"}
                  </button>
                  <button type="button" onClick={() => remove(batch)} className="text-sm font-semibold text-terracotta">
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

function Labeled({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">{label}</span>
      <input value={value} onChange={(event) => onChange(event.target.value)} className={fieldClass} />
    </label>
  );
}
