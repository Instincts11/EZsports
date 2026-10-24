"use client";

export function AppTabs<T extends string>({
  tabs,
  value,
  onChange,
}: {
  tabs: readonly { id: T; label: string }[];
  value: T;
  onChange: (id: T) => void;
}) {
  return (
    <div className="flex gap-1 overflow-x-auto border-b border-line px-5">
      {tabs.map((tab) => {
        const selected = tab.id === value;
        return (
          <button
            key={tab.id}
            type="button"
            onClick={() => onChange(tab.id)}
            className={`shrink-0 border-b-2 px-3 py-2.5 text-sm font-semibold ${
              selected ? "border-terracotta text-ink-text" : "border-transparent text-muted hover:text-ink-text"
            }`}
          >
            {tab.label}
          </button>
        );
      })}
    </div>
  );
}
