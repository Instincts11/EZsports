"use client";

import { useEffect, useState } from "react";
import { ApiError, api } from "@/lib/api";
import type { Coach, Leave } from "@/lib/types";

function pretty(value: string) {
  const [year, month, day] = value.slice(0, 10).split("-");
  if (!year || !month || !day) return value;
  return `${day}-${month}-${year}`;
}

export function LeaveNotifications() {
  const [leaves, setLeaves] = useState<Leave[]>([]);
  const [names, setNames] = useState<Record<number, string>>({});
  const [open, setOpen] = useState(false);
  const [error, setError] = useState("");

  function load() {
    Promise.all([api<Leave[]>("/leaves"), api<Coach[]>("/coaches")])
      .then(([nextLeaves, coaches]) => {
        setLeaves(nextLeaves);
        setNames(Object.fromEntries(coaches.map((coach) => [coach.coach_id, coach.name])));
        setError("");
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Leave requests could not be loaded.");
      });
  }

  useEffect(() => {
    load();
  }, []);

  async function setStatus(leave: Leave, status: "approved" | "rejected") {
    try {
      const saved = await api<Leave>(`/leaves/${leave.leave_id}`, {
        method: "PATCH",
        body: JSON.stringify({ status }),
      });
      setLeaves((rows) => rows.map((row) => (row.leave_id === saved.leave_id ? saved : row)));
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The leave could not be updated.");
    }
  }

  const ordered = [...leaves].sort((left, right) => {
    if (left.status === "pending" && right.status !== "pending") return -1;
    if (right.status === "pending" && left.status !== "pending") return 1;
    return right.from_date.localeCompare(left.from_date);
  });
  const pending = leaves.filter((leave) => leave.status === "pending").length;

  return (
    <div className="relative">
      <button
        type="button"
        aria-label="Notifications"
        aria-expanded={open}
        onClick={() => {
          setOpen((current) => !current);
          load();
        }}
        className="relative flex items-center gap-2 rounded-full border border-line bg-card px-3 py-1.5 text-sm font-semibold"
      >
        <BellIcon />
        Notifications
        {pending > 0 ? (
          <span className="rounded-full bg-terracotta px-1.5 text-xs font-bold text-white">{pending}</span>
        ) : null}
      </button>
      {open ? (
        <div className="absolute right-0 z-40 mt-2 w-80 max-h-96 overflow-y-auto rounded-2xl border border-line bg-card p-3 shadow-lg">
          <p className="font-serif text-lg">Leave requests</p>
          {error ? <p className="mt-2 text-sm text-terracotta">{error}</p> : null}
          {ordered.length === 0 ? <p className="mt-3 text-sm text-muted">No leave requests.</p> : null}
          <ul className="mt-2 flex flex-col gap-3">
            {ordered.map((leave) => (
              <li key={leave.leave_id} className="border-t border-line pt-3 first:border-t-0 first:pt-0">
                <p className="text-sm font-semibold">{names[leave.coach_id] || "Coach"}</p>
                <p className="text-sm text-muted">
                  {pretty(leave.from_date)} – {pretty(leave.to_date)}
                </p>
                <p className="text-sm">{leave.reason}</p>
                <p className="mt-1 text-xs font-bold tracking-wide text-muted uppercase">{leave.status}</p>
                {leave.status === "pending" ? (
                  <div className="mt-2 flex gap-3">
                    <button type="button" onClick={() => setStatus(leave, "approved")} className="text-sm font-semibold text-terracotta">
                      Approve
                    </button>
                    <button type="button" onClick={() => setStatus(leave, "rejected")} className="text-sm font-semibold text-muted">
                      Reject
                    </button>
                  </div>
                ) : null}
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </div>
  );
}

function BellIcon() {
  return (
    <svg viewBox="0 0 24 24" className="size-4" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
      <path d="M6 9a6 6 0 1 1 12 0c0 7 3 7 3 7H3s3 0 3-7" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M10 19a2 2 0 0 0 4 0" strokeLinecap="round" />
    </svg>
  );
}
