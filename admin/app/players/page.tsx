"use client";

import { useEffect, useMemo, useState } from "react";
import { AddPlayerForm } from "@/components/add-person-forms";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { PersonList } from "@/components/person-list";
import { PlayerEditor } from "@/components/player-editor";
import { ApiError, api } from "@/lib/api";
import { rupees } from "@/lib/format";
import type { Student } from "@/lib/types";

export default function PlayersPage() {
  return (
    <AuthGate allow="super_admin">
      <PlayerDesk />
    </AuthGate>
  );
}

function playerDetail(student: Student): string {
  const batch = student.batch_name || "No batch";
  const amount = rupees(student.bill_amount);
  const status = student.bill_status || student.fee_status;
  const fee = [amount, status].filter(Boolean).join(" ");
  return fee ? `${batch} · ${fee}` : batch;
}

function PlayerDesk() {
  const [students, setStudents] = useState<Student[]>([]);
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [adding, setAdding] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    api<Student[]>("/students")
      .then(setStudents)
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Players could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  const visible = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return students.filter((student) => {
      if (!needle) return true;
      return `${student.name} ${student.mobile ?? ""} ${student.parent_mobile}`.toLowerCase().includes(needle);
    });
  }, [students, query]);

  const selected = students.find((student) => student.student_id === selectedId) ?? null;

  return (
    <DeskShell active="players" mode="admin">
      <div className="flex min-h-0 flex-1">
        <PersonList
          title="Players"
          summary={loading ? "Loading" : `${visible.length} ${visible.length === 1 ? "player" : "players"}`}
          query={query}
          onQuery={setQuery}
          people={visible.map((student) => ({
            id: student.student_id,
            name: student.name,
            mobile: student.mobile || student.parent_mobile,
            detail: playerDetail(student),
            accent: "player",
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
          emptyLabel={query.trim() ? "No one matches that search." : "No players yet."}
        />
        <section className={`${selected || adding ? "flex" : "hidden lg:flex"} min-w-0 flex-1 flex-col`}>
          {adding ? (
            <AddPlayerForm
              onCancel={() => setAdding(false)}
              onCreated={(created) => {
                setStudents((rows) => [created, ...rows.filter((row) => row.student_id !== created.student_id)]);
                setAdding(false);
                setSelectedId(created.student_id);
              }}
            />
          ) : selected ? (
            <PlayerEditor
              key={selected.student_id}
              student={selected}
              onBack={() => setSelectedId(null)}
              onSaved={(saved) => {
                setStudents((rows) =>
                  rows.map((row) => (row.student_id === saved.student_id ? saved : row)),
                );
              }}
              onDeleted={() => {
                setStudents((rows) => rows.filter((row) => row.student_id !== selected.student_id));
                setSelectedId(null);
              }}
            />
          ) : (
            <p className="m-auto max-w-sm px-6 text-center text-sm text-muted">
              Select a player to update their details.
            </p>
          )}
        </section>
      </div>
    </DeskShell>
  );
}
