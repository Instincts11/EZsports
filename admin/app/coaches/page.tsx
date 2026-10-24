"use client";

import { useEffect, useMemo, useState } from "react";
import { AddCoachForm } from "@/components/add-person-forms";
import { AuthGate } from "@/components/auth-gate";
import { CoachEditor } from "@/components/coach-editor";
import { DeskShell } from "@/components/desk-shell";
import { PersonList } from "@/components/person-list";
import { ApiError, api } from "@/lib/api";
import type { Coach } from "@/lib/types";

export default function CoachesPage() {
  return (
    <AuthGate allow="super_admin">
      <CoachDesk />
    </AuthGate>
  );
}

function CoachDesk() {
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [adding, setAdding] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    api<Coach[]>("/coaches")
      .then(setCoaches)
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Coaches could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  const visible = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return coaches.filter((coach) => {
      if (!needle) return true;
      return `${coach.name} ${coach.mobile}`.toLowerCase().includes(needle);
    });
  }, [coaches, query]);

  const selected = coaches.find((coach) => coach.coach_id === selectedId) ?? null;

  return (
    <DeskShell active="coaches" mode="admin">
      <div className="flex min-h-0 flex-1">
        <PersonList
          title="Coaches"
          summary={loading ? "Loading" : `${visible.length} ${visible.length === 1 ? "coach" : "coaches"}`}
          query={query}
          onQuery={setQuery}
          people={visible.map((coach) => ({
            id: coach.coach_id,
            name: coach.name,
            mobile: coach.mobile,
            detail: coach.experience || "No experience noted",
            accent: "coach",
          }))}
          selectedId={selectedId}
          onSelect={(id) => {
            setAdding(false);
            setSelectedId(id);
          }}
          addLabel="Add"
          onAdd={() => {
            setSelectedId(null);
            setAdding(true);
          }}
          hiddenOnNarrow={selected !== null || adding}
          loading={loading}
          error={error}
          emptyLabel={query.trim() ? "No one matches that search." : "No coaches yet."}
        />
        <section className={`${selected || adding ? "flex" : "hidden lg:flex"} min-w-0 flex-1 flex-col`}>
          {adding ? (
            <AddCoachForm
              onCancel={() => setAdding(false)}
              onCreated={(created) => {
                setCoaches((rows) => [created, ...rows.filter((row) => row.coach_id !== created.coach_id)]);
                setAdding(false);
                setSelectedId(created.coach_id);
              }}
            />
          ) : selected ? (
            <CoachEditor
              key={selected.coach_id}
              coach={selected}
              onBack={() => setSelectedId(null)}
              onSaved={(saved) => {
                setCoaches((rows) => rows.map((row) => (row.coach_id === saved.coach_id ? saved : row)));
              }}
              onDeleted={() => {
                setCoaches((rows) => rows.filter((row) => row.coach_id !== selected.coach_id));
                setSelectedId(null);
              }}
            />
          ) : (
            <p className="m-auto max-w-sm px-6 text-center text-sm text-muted">
              Select a coach to update their details.
            </p>
          )}
        </section>
      </div>
    </DeskShell>
  );
}
