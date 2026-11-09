"use client";

import { useEffect, useMemo, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import { formatDate, rupees } from "@/lib/format";
import type { Batch, Bill, Enrollment, Student } from "@/lib/types";

const noCentre = "No centre set";

type Money = {
  collected: number;
  pending: number;
  overdue: number;
};

type BatchSummary = {
  batch: Batch;
  players: Student[];
  money: Money;
};

type CentreSummary = {
  name: string;
  batches: BatchSummary[];
  playerCount: number;
  money: Money;
};

function emptyMoney(): Money {
  return { collected: 0, pending: 0, overdue: 0 };
}

function addBills(money: Money, bills: Bill[]): Money {
  for (const bill of bills) {
    const amount = Number(bill.amount) || 0;
    if (bill.status === "paid") money.collected += amount;
    else money.pending += amount;
    if (bill.status === "overdue") money.overdue += amount;
  }
  return money;
}

function summarise(batches: Batch[], enrollments: Enrollment[], students: Student[], bills: Bill[]): CentreSummary[] {
  const studentsById = new Map(students.map((student) => [student.student_id, student]));
  const billsByStudent = new Map<number, Bill[]>();
  for (const bill of bills) {
    if (bill.student_id == null) continue;
    billsByStudent.set(bill.student_id, [...(billsByStudent.get(bill.student_id) ?? []), bill]);
  }
  const centres = new Map<string, BatchSummary[]>();
  for (const batch of batches) {
    const ids = new Set(enrollments.filter((row) => row.batch_id === batch.batch_id).map((row) => row.student_id));
    const players = [...ids]
      .map((id) => studentsById.get(id))
      .filter((student): student is Student => student !== undefined)
      .sort((left, right) => left.name.localeCompare(right.name));
    const money = players.reduce((total, player) => addBills(total, billsByStudent.get(player.student_id) ?? []), emptyMoney());
    const name = batch.centre?.trim() || noCentre;
    centres.set(name, [...(centres.get(name) ?? []), { batch, players, money }]);
  }
  return [...centres.entries()]
    .map(([name, rows]) => {
      const unique = new Map(rows.flatMap((row) => row.players).map((player) => [player.student_id, player]));
      const money = [...unique.keys()].reduce(
        (total, id) => addBills(total, billsByStudent.get(id) ?? []),
        emptyMoney(),
      );
      return {
        name,
        batches: rows.sort((left, right) => left.batch.name.localeCompare(right.batch.name)),
        playerCount: unique.size,
        money,
      };
    })
    .sort((left, right) => {
      if (left.name === noCentre) return 1;
      if (right.name === noCentre) return -1;
      return left.name.localeCompare(right.name);
    });
}

export default function CentresPage() {
  return (
    <AuthGate allow="super_admin">
      <CentreDesk />
    </AuthGate>
  );
}

function CentreDesk() {
  const [batches, setBatches] = useState<Batch[]>([]);
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [students, setStudents] = useState<Student[]>([]);
  const [bills, setBills] = useState<Bill[]>([]);
  const [centreName, setCentreName] = useState<string | null>(null);
  const [batchId, setBatchId] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    Promise.all([
      api<Batch[]>("/batches"),
      api<Enrollment[]>("/batches/enrollments"),
      api<Student[]>("/students"),
      api<Bill[]>("/bills"),
    ])
      .then(([nextBatches, nextEnrollments, nextStudents, nextBills]) => {
        setBatches(nextBatches);
        setEnrollments(nextEnrollments);
        setStudents(nextStudents);
        setBills(nextBills);
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Centres could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  const centres = useMemo(() => summarise(batches, enrollments, students, bills), [batches, enrollments, students, bills]);
  const centre = centres.find((item) => item.name === centreName) ?? centres[0] ?? null;
  const batch = centre?.batches.find((item) => item.batch.batch_id === batchId) ?? null;
  const billsByStudent = useMemo(() => {
    const map = new Map<number, Bill[]>();
    for (const bill of bills) {
      if (bill.student_id == null) continue;
      map.set(bill.student_id, [...(map.get(bill.student_id) ?? []), bill]);
    }
    return map;
  }, [bills]);
  const academyCollected = centres.reduce((total, item) => total + item.money.collected, 0);

  return (
    <DeskShell active="centres" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">ACADEMY SETUP</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">Centres</h1>
        <p className="mt-2 max-w-2xl text-sm text-muted">
          Revenue, players, and fees for each centre and batch. Set a batch&apos;s centre on the Batches page. A player in
          two batches counts in both batches, but only once in the centre total.
        </p>
        {loading ? <p className="mt-6 text-sm text-muted">Loading centres</p> : null}
        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}

        {!loading && !error ? (
          <p className="mt-4 text-sm">
            Collected across all centres: <span className="font-bold">{rupees(academyCollected)}</span>
          </p>
        ) : null}

        <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
          {centres.map((item) => {
            const active = item.name === centre?.name;
            return (
              <button
                key={item.name}
                type="button"
                onClick={() => {
                  setCentreName(item.name);
                  setBatchId(null);
                }}
                className={`rounded-2xl border p-4 text-left ${
                  active ? "border-terracotta bg-card ring-2 ring-terracotta/30" : "border-line bg-card/70 hover:bg-card"
                }`}
              >
                <p className="font-serif text-2xl">{item.name}</p>
                <p className="mt-1 text-sm text-muted">
                  {item.batches.length} {item.batches.length === 1 ? "batch" : "batches"} · {item.playerCount}{" "}
                  {item.playerCount === 1 ? "player" : "players"}
                </p>
                <MoneyLine money={item.money} />
              </button>
            );
          })}
        </div>

        {centre ? (
          <section className="mt-8">
            <h2 className="font-serif text-3xl font-medium">{centre.name}</h2>
            <p className="mt-1 text-sm text-muted">Choose a batch to see its players and fee payments.</p>
            <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
              {centre.batches.map((item) => {
                const active = item.batch.batch_id === batch?.batch.batch_id;
                return (
                  <button
                    key={item.batch.batch_id}
                    type="button"
                    onClick={() => setBatchId(active ? null : item.batch.batch_id)}
                    className={`rounded-2xl border p-4 text-left ${
                      active ? "border-terracotta bg-card ring-2 ring-terracotta/30" : "border-line bg-card/70 hover:bg-card"
                    }`}
                  >
                    <p className="font-serif text-xl">{item.batch.name}</p>
                    <p className="mt-1 text-sm text-muted">
                      {item.batch.coach_name || "No coach"} · {item.players.length}{" "}
                      {item.players.length === 1 ? "player" : "players"}
                    </p>
                    <MoneyLine money={item.money} />
                  </button>
                );
              })}
            </div>
          </section>
        ) : null}

        {batch ? <BatchPlayers summary={batch} billsByStudent={billsByStudent} /> : null}
      </div>
    </DeskShell>
  );
}

function MoneyLine({ money }: { money: Money }) {
  return (
    <div className="mt-3 grid grid-cols-2 gap-2 text-sm">
      <span>
        <span className="block text-xs font-semibold tracking-wide text-muted">Collected</span>
        <span className="font-bold text-success">{rupees(money.collected)}</span>
      </span>
      <span>
        <span className="block text-xs font-semibold tracking-wide text-muted">Pending</span>
        <span className="font-bold text-terracotta">{rupees(money.pending)}</span>
        {money.overdue > 0 ? <span className="block text-xs text-terracotta">{rupees(money.overdue)} overdue</span> : null}
      </span>
    </div>
  );
}

function BatchPlayers({ summary, billsByStudent }: { summary: BatchSummary; billsByStudent: Map<number, Bill[]> }) {
  return (
    <section className="mt-8 overflow-hidden rounded-2xl border border-line bg-card">
      <div className="border-b border-line bg-cream/60 px-4 py-3">
        <h3 className="font-serif text-2xl">{summary.batch.name}</h3>
        <p className="text-sm text-muted">
          {summary.players.length} {summary.players.length === 1 ? "player" : "players"} · Collected{" "}
          {rupees(summary.money.collected)} · Pending {rupees(summary.money.pending)}
        </p>
      </div>
      {summary.players.length === 0 ? <p className="px-4 py-4 text-sm text-muted">No players in this batch yet.</p> : null}
      <ul className="divide-y divide-line">
        {summary.players.map((player) => {
          const playerBills = [...(billsByStudent.get(player.student_id) ?? [])].sort((left, right) =>
            right.due_date.localeCompare(left.due_date),
          );
          return (
            <li key={player.student_id} className="grid gap-3 px-4 py-4 md:grid-cols-[minmax(0,1fr)_minmax(0,1.4fr)]">
              <div className="min-w-0">
                <p className="font-semibold">{player.name}</p>
                <p className="text-sm text-muted">{player.mobile || player.parent_mobile || "No mobile"}</p>
                {player.guardian_name ? <p className="text-sm text-muted">Guardian: {player.guardian_name}</p> : null}
                <p className="mt-1 text-sm">
                  Attendance {player.attended} of {player.total_sessions}
                </p>
              </div>
              <div className="min-w-0">
                <p className="mb-1.5 text-xs font-semibold tracking-wide text-muted">Fee payments</p>
                {playerBills.length === 0 ? <p className="text-sm text-muted">No fees yet</p> : null}
                <ul className="flex flex-col gap-1.5">
                  {playerBills.map((bill) => (
                    <li key={bill.bill_id} className="flex flex-wrap items-center gap-2 text-sm">
                      <span className="font-semibold">{rupees(bill.amount)}</span>
                      <span className="text-muted">due {formatDate(bill.due_date)}</span>
                      <span
                        className={`rounded-full px-2 py-0.5 text-xs font-bold capitalize ${
                          bill.status === "paid" ? "bg-teal text-white" : "bg-terracotta text-white"
                        }`}
                      >
                        {bill.status}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
