"use client";

import { DateInput } from "@/components/date-input";

export function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-2xl border border-line bg-card/80 p-4 sm:p-5">
      <h3 className="font-serif text-xl font-medium">{title}</h3>
      <div className="mt-4 grid gap-4 sm:grid-cols-2">{children}</div>
    </section>
  );
}

export function Field({
  label,
  value,
  onChange,
  type = "text",
  readOnly = false,
  wide = false,
  multiline = false,
}: {
  label: string;
  value: string;
  onChange?: (value: string) => void;
  type?: string;
  readOnly?: boolean;
  wide?: boolean;
  multiline?: boolean;
}) {
  const className = `w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm outline-none focus:border-terracotta ${
    readOnly ? "text-muted" : "text-ink-text"
  }`;
  return (
    <label className={`block ${wide ? "sm:col-span-2" : ""}`}>
      <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">{label}</span>
      {multiline ? (
        <textarea
          value={value}
          readOnly={readOnly}
          rows={3}
          onChange={(event) => onChange?.(event.target.value)}
          className={className}
        />
      ) : type === "date" ? (
        <DateInput range={false} value={value} onChange={(next) => onChange?.(next)} className={className} />
      ) : (
        <input
          type={type}
          value={value}
          readOnly={readOnly}
          onChange={(event) => onChange?.(event.target.value)}
          className={className}
        />
      )}
    </label>
  );
}

export function SaveBar({
  pending,
  notice,
  error,
  label = "Save",
}: {
  pending: boolean;
  notice: string;
  error: string;
  label?: string;
}) {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <button
        type="submit"
        disabled={pending}
        className="rounded-xl bg-terracotta px-5 py-2.5 text-sm font-bold text-white hover:bg-terracotta-dark disabled:opacity-60"
      >
        {pending ? "Saving" : label}
      </button>
      {notice ? (
        <p className={`text-sm ${notice === "Saved" ? "text-success" : "text-muted"}`}>{notice}</p>
      ) : null}
      {error ? <p className="text-sm text-terracotta">{error}</p> : null}
    </div>
  );
}
