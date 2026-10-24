"use client";

import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ApiError, api } from "@/lib/api";
import type { Academy } from "@/lib/types";

const highlight = "#F15B5B";
const weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
const months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

function dayOf(value: string | null): Date | null {
  if (!value) return null;
  const [year, month, day] = value.slice(0, 10).split("-").map(Number);
  if (!year || !month || !day) return null;
  return new Date(year, month - 1, day);
}

function iso(value: Date) {
  const month = String(value.getMonth() + 1).padStart(2, "0");
  const day = String(value.getDate()).padStart(2, "0");
  return `${value.getFullYear()}-${month}-${day}`;
}

function same(a: Date, b: Date) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

export function DateRangeButton({ onOpen }: { onOpen?: () => void }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button
        type="button"
        onClick={() => {
          onOpen?.();
          setOpen(true);
        }}
        title="Dates"
        aria-label="Dates"
        className={`flex size-10 w-auto items-center justify-center gap-0 rounded-xl px-0 py-2 text-left text-sm font-semibold group-data-[expanded=true]/rail:h-auto group-data-[expanded=true]/rail:w-auto group-data-[expanded=true]/rail:justify-start group-data-[expanded=true]/rail:gap-3 group-data-[expanded=true]/rail:px-3 min-[1025px]:h-auto min-[1025px]:w-auto min-[1025px]:justify-start min-[1025px]:gap-3 min-[1025px]:px-3 ${
          open ? "bg-terracotta text-white" : "text-cream-text/80 hover:bg-white/5"
        }`}
      >
        <span className="inline shrink-0">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
            <rect x="3.5" y="5" width="17" height="15.5" rx="2" />
            <path d="M8 3.5v3M16 3.5v3M3.5 10h17" />
            <path d="M8 15h5" />
          </svg>
        </span>
        <span className="hidden group-data-[expanded=true]/rail:inline min-[1025px]:inline">Dates</span>
      </button>
      {open ? <DateRangePopup onClose={() => setOpen(false)} /> : null}
    </>
  );
}

function DateRangePopup({ onClose }: { onClose: () => void }) {
  const today = new Date();
  const [month, setMonth] = useState(new Date(today.getFullYear(), today.getMonth(), 1));
  const [start, setStart] = useState<Date | null>(null);
  const [end, setEnd] = useState<Date | null>(null);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  const [mounted, setMounted] = useState(false);
  const picked = useRef(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    api<Academy>("/academy")
      .then((academy) => {
        if (picked.current) return;
        const nextStart = dayOf(academy.range_start);
        const nextEnd = dayOf(academy.range_end);
        setStart(nextStart);
        setEnd(nextEnd);
        if (nextStart) setMonth(new Date(nextStart.getFullYear(), nextStart.getMonth(), 1));
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "The dates could not be loaded.");
      });
  }, []);

  async function submit() {
    if (!start || !end) return;
    setPending(true);
    setError("");
    try {
      await api("/academy", {
        method: "PATCH",
        body: JSON.stringify({ range_start: iso(start), range_end: iso(end) }),
      });
      onClose();
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The dates could not be saved.");
      setPending(false);
    }
  }

  function pick(day: Date) {
    picked.current = true;
    setError("");
    if (!start || end) {
      setStart(day);
      setEnd(null);
      return;
    }
    if (same(day, start)) return;
    const nextStart = day.getTime() < start.getTime() ? day : start;
    const nextEnd = day.getTime() < start.getTime() ? start : day;
    setStart(nextStart);
    setEnd(nextEnd);
  }

  const first = new Date(month.getFullYear(), month.getMonth(), 1);
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
  const leading = first.getDay();
  const cells = Array.from({ length: Math.ceil((leading + daysInMonth) / 7) * 7 }, (_, index) => {
    const dayNumber = index - leading + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) return null;
    return new Date(month.getFullYear(), month.getMonth(), dayNumber);
  });

  function marked(day: Date) {
    if (!start) return false;
    if (!end) return same(day, start);
    return day >= start && day <= end;
  }

  if (!mounted) return null;

  return createPortal(
    <div className="fixed inset-0 z-[80] flex items-center justify-center bg-black/70 p-4 max-[510px]:items-end max-[510px]:p-0">
      <div
        className="date-card w-full max-w-[340px] rounded-2xl bg-white px-5 pt-5 pb-4 text-[#1C1C1C] shadow-[0_18px_50px_rgba(0,0,0,0.18)] max-[510px]:max-w-none max-[510px]:rounded-none max-[510px]:rounded-t-3xl max-[510px]:pb-6"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex items-center">
          <p className="flex-1 text-[15px] font-extrabold tracking-[0.04em]">
            {months[month.getMonth()].toUpperCase()} {month.getFullYear()}
          </p>
          <button type="button" onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))} className="px-1 text-lg leading-none text-[#1C1C1C]" aria-label="Previous month">
            ‹
          </button>
          <button type="button" onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))} className="px-1 text-lg leading-none text-[#1C1C1C]" aria-label="Next month">
            ›
          </button>
          <CalendarIcon color={highlight} />
        </div>
        <div className="mt-2 grid grid-cols-7 text-center text-[11px] font-semibold tracking-wide text-[#B0A8A0]">
          {weekdays.map((label) => (
            <span key={label}>{label}</span>
          ))}
        </div>
        <div className="mt-2 grid grid-cols-7">
          {cells.map((day, index) => {
            if (!day) return <span key={index} className="h-10" />;
            const on = marked(day);
            const previous = index % 7 !== 0 && cells[index - 1] ? marked(cells[index - 1]!) : false;
            const next = index % 7 !== 6 && cells[index + 1] ? marked(cells[index + 1]!) : false;
            const alone = on && !previous && !next;
            return (
              <button key={iso(day)} type="button" onClick={() => pick(day)} className="relative h-10 text-sm">
                {alone ? (
                  <span className="absolute top-1/2 left-1/2 h-[34px] w-[34px] -translate-x-1/2 -translate-y-1/2 rounded-full" style={{ background: highlight }} />
                ) : null}
                {on && !alone ? (
                  <span
                    className="absolute inset-x-0 top-[3px] bottom-[3px]"
                    style={{
                      background: highlight,
                      borderTopLeftRadius: previous ? 0 : 18,
                      borderBottomLeftRadius: previous ? 0 : 18,
                      borderTopRightRadius: next ? 0 : 18,
                      borderBottomRightRadius: next ? 0 : 18,
                    }}
                  />
                ) : null}
                <span className={`relative font-medium ${on ? "font-bold text-white" : "text-[#2C2C2C]"}`}>{day.getDate()}</span>
              </button>
            );
          })}
        </div>
        <div className="mt-4 grid grid-cols-2 gap-3 border-t border-[#F3EBE3] pt-3">
          <div>
            <p className="text-[11px] font-semibold tracking-wide text-[#B0A8A0]">START</p>
            <p className="mt-1 text-sm font-bold">{start ? `${String(start.getDate()).padStart(2, "0")}-${String(start.getMonth() + 1).padStart(2, "0")}-${start.getFullYear()}` : "Select"}</p>
          </div>
          <div>
            <p className="text-[11px] font-semibold tracking-wide text-[#B0A8A0]">END</p>
            <p className="mt-1 text-sm font-bold">{end ? `${String(end.getDate()).padStart(2, "0")}-${String(end.getMonth() + 1).padStart(2, "0")}-${end.getFullYear()}` : "Select"}</p>
          </div>
        </div>
        {error ? <p className="mt-2 text-sm text-terracotta">{error}</p> : null}
        <div className="mt-4 flex items-center justify-center gap-3">
          <button type="button" onClick={onClose} className="px-3 py-2 text-sm font-semibold text-[#9A9086]">
            Cancel
          </button>
          <button
            type="button"
            onClick={() => void submit()}
            disabled={!start || !end || pending}
            className="rounded-xl px-4 py-2 text-sm font-bold text-white disabled:opacity-40"
            style={{ background: highlight }}
          >
            {pending ? "Saving" : "Submit"}
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
}

function CalendarIcon({ color = "currentColor" }: { color?: string }) {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" aria-hidden="true">
      <rect x="3.5" y="5" width="17" height="15.5" rx="2" />
      <path d="M8 3.5v3M16 3.5v3M3.5 9.5h17" />
    </svg>
  );
}
