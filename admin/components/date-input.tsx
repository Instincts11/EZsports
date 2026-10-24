"use client";

import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";

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

function parseDay(value: string): Date | null {
  const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(value);
  if (!match) return null;
  return new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]));
}

function iso(value: Date) {
  const month = String(value.getMonth() + 1).padStart(2, "0");
  const day = String(value.getDate()).padStart(2, "0");
  return `${value.getFullYear()}-${month}-${day}`;
}

function shown(value: string) {
  const day = parseDay(value);
  if (!day) return value;
  const date = String(day.getDate()).padStart(2, "0");
  const month = String(day.getMonth() + 1).padStart(2, "0");
  return `${date}-${month}-${day.getFullYear()}`;
}

function same(a: Date, b: Date) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

export function DateInput({
  value,
  onChange,
  className,
  required = false,
  range = false,
}: {
  value: string;
  onChange: (value: string) => void;
  className?: string;
  required?: boolean;
  range?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [start, setStart] = useState<Date | null>(() => parseDay(value));
  const [end, setEnd] = useState<Date | null>(null);
  const [chosen, setChosen] = useState<{ start: Date; end: Date } | null>(null);
  const label =
    range && chosen && iso(chosen.start) === value
      ? `${shown(iso(chosen.start))} – ${shown(iso(chosen.end))}`
      : shown(value);

  function openPicker() {
    setStart(parseDay(value));
    setEnd(null);
    setOpen(true);
  }

  return (
    <span className="relative block">
      <button
        type="button"
        onClick={openPicker}
        className={`flex w-full items-center justify-between gap-3 text-left ${className ?? "rounded-xl border border-line bg-cream px-3 py-2 text-sm outline-none"}`}
      >
        <span className={label ? "text-ink-text" : "text-muted"}>{label || "dd-mm-yyyy"}</span>
        <CalendarIcon />
      </button>
      {required ? (
        <input
          value={value}
          required
          tabIndex={-1}
          aria-hidden="true"
          onChange={() => undefined}
          className="pointer-events-none absolute h-px w-px opacity-0"
        />
      ) : null}
      {open && range ? (
        <DatePopup
          start={start}
          end={end}
          onStart={setStart}
          onEnd={setEnd}
          onClose={() => {
            setStart(parseDay(value));
            setEnd(null);
            setOpen(false);
          }}
          onSubmit={() => {
            if (!start || !end) return;
            setChosen({ start, end });
            onChange(iso(start));
            setOpen(false);
          }}
        />
      ) : null}
      {open && !range ? (
        <SingleDatePopup
          value={value}
          onClose={() => setOpen(false)}
          onPick={(next) => {
            onChange(next);
            setOpen(false);
          }}
        />
      ) : null}
    </span>
  );
}

function SingleDatePopup({
  value,
  onClose,
  onPick,
}: {
  value: string;
  onClose: () => void;
  onPick: (value: string) => void;
}) {
  const today = new Date();
  const [picked, setPicked] = useState<Date | null>(() => parseDay(value));
  const opening = picked ?? today;
  const [month, setMonth] = useState(new Date(opening.getFullYear(), opening.getMonth(), 1));
  const firstYear = 1940;
  const lastYear = today.getFullYear();
  const years = Array.from({ length: lastYear - firstYear + 1 }, (_, index) => firstYear + index);
  const first = new Date(month.getFullYear(), month.getMonth(), 1);
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
  const leading = first.getDay();
  const cells = Array.from({ length: Math.ceil((leading + daysInMonth) / 7) * 7 }, (_, index) => {
    const dayNumber = index - leading + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) return null;
    return new Date(month.getFullYear(), month.getMonth(), dayNumber);
  });

  return createPortal(
    <div className="fixed inset-0 z-[80] flex items-center justify-center bg-black/70 p-4 max-[510px]:items-end max-[510px]:p-0" onClick={onClose}>
      <div
        className="date-card w-full max-w-[340px] rounded-2xl bg-white px-5 pt-5 pb-4 text-[#1C1C1C] shadow-[0_18px_50px_rgba(0,0,0,0.18)] max-[510px]:max-w-none max-[510px]:rounded-none max-[510px]:rounded-t-3xl max-[510px]:pb-6"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex items-center justify-center gap-2">
          <div className="flex items-center gap-2 text-[15px] font-extrabold tracking-[0.04em]">
            <span>{months[month.getMonth()].toUpperCase()}</span>
            <YearSelect
              value={month.getFullYear()}
              years={years}
              onChange={(year) => setMonth(new Date(year, month.getMonth(), 1))}
            />
          </div>
          <button
            type="button"
            onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))}
            className="px-1 text-lg leading-none text-[#1C1C1C]"
            aria-label="Previous month"
          >
            ‹
          </button>
          <button
            type="button"
            onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))}
            className="px-1 text-lg leading-none text-[#1C1C1C]"
            aria-label="Next month"
          >
            ›
          </button>
          <CalendarIcon />
        </div>
        <div className="mt-2 grid grid-cols-7 text-center text-[11px] font-semibold tracking-wide text-[#B0A8A0]">
          {weekdays.map((label) => (
            <span key={label}>{label}</span>
          ))}
        </div>
        <div className="mt-2 grid grid-cols-7">
          {cells.map((day, index) => {
            if (!day) return <span key={index} className="h-10" />;
            const on = picked ? same(day, picked) : false;
            return (
              <button key={iso(day)} type="button" onClick={() => setPicked(day)} className="relative h-10 text-sm">
                {on ? (
                  <span className="absolute top-1/2 left-1/2 h-[34px] w-[34px] -translate-x-1/2 -translate-y-1/2 rounded-full" style={{ background: highlight }} />
                ) : null}
                <span className={`relative font-medium ${on ? "font-bold text-white" : "text-[#2C2C2C]"}`}>{day.getDate()}</span>
              </button>
            );
          })}
        </div>
        <div className="mt-4 flex items-center justify-center gap-3">
          <button type="button" onClick={onClose} className="px-3 py-2 text-sm font-semibold text-[#9A9086]">
            Cancel
          </button>
          <button
            type="button"
            onClick={() => picked && onPick(iso(picked))}
            disabled={!picked}
            className="rounded-xl px-4 py-2 text-sm font-bold text-white disabled:opacity-40"
            style={{ background: highlight }}
          >
            Submit
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
}

function DatePopup({
  start,
  end,
  onStart,
  onEnd,
  onClose,
  onSubmit,
}: {
  start: Date | null;
  end: Date | null;
  onStart: (day: Date | null) => void;
  onEnd: (day: Date | null) => void;
  onClose: () => void;
  onSubmit: () => void;
}) {
  const today = new Date();
  const opening = start ?? today;
  const [month, setMonth] = useState(new Date(opening.getFullYear(), opening.getMonth(), 1));

  function pick(day: Date) {
    if (!start || end) {
      onStart(day);
      onEnd(null);
      return;
    }
    if (same(day, start)) return;
    if (day.getTime() < start.getTime()) {
      onEnd(start);
      onStart(day);
      return;
    }
    onEnd(day);
  }

  function marked(day: Date) {
    if (!start) return false;
    if (!end) return same(day, start);
    return day >= start && day <= end;
  }

  const first = new Date(month.getFullYear(), month.getMonth(), 1);
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
  const leading = first.getDay();
  const cells = Array.from({ length: Math.ceil((leading + daysInMonth) / 7) * 7 }, (_, index) => {
    const dayNumber = index - leading + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) return null;
    return new Date(month.getFullYear(), month.getMonth(), dayNumber);
  });

  return createPortal(
    <div className="fixed inset-0 z-[80] flex items-center justify-center bg-black/70 p-4 max-[510px]:items-end max-[510px]:p-0">
      <div className="date-card w-full max-w-[340px] rounded-2xl bg-white px-5 pt-5 pb-4 text-[#1C1C1C] shadow-[0_18px_50px_rgba(0,0,0,0.18)] max-[510px]:max-w-none max-[510px]:rounded-none max-[510px]:rounded-t-3xl max-[510px]:pb-6">
        <div className="flex items-center justify-center gap-2">
          <p className="text-[15px] font-extrabold tracking-[0.04em]">
            {months[month.getMonth()].toUpperCase()} {month.getFullYear()}
          </p>
          <button
            type="button"
            onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))}
            className="px-1 text-lg leading-none text-[#1C1C1C]"
            aria-label="Previous month"
          >
            ‹
          </button>
          <button
            type="button"
            onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))}
            className="px-1 text-lg leading-none text-[#1C1C1C]"
            aria-label="Next month"
          >
            ›
          </button>
          <CalendarIcon />
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
        <div className="mt-4 flex items-center justify-center gap-3">
          <button type="button" onClick={onClose} className="px-3 py-2 text-sm font-semibold text-[#9A9086]">
            Cancel
          </button>
          <button
            type="button"
            onClick={onSubmit}
            disabled={!start || !end}
            className="rounded-xl px-4 py-2 text-sm font-bold text-white disabled:opacity-40"
            style={{ background: highlight }}
          >
            Submit
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
}

function YearSelect({
  value,
  years,
  onChange,
}: {
  value: number;
  years: number[];
  onChange: (year: number) => void;
}) {
  const [open, setOpen] = useState(false);
  const list = useRef<HTMLUListElement>(null);
  const selected = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!open || !list.current || !selected.current) return;
    list.current.scrollTop = selected.current.offsetTop - list.current.clientHeight / 2 + selected.current.clientHeight / 2;
  }, [open]);

  return (
    <span className="relative">
      <button
        type="button"
        aria-label="Year"
        aria-haspopup="listbox"
        aria-expanded={open}
        onClick={() => setOpen(!open)}
        className="flex items-center gap-1 font-extrabold tracking-[0.04em] outline-none"
      >
        {value}
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" aria-hidden="true">
          <path d={open ? "M6 15l6-6 6 6" : "M6 9l6 6 6-6"} />
        </svg>
      </button>
      {open ? (
        <>
          <span className="fixed inset-0 z-10" onClick={() => setOpen(false)} />
          <ul
            ref={list}
            role="listbox"
            className="absolute top-full left-1/2 z-20 mt-2 max-h-48 w-24 -translate-x-1/2 overflow-y-auto rounded-xl border border-[#F3EBE3] bg-white py-1 shadow-[0_12px_30px_rgba(0,0,0,0.15)]"
          >
            {years.map((year) => {
              const on = year === value;
              return (
                <li key={year} role="option" aria-selected={on}>
                  <button
                    ref={on ? selected : undefined}
                    type="button"
                    onClick={() => {
                      onChange(year);
                      setOpen(false);
                    }}
                    className={`block w-full px-3 py-1.5 text-center text-sm ${on ? "font-bold text-white" : "font-medium text-[#2C2C2C] hover:bg-[#FBF5EF]"}`}
                    style={on ? { background: highlight } : undefined}
                  >
                    {year}
                  </button>
                </li>
              );
            })}
          </ul>
        </>
      ) : null}
    </span>
  );
}

function CalendarIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={highlight} strokeWidth="1.8" aria-hidden="true">
      <rect x="3.5" y="5" width="17" height="15.5" rx="2" />
      <path d="M8 3.5v3M16 3.5v3M3.5 9.5h17" />
    </svg>
  );
}
