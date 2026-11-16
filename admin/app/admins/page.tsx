"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { Field, SaveBar, Section } from "@/components/fields";
import { PersonList } from "@/components/person-list";
import { ApiError, api } from "@/lib/api";
import { changedText } from "@/lib/patch";
import type { AcademyAdmin } from "@/lib/types";

const keys = ["name", "email", "mobile", "academy_name", "password"] as const;
type AdminField = (typeof keys)[number];
type AdminForm = Record<AdminField, string>;

function toForm(admin: AcademyAdmin): AdminForm {
  return {
    name: admin.name ?? "",
    email: admin.email ?? "",
    mobile: admin.mobile ?? "",
    academy_name: admin.academy_name ?? "",
    password: "",
  };
}

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
            <AdminEditor
              key={selected.admin_id}
              admin={selected}
              onBack={() => setSelectedId(null)}
              onSaved={(saved) => {
                setAdmins((rows) => rows.map((row) => (row.admin_id === saved.admin_id ? saved : row)));
              }}
            />
          ) : (
            <p className="m-auto max-w-sm px-6 text-center text-sm text-muted">
              Select an admin to update the account stored in the database.
            </p>
          )}
        </section>
      </div>
    </DeskShell>
  );
}

function AdminEditor({
  admin,
  onBack,
  onSaved,
}: {
  admin: AcademyAdmin;
  onBack: () => void;
  onSaved: (admin: AcademyAdmin) => void;
}) {
  const [baseline, setBaseline] = useState(admin);
  const [form, setForm] = useState<AdminForm>(() => toForm(admin));
  const [pending, setPending] = useState(false);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");

  function setField(key: AdminField, value: string) {
    setForm((current) => ({ ...current, [key]: value }));
    setNotice("");
    setError("");
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    const { patch, message } = changedText(
      toForm(baseline),
      form,
      keys,
      ["name", "email", "academy_name"],
      "Name, email, and academy are required.",
    );
    if (message) {
      setError(message);
      setNotice("");
      return;
    }
    if (Object.keys(patch).length === 0) {
      setNotice("No changes to save.");
      setError("");
      return;
    }
    setPending(true);
    setError("");
    setNotice("");
    try {
      const saved = await api<AcademyAdmin>(`/admins/${admin.admin_id}`, {
        method: "PATCH",
        body: JSON.stringify(patch),
      });
      setBaseline(saved);
      setForm(toForm(saved));
      setNotice("Saved");
      onSaved(saved);
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The admin could not be saved.");
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="flex min-h-0 flex-1 flex-col">
      <div className="flex items-center gap-3 border-b border-line px-5 py-4">
        <button type="button" onClick={onBack} className="text-sm font-semibold text-terracotta lg:hidden">
          Back
        </button>
        <div>
          <h2 className="font-serif text-3xl font-medium">{baseline.name}</h2>
          <p className="text-sm text-muted">Admin account</p>
        </div>
      </div>
      <form onSubmit={onSubmit} className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
        <Section title="Account">
          <Field label="Name" value={form.name} onChange={(value) => setField("name", value)} />
          <Field label="Mobile" value={form.mobile} onChange={(value) => setField("mobile", value)} />
          <Field label="Email" type="email" value={form.email} onChange={(value) => setField("email", value)} />
          <Field
            label="New password"
            type="password"
            value={form.password}
            onChange={(value) => setField("password", value)}
          />
          <Field
            label="Academy"
            value={form.academy_name}
            onChange={(value) => setField("academy_name", value)}
            wide
          />
        </Section>
        <SaveBar pending={pending} notice={notice} error={error} label="Save admin" />
      </form>
    </div>
  );
}
