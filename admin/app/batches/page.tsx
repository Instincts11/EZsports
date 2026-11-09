"use client";

import { FormEvent, useEffect, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import type { Batch, Coach } from "@/lib/types";

const fieldClass =
  "w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm text-ink-text outline-none focus:border-terracotta";
const buttonClass = "rounded-xl bg-terracotta px-4 py-2 text-sm font-bold text-white disabled:opacity-60";

type Draft = {
  name: string;
  centre: string;
  coach_id: string;
  description: string;
};

const emptyDraft: Draft = {
  name: "",
  centre: "",
  coach_id: "",
  description: "",
};

function toDraft(batch: Batch): Draft {
  return {
    name: batch.name,
    centre: batch.centre ?? "",
    coach_id: batch.coach_id ? String(batch.coach_id) : "",
    description: batch.description ?? "",
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
  const [coaches, setCoaches] = useState<Coach[]>([]);
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
    Promise.all([api<Batch[]>("/batches"), api<Coach[]>("/coaches")])
      .then(([rows, nextCoaches]) => {
        apply(rows);
        setCoaches(nextCoaches);
      })
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

  function payload(draft: Draft) {
    return {
      name: draft.name.trim(),
      centre: draft.centre.trim() || null,
      description: draft.description.trim() || null,
      coach_id: draft.coach_id ? Number(draft.coach_id) : null,
    };
  }

  async function save(batch: Batch) {
    const draft = drafts[batch.batch_id];
    if (!draft?.name.trim()) {
      setError("Name is required.");
      setNotice("");
      return;
    }
    setPendingId(batch.batch_id);
    setError("");
    try {
      const saved = await api<Batch>(`/batches/${batch.batch_id}`, {
        method: "PATCH",
        body: JSON.stringify(payload(draft)),
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
    if (!creating.name.trim()) {
      setError("Name is required.");
      setNotice("");
      return;
    }
    setPendingId("new");
    setError("");
    try {
      const saved = await api<Batch>("/batches", {
        method: "POST",
        body: JSON.stringify(payload(creating)),
      });
      setBatches((rows) => [...rows, saved]);
      setDrafts((current) => ({ ...current, [saved.batch_id]: toDraft(saved) }));
      setCreating(emptyDraft);
      setNotice("Saved");
    } catch (cause) {
      setNotice("");
      setError(cause instanceof ApiError ? cause.message : "The batch could not be added.");
    } finally {
      setPendingId(null);
    }
  }

  const centreNames = [...new Set(batches.map((batch) => batch.centre?.trim()).filter((name): name is string => !!name))].sort();

  return (
    <DeskShell active="batches" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">ACADEMY SETUP</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">Batches</h1>
        {loading ? <p className="mt-6 text-sm text-muted">Loading batches</p> : null}
        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}
        {notice ? <p className="mt-4 text-sm text-success">{notice}</p> : null}

        <form onSubmit={create} className="mt-6 grid max-w-3xl gap-3 rounded-2xl border border-line bg-card p-4 sm:grid-cols-2 min-[1300px]:max-w-none">
          <p className="font-serif text-2xl sm:col-span-2">Add batch</p>
          <Labeled label="Name" value={creating.name} onChange={(value) => setCreating({ ...creating, name: value })} />
          <Labeled
            label="Centre"
            value={creating.centre}
            list="centre-names"
            onChange={(value) => setCreating({ ...creating, centre: value })}
          />
          <CoachField
            coaches={coaches}
            value={creating.coach_id}
            onChange={(value) => setCreating({ ...creating, coach_id: value })}
          />
          <DescriptionField
            value={creating.description}
            onChange={(value) => setCreating({ ...creating, description: value })}
          />
          <div className="sm:col-span-2">
            <button type="submit" disabled={pendingId === "new"} className={buttonClass}>
              {pendingId === "new" ? "Saving" : "Add batch"}
            </button>
          </div>
        </form>

        <datalist id="centre-names">
          {centreNames.map((name) => (
            <option key={name} value={name} />
          ))}
        </datalist>

        <div className="mt-6 flex max-w-3xl flex-col gap-4 min-[1300px]:max-w-none">
          {batches.map((batch) => {
            const draft = drafts[batch.batch_id] ?? toDraft(batch);
            return (
              <div key={batch.batch_id} className="grid gap-3 rounded-2xl border border-line bg-card p-4 sm:grid-cols-2">
                <p className="text-sm text-muted sm:col-span-2">
                  {batch.student_count} students{batch.centre ? ` · ${batch.centre}` : ""}
                </p>
                <Labeled label="Name" value={draft.name} onChange={(value) => patch(batch.batch_id, { name: value })} />
                <Labeled
                  label="Centre"
                  value={draft.centre}
                  list="centre-names"
                  onChange={(value) => patch(batch.batch_id, { centre: value })}
                />
                <CoachField
                  coaches={coaches}
                  value={draft.coach_id}
                  onChange={(value) => patch(batch.batch_id, { coach_id: value })}
                />
                <DescriptionField
                  value={draft.description}
                  onChange={(value) => patch(batch.batch_id, { description: value })}
                />
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
  list,
  onChange,
}: {
  label: string;
  value: string;
  list?: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">{label}</span>
      <input value={value} list={list} onChange={(event) => onChange(event.target.value)} className={fieldClass} />
    </label>
  );
}

function CoachField({
  coaches,
  value,
  onChange,
}: {
  coaches: Coach[];
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Coach</span>
      <select value={value} onChange={(event) => onChange(event.target.value)} className={fieldClass}>
        <option value="">No coach</option>
        {coaches.map((coach) => (
          <option key={coach.coach_id} value={coach.coach_id}>
            {coach.name}
          </option>
        ))}
      </select>
    </label>
  );
}

function DescriptionField({ value, onChange }: { value: string; onChange: (value: string) => void }) {
  return (
    <label className="block sm:col-span-2">
      <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Description</span>
      <textarea
        value={value}
        rows={3}
        onChange={(event) => onChange(event.target.value)}
        className={fieldClass}
      />
    </label>
  );
}
