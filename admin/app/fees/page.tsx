"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DateInput } from "@/components/date-input";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import { formatDate, initials, rupees } from "@/lib/format";
import type { Bill, Coach, Student } from "@/lib/types";

type Kind = "player" | "coach";

type Account = {
  kind: Kind;
  id: number;
  name: string;
  contact: string;
  email: string;
};

const statuses = ["due", "paid", "overdue"] as const;

export default function FeesPage() {
  return (
    <AuthGate allow="accountant">
      <FeeDesk />
    </AuthGate>
  );
}

function FeeDesk() {
  const [players, setPlayers] = useState<Student[]>([]);
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [bills, setBills] = useState<Bill[]>([]);
  const [kind, setKind] = useState<Kind>("player");
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Account | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    Promise.all([api<Student[]>("/students"), api<Coach[]>("/coaches"), api<Bill[]>("/bills")])
      .then(([nextPlayers, nextCoaches, nextBills]) => {
        setPlayers(nextPlayers);
        setCoaches(nextCoaches);
        setBills(nextBills);
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Fees could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  const accounts = useMemo(() => {
    const rows: Account[] =
      kind === "player"
        ? players.map((player) => ({
            kind: "player",
            id: player.student_id,
            name: player.name,
            contact: player.mobile || player.parent_mobile,
            email: player.email || "",
          }))
        : coaches.map((coach) => ({
            kind: "coach",
            id: coach.coach_id,
            name: coach.name,
            contact: coach.mobile,
            email: coach.email || "",
          }));
    const needle = query.trim().toLowerCase();
    return rows.filter((account) => {
      if (!needle) return true;
      return `${account.name} ${account.contact} ${account.email}`.toLowerCase().includes(needle);
    });
  }, [coaches, kind, players, query]);

  function billsFor(account: Account | null): Bill[] {
    if (!account) return [];
    return bills.filter((bill) =>
      account.kind === "player" ? bill.student_id === account.id : bill.coach_id === account.id,
    );
  }

  function feeLine(account: Account): string {
    const latest = billsFor(account)[0];
    if (!latest) return "No fee yet";
    return `${rupees(latest.amount)} · ${latest.status}`;
  }

  return (
    <DeskShell active="fees" mode="accountant">
      <div className="flex min-h-0 flex-1">
        <section
          className={`${selected ? "hidden lg:flex" : "flex"} w-full shrink-0 flex-col border-line lg:w-[360px] lg:border-r min-[1920px]:w-[440px]`}
        >
          <div className="border-b border-line px-4 py-4">
            <h1 className="font-serif text-3xl font-medium">Fees</h1>
            <p className="mt-1 text-sm text-muted">{loading ? "Loading" : "Player and coach accounts"}</p>
            <div className="mt-4 flex gap-2">
              <TabButton active={kind === "player"} onClick={() => { setKind("player"); setSelected(null); }}>
                Players
              </TabButton>
              <TabButton active={kind === "coach"} onClick={() => { setKind("coach"); setSelected(null); }}>
                Coaches
              </TabButton>
            </div>
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search name, mobile, or email"
              className="mt-4 w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
            />
          </div>
          <div className="flex flex-1 flex-col gap-2 overflow-y-auto px-4 py-4">
            {error ? <p className="text-sm text-terracotta">{error}</p> : null}
            {!loading && !error && accounts.length === 0 ? (
              <p className="text-sm text-muted">{query.trim() ? "No one matches that search." : "No accounts yet."}</p>
            ) : null}
            {accounts.map((account) => {
              const active = selected?.kind === account.kind && selected.id === account.id;
              return (
                <button
                  key={`${account.kind}-${account.id}`}
                  type="button"
                  onClick={() => setSelected(account)}
                  className={`rounded-2xl border px-3 py-3 text-left ${
                    active ? "border-terracotta bg-card" : "border-line bg-card/70 hover:bg-card"
                  }`}
                >
                  <span className="flex gap-3">
                    <span
                      className={`mt-0.5 flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-sm font-bold text-white ${
                        account.kind === "player" ? "bg-teal" : "bg-terracotta"
                      }`}
                    >
                      {initials(account.name)}
                    </span>
                    <span className="min-w-0">
                      <span className="block truncate font-serif text-lg leading-tight">{account.name}</span>
                      <span className="block truncate text-sm text-muted">{account.contact || "No mobile"}</span>
                      <span className="block truncate text-sm">{feeLine(account)}</span>
                    </span>
                  </span>
                </button>
              );
            })}
          </div>
        </section>
        <section className={`${selected ? "flex" : "hidden lg:flex"} min-w-0 flex-1 flex-col`}>
          {selected ? (
            <FeeEditor
              key={`${selected.kind}-${selected.id}`}
              account={selected}
              bills={billsFor(selected)}
              onBack={() => setSelected(null)}
              onSaved={(saved) => {
                setBills((rows) => {
                  const rest = rows.filter((row) => row.bill_id !== saved.bill_id);
                  return [saved, ...rest].sort((a, b) => b.due_date.localeCompare(a.due_date));
                });
              }}
            />
          ) : (
            <p className="m-auto max-w-sm px-6 text-center text-sm text-muted">
              Select a player or coach to update their fee.
            </p>
          )}
        </section>
      </div>
    </DeskShell>
  );
}

function FeeEditor({
  account,
  bills,
  onBack,
  onSaved,
}: {
  account: Account;
  bills: Bill[];
  onBack: () => void;
  onSaved: (bill: Bill) => void;
}) {
  const [billId, setBillId] = useState<number | null>(bills[0]?.bill_id ?? null);
  const current = bills.find((bill) => bill.bill_id === billId) ?? null;
  const [amount, setAmount] = useState(current ? String(current.amount) : "");
  const [dueDate, setDueDate] = useState(current ? current.due_date.slice(0, 10) : "");
  const [status, setStatus] = useState(current?.status || "due");
  const [pending, setPending] = useState(false);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");

  function choose(bill: Bill | null) {
    setBillId(bill?.bill_id ?? null);
    setAmount(bill ? String(bill.amount) : "");
    setDueDate(bill ? bill.due_date.slice(0, 10) : "");
    setStatus(bill?.status || "due");
    setNotice("");
    setError("");
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    const parsed = Number(amount);
    if (!amount.trim() || Number.isNaN(parsed) || parsed <= 0) {
      setError("Enter a fee amount greater than zero.");
      setNotice("");
      return;
    }
    if (!dueDate) {
      setError("Choose a due date.");
      setNotice("");
      return;
    }
    setPending(true);
    setError("");
    setNotice("");
    const body = { amount: parsed, due_date: dueDate, status };
    try {
      const saved = billId
        ? await api<Bill>(`/bills/${billId}`, { method: "PATCH", body: JSON.stringify(body) })
        : await api<Bill>("/bills", {
            method: "POST",
            body: JSON.stringify({
              ...body,
              student_id: account.kind === "player" ? account.id : null,
              coach_id: account.kind === "coach" ? account.id : null,
            }),
          });
      setBillId(saved.bill_id);
      setNotice("Saved");
      onSaved(saved);
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The fee could not be saved.");
    } finally {
      setPending(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex min-h-0 flex-1 flex-col">
      <div className="flex items-center gap-3 border-b border-line px-5 py-4">
        <button type="button" onClick={onBack} className="text-sm font-semibold text-terracotta lg:hidden">
          Back
        </button>
        <div>
          <h2 className="font-serif text-3xl font-medium">{account.name}</h2>
          <p className="text-sm text-muted">
            {account.kind === "player" ? "Player account" : "Coach account"}
            {account.email ? ` · ${account.email}` : ""}
          </p>
        </div>
      </div>
      <div className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => choose(null)}
            className={`rounded-full px-3 py-1.5 text-sm font-semibold ${
              billId === null ? "bg-terracotta text-white" : "bg-card text-ink-text"
            }`}
          >
            New fee
          </button>
          {bills.map((bill) => (
            <button
              key={bill.bill_id}
              type="button"
              onClick={() => choose(bill)}
              className={`rounded-full px-3 py-1.5 text-sm font-semibold ${
                bill.bill_id === billId ? "bg-terracotta text-white" : "bg-card text-ink-text"
              }`}
            >
              {rupees(bill.amount)} · {formatDate(bill.due_date)}
            </button>
          ))}
        </div>
        <section className="rounded-2xl border border-line bg-card/80 p-4 sm:p-5">
          <h3 className="font-serif text-xl font-medium">{billId ? "Update fee" : "Add fee"}</h3>
          <div className="mt-4 grid gap-4 sm:grid-cols-2">
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Amount</span>
              <input
                inputMode="decimal"
                value={amount}
                onChange={(event) => {
                  setAmount(event.target.value);
                  setNotice("");
                  setError("");
                }}
                className="w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm outline-none focus:border-terracotta"
              />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Due date</span>
              <DateInput
                value={dueDate}
                onChange={(value) => {
                  setDueDate(value);
                  setNotice("");
                  setError("");
                }}
                className="w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm outline-none focus:border-terracotta"
              />
            </label>
            <label className="block sm:col-span-2">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Status</span>
              <select
                value={status}
                onChange={(event) => {
                  setStatus(event.target.value);
                  setNotice("");
                  setError("");
                }}
                className="w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm outline-none focus:border-terracotta"
              >
                {statuses.map((item) => (
                  <option key={item} value={item}>
                    {item}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </section>
        <div className="flex flex-wrap items-center gap-3">
          <button
            type="submit"
            disabled={pending}
            className="rounded-xl bg-terracotta px-5 py-2.5 text-sm font-bold text-white hover:bg-terracotta-dark disabled:opacity-60"
          >
            {pending ? "Saving" : "Save"}
          </button>
          {notice ? <p className="text-sm text-success">{notice}</p> : null}
          {error ? <p className="text-sm text-terracotta">{error}</p> : null}
        </div>
      </div>
    </form>
  );
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`rounded-full px-3 py-1.5 text-sm font-semibold ${
        active ? "bg-terracotta text-white" : "bg-card text-ink-text"
      }`}
    >
      {children}
    </button>
  );
}
