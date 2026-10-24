"use client";

import { useEffect, useMemo, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { Field, Section } from "@/components/fields";
import { PersonList } from "@/components/person-list";
import { ApiError, api } from "@/lib/api";
import type { AcademyAdmin } from "@/lib/types";

export default function AdminsPage() {
  return (
    <AuthGate allow="super_admin">
      <AdminDesk />
    </AuthGate>
  );
}

function AdminDesk() {
  const [admins, setAdmins] = useState<AcademyAdmin[]>([]);
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    api<AcademyAdmin[]>("/admins")
      .then(setAdmins)
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "Admins could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  const visible = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return admins.filter((admin) => {
      if (!needle) return true;
      return `${admin.name} ${admin.email ?? ""} ${admin.mobile ?? ""}`.toLowerCase().includes(needle);
    });
  }, [admins, query]);

  const selected = admins.find((admin) => admin.admin_id === selectedId) ?? null;

  return (
    <DeskShell active="admins" mode="admin">
      <div className="flex min-h-0 flex-1">
        <PersonList
          title="Admins"
          summary={loading ? "Loading" : `${visible.length} ${visible.length === 1 ? "admin" : "admins"}`}
          query={query}
          onQuery={setQuery}
          people={visible.map((admin) => ({
            id: admin.admin_id,
            name: admin.name,
            mobile: admin.mobile || "",
            detail: admin.email || "No email",
            accent: "admin",
          }))}
          selectedId={selectedId}
          onSelect={setSelectedId}
          hiddenOnNarrow={selected !== null}
          loading={loading}
          error={error}
          emptyLabel={query.trim() ? "No one matches that search." : "No admins yet."}
        />
        <section className={`${selected ? "flex" : "hidden lg:flex"} min-w-0 flex-1 flex-col`}>
          {selected ? (
            <div className="flex min-h-0 flex-1 flex-col">
              <div className="flex items-center gap-3 border-b border-line px-5 py-4">
                <button
                  type="button"
                  onClick={() => setSelectedId(null)}
                  className="text-sm font-semibold text-terracotta lg:hidden"
                >
                  Back
                </button>
                <div>
                  <h2 className="font-serif text-3xl font-medium">{selected.name}</h2>
                  <p className="text-sm text-muted">Admin account</p>
                </div>
              </div>
              <div className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
                <Section title="Account">
                  <Field label="Name" value={selected.name} readOnly />
                  <Field label="Email" value={selected.email || ""} readOnly />
                  <Field label="Mobile" value={selected.mobile || ""} readOnly />
                  <Field label="Academy" value={selected.academy_name || ""} readOnly wide />
                </Section>
              </div>
            </div>
          ) : (
            <p className="m-auto max-w-sm px-6 text-center text-sm text-muted">
              Select an admin to see the account stored in the database.
            </p>
          )}
        </section>
      </div>
    </DeskShell>
  );
}
