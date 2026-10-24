"use client";

import { initials } from "@/lib/format";

export type PersonCard = {
  id: number;
  name: string;
  mobile: string;
  detail: string;
  accent: "admin" | "coach" | "player";
};

export function PersonList({
  title,
  summary,
  query,
  onQuery,
  people,
  selectedId,
  onSelect,
  hiddenOnNarrow,
  loading,
  error,
  emptyLabel,
  addLabel,
  onAdd,
}: {
  title: string;
  summary: string;
  query: string;
  onQuery: (value: string) => void;
  people: PersonCard[];
  selectedId: number | null;
  onSelect: (id: number) => void;
  hiddenOnNarrow: boolean;
  loading: boolean;
  error: string;
  emptyLabel: string;
  addLabel?: string;
  onAdd?: () => void;
}) {
  return (
    <section
      className={`person-list ${hiddenOnNarrow ? "hidden lg:flex" : "flex"} w-full shrink-0 flex-col border-line lg:w-[340px] lg:border-r`}
    >
      <div className="border-b border-line px-4 py-4">
        <div className="flex items-start justify-between gap-3">
          <h1 className="font-serif text-3xl font-medium text-ink-text">{title}</h1>
          {onAdd && addLabel ? (
            <button
              type="button"
              onClick={onAdd}
              className="rounded-xl bg-terracotta px-3 py-2 text-sm font-bold text-white hover:bg-terracotta-dark"
            >
              {addLabel}
            </button>
          ) : null}
        </div>
        <p className="mt-1 text-sm text-muted">{summary}</p>
        <input
          value={query}
          onChange={(event) => onQuery(event.target.value)}
          placeholder="Search name or mobile"
          className="mt-4 w-full rounded-xl border border-line bg-card px-3 py-2 text-sm outline-none focus:border-terracotta"
        />
      </div>
      <div className="flex flex-1 flex-col gap-2 overflow-y-auto px-4 py-4">
        {error ? <p className="text-sm text-terracotta">{error}</p> : null}
        {!loading && !error && people.length === 0 ? (
          <p className="text-sm text-muted">{emptyLabel}</p>
        ) : null}
        {people.map((person) => {
          const selected = person.id === selectedId;
          return (
            <button
              key={person.id}
              type="button"
              onClick={() => onSelect(person.id)}
              className={`rounded-2xl border px-3 py-3 text-left ${
                selected ? "border-terracotta bg-card" : "border-line bg-card/70 hover:bg-card"
              }`}
            >
              <span className="flex gap-3">
                <span
                  className={`person-avatar mt-0.5 flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-sm font-bold text-white ${
                      person.accent === "player" ? "bg-teal" : person.accent === "admin" ? "bg-ink" : "bg-terracotta"
                  }`}
                >
                  {initials(person.name)}
                </span>
                <span className="min-w-0">
                  <span className="block truncate font-serif text-lg leading-tight">{person.name}</span>
                  <span className="block truncate text-sm text-muted">{person.mobile || "No mobile"}</span>
                  <span className="block truncate text-sm">{person.detail}</span>
                </span>
              </span>
            </button>
          );
        })}
      </div>
    </section>
  );
}
