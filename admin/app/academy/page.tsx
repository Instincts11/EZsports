"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import { rupees } from "@/lib/format";
import type { Academy, AcademyAdmin, Batch, Coach, Student } from "@/lib/types";

export default function AcademyPage() {
  return (
    <AuthGate allow="super_admin">
      <AcademyDesk />
    </AuthGate>
  );
}

function AcademyDesk() {
  const [academy, setAcademy] = useState<Academy | null>(null);
  const [admins, setAdmins] = useState<AcademyAdmin[]>([]);
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [players, setPlayers] = useState<Student[]>([]);
  const [batches, setBatches] = useState<Batch[]>([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);
  const [name, setName] = useState("");
  const [sport, setSport] = useState("");
  const [academyNotice, setAcademyNotice] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState("");
  const [directory, setDirectory] = useState<DirectoryTab>("admins");
  const [page, setPage] = useState(1);

  useEffect(() => {
    Promise.all([
      api<Academy>("/academy"),
      api<AcademyAdmin[]>("/admins"),
      api<Coach[]>("/coaches"),
      api<Student[]>("/students"),
      api<Batch[]>("/batches"),
    ])
      .then(([nextAcademy, nextAdmins, nextCoaches, nextPlayers, nextBatches]) => {
        setAcademy(nextAcademy);
        setName(nextAcademy.name);
        setSport(nextAcademy.sport);
        setAcademyNotice(nextAcademy.notice ?? "");
        setPhone(nextAcademy.phone ?? "");
        setAddress(nextAcademy.address ?? "");
        setAdmins(nextAdmins);
        setCoaches(nextCoaches);
        setPlayers(nextPlayers);
        setBatches(nextBatches);
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "The academy could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  const feesOpen = players.filter((player) => {
    const status = (player.bill_status || player.fee_status || "").toLowerCase();
    return status === "due" || status === "overdue";
  }).length;

  return (
    <DeskShell active="academy" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">FROM THE DATABASE</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">{academy?.name || "Academy"}</h1>
        <form
          className="mt-4 grid max-w-xl gap-3 sm:grid-cols-2 min-[1300px]:max-w-none"
          onSubmit={(event) => {
            event.preventDefault();
            setSaving(true);
            setNotice("");
            api<Academy>("/academy", {
              method: "PATCH",
              body: JSON.stringify({ name, sport, notice: academyNotice, phone, address }),
            })
              .then((saved) => {
                setAcademy(saved);
                setName(saved.name);
                setSport(saved.sport);
                setAcademyNotice(saved.notice ?? "");
                setPhone(saved.phone ?? "");
                setAddress(saved.address ?? "");
                setNotice("Saved");
              })
              .catch((cause: unknown) => {
                setError(cause instanceof ApiError ? cause.message : "The academy could not be saved.");
              })
              .finally(() => setSaving(false));
          }}
        >
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Academy name</span>
            <input
              value={name}
              onChange={(event) => setName(event.target.value)}
              className="w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
            />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Sport</span>
            <input
              value={sport}
              onChange={(event) => setSport(event.target.value)}
              className="w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
            />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Phone on coach and player home</span>
            <input
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              className="w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
            />
          </label>
          <label className="block sm:col-span-2">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Address on coach and player profile</span>
            <input
              value={address}
              onChange={(event) => setAddress(event.target.value)}
              className="w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
            />
          </label>
          <label className="block sm:col-span-2">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Notice on coach and player home</span>
            <textarea
              value={academyNotice}
              rows={3}
              onChange={(event) => setAcademyNotice(event.target.value)}
              className="w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
            />
          </label>
          <div className="flex items-center gap-3 sm:col-span-2">
            <button
              type="submit"
              disabled={saving}
              className="rounded-xl bg-terracotta px-4 py-2 text-sm font-bold text-white disabled:opacity-60"
            >
              {saving ? "Saving" : "Save academy"}
            </button>
            {notice ? <p className="text-sm text-success">{notice}</p> : null}
          </div>
        </form>
        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}

        <div className="mt-6 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          <Stat href="/admins" label="Admins" value={String(admins.length)} />
          <Stat href="/coaches" label="Coaches" value={String(coaches.length)} />
          <Stat href="/players" label="Players" value={String(players.length)} />
          <Stat href="/players" label="Fees open" value={String(feesOpen)} />
        </div>

        <DirectoryTabs
          value={directory}
          counts={{ admins: admins.length, coaches: coaches.length, players: players.length }}
          onChange={(next) => {
            setDirectory(next);
            setPage(1);
          }}
        />
        <Directory
          title={directoryTitle[directory]}
          href={directoryHref[directory]}
          page={page}
          onPage={setPage}
          rows={directoryRows(directory, admins, coaches, players)}
        />

        <section className="mt-6">
          <h2 className="font-serif text-2xl font-medium">Batches</h2>
          <div className="mt-3 grid gap-3 sm:grid-cols-2">
            {batches.map((batch) => (
              <article key={batch.batch_id} className="rounded-2xl border border-line bg-card px-4 py-4">
                <h3 className="font-serif text-xl">{batch.name}</h3>
                <p className="mt-1 text-sm text-muted">{batch.sport}</p>
                <p className="mt-2 text-sm">{batch.days}</p>
                {batch.meeting_point ? <p className="mt-1 text-sm">Meet at {batch.meeting_point}</p> : null}
                {batch.focus ? <p className="mt-1 text-sm">{batch.focus}</p> : null}
                {batch.kit ? <p className="mt-1 text-sm">Kit: {batch.kit}</p> : null}
                <p className="mt-1 text-sm">{batch.student_count} players</p>
              </article>
            ))}
            {!loading && batches.length === 0 ? <p className="text-sm text-muted">No batches yet.</p> : null}
          </div>
        </section>
      </div>
    </DeskShell>
  );
}

function Stat({ href, label, value }: { href: string; label: string; value: string }) {
  return (
    <Link href={href} className="rounded-2xl border border-line bg-card px-4 py-4">
      <p className="text-xs font-semibold tracking-wide text-muted uppercase">{label}</p>
      <p className="mt-2 font-serif text-3xl">{value}</p>
    </Link>
  );
}

const PAGE_SIZE = 5;

type DirectoryTab = "admins" | "coaches" | "players";

type DirectoryRow = { key: number; name: string; line: string; extra: string };

const directoryTitle: Record<DirectoryTab, string> = {
  admins: "Admins",
  coaches: "Coaches",
  players: "Players",
};

const directoryHref: Record<DirectoryTab, string> = {
  admins: "/admins",
  coaches: "/coaches",
  players: "/players",
};

function directoryRows(tab: DirectoryTab, admins: AcademyAdmin[], coaches: Coach[], players: Student[]): DirectoryRow[] {
  if (tab === "admins") {
    return admins.map((admin) => ({
      key: admin.admin_id,
      name: admin.name,
      line: admin.email || "No email",
      extra: admin.mobile || "No mobile",
    }));
  }
  if (tab === "coaches") {
    return coaches.map((coach) => ({
      key: coach.coach_id,
      name: coach.name,
      line: coach.email || "No email",
      extra: coach.mobile || "No mobile",
    }));
  }
  return [...players]
    .sort((a, b) => a.name.localeCompare(b.name))
    .map((player) => ({
      key: player.student_id,
      name: player.name,
      line: player.batch_name || "No batch",
      extra: player.bill_amount != null ? `${rupees(player.bill_amount)} · ${player.bill_status || player.fee_status}` : player.fee_status,
    }));
}

function DirectoryTabs({
  value,
  counts,
  onChange,
}: {
  value: DirectoryTab;
  counts: Record<DirectoryTab, number>;
  onChange: (tab: DirectoryTab) => void;
}) {
  const tabs: DirectoryTab[] = ["admins", "coaches", "players"];
  return (
    <div className="mt-6 flex flex-wrap gap-2" role="tablist" aria-label="Academy directories">
      {tabs.map((tab) => {
        const selected = tab === value;
        return (
          <button
            key={tab}
            type="button"
            role="tab"
            aria-selected={selected}
            onClick={() => onChange(tab)}
            className={`rounded-full px-4 py-2 text-sm font-semibold ${
              selected ? "bg-terracotta text-white" : "border border-line bg-card text-ink-text hover:border-terracotta"
            }`}
          >
            {directoryTitle[tab]}
            <span className={selected ? "text-white/80" : "text-muted"}> {counts[tab]}</span>
          </button>
        );
      })}
    </div>
  );
}

function Directory({
  title,
  href,
  rows,
  page,
  onPage,
}: {
  title: string;
  href: string;
  rows: DirectoryRow[];
  page: number;
  onPage: (page: number) => void;
}) {
  const pageCount = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
  const current = Math.min(page, pageCount);
  const visible = rows.slice((current - 1) * PAGE_SIZE, current * PAGE_SIZE);
  return (
    <section className="mt-4 rounded-2xl border border-line bg-card/80 p-4">
      <div className="flex items-center justify-between gap-3">
        <h2 className="font-serif text-2xl font-medium">{title}</h2>
        <Link href={href} className="text-sm font-semibold text-terracotta">
          Open
        </Link>
      </div>
      <ul className="mt-3 flex flex-col gap-3">
        {visible.map((row) => (
          <li key={row.key} className="border-t border-line pt-3 first:border-t-0 first:pt-0">
            <p className="font-semibold">{row.name}</p>
            <p className="text-sm text-muted">{row.line}</p>
            <p className="text-sm">{row.extra}</p>
          </li>
        ))}
        {rows.length === 0 ? <li className="text-sm text-muted">None in the database.</li> : null}
      </ul>
      <div className="mt-4 flex items-center justify-between gap-3 border-t border-line pt-3">
        <p className="text-sm text-muted">
          Page {current} of {pageCount}
        </p>
        <div className="flex gap-2">
          <button
            type="button"
            disabled={current <= 1}
            onClick={() => onPage(current - 1)}
            className="rounded-full border border-line px-3 py-1.5 text-sm font-semibold disabled:opacity-40"
          >
            Previous
          </button>
          <button
            type="button"
            disabled={current >= pageCount}
            onClick={() => onPage(current + 1)}
            className="rounded-full border border-line px-3 py-1.5 text-sm font-semibold disabled:opacity-40"
          >
            Next
          </button>
        </div>
      </div>
    </section>
  );
}
