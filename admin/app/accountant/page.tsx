"use client";

import { FormEvent, useEffect, useState } from "react";
import { AuthGate } from "@/components/auth-gate";
import { DeskShell } from "@/components/desk-shell";
import { ApiError, api } from "@/lib/api";
import type { Accountant } from "@/lib/types";

const fieldClass =
  "w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm text-ink-text outline-none focus:border-terracotta";
const buttonClass = "rounded-xl bg-terracotta px-4 py-2 text-sm font-bold text-white disabled:opacity-60";

export default function AccountantPage() {
  return (
    <AuthGate allow="super_admin">
      <AccountantDesk />
    </AuthGate>
  );
}

function AccountantDesk() {
  const [accountant, setAccountant] = useState<Accountant | null>(null);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(true);
  const [pending, setPending] = useState(false);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    api<Accountant[]>("/accountants")
      .then((rows) => {
        const current = rows[0] ?? null;
        setAccountant(current);
        setName(current?.name ?? "");
        setEmail(current?.email ?? "");
      })
      .catch((cause: unknown) => {
        setError(cause instanceof ApiError ? cause.message : "The accountant could not be loaded.");
      })
      .finally(() => setLoading(false));
  }, []);

  async function create(event: FormEvent) {
    event.preventDefault();
    setPending(true);
    setError("");
    setNotice("");
    try {
      const saved = await api<Accountant>("/accountants", {
        method: "POST",
        body: JSON.stringify({ name: name.trim(), email: email.trim(), password }),
      });
      setAccountant(saved);
      setPassword("");
      setNotice("Saved");
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The accountant could not be added.");
    } finally {
      setPending(false);
    }
  }

  async function update(event: FormEvent) {
    event.preventDefault();
    if (!accountant) return;
    const body: Record<string, string> = {};
    if (name.trim() && name.trim() !== accountant.name) body.name = name.trim();
    if (email.trim() && email.trim() !== (accountant.email ?? "")) body.email = email.trim();
    if (password) body.password = password;
    if (Object.keys(body).length === 0) {
      setNotice("No changes to save.");
      setError("");
      return;
    }
    setPending(true);
    setError("");
    setNotice("");
    try {
      const saved = await api<Accountant>(`/accountants/${accountant.accountant_id}`, {
        method: "PATCH",
        body: JSON.stringify(body),
      });
      setAccountant(saved);
      setName(saved.name);
      setEmail(saved.email ?? "");
      setPassword("");
      setNotice("Saved");
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The accountant could not be saved.");
    } finally {
      setPending(false);
    }
  }

  async function remove() {
    if (!accountant) return;
    if (!window.confirm(`Delete ${accountant.name}?`)) return;
    setPending(true);
    setError("");
    setNotice("");
    try {
      await api(`/accountants/${accountant.accountant_id}`, { method: "DELETE" });
      setAccountant(null);
      setName("");
      setEmail("");
      setPassword("");
      setNotice("Deleted");
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The accountant could not be deleted.");
    } finally {
      setPending(false);
    }
  }

  return (
    <DeskShell active="accountant" mode="admin">
      <div className="flex-1 overflow-y-auto px-5 py-6">
        <p className="text-xs font-bold tracking-[0.18em] text-terracotta">ACADEMY SETUP</p>
        <h1 className="mt-2 font-serif text-4xl font-medium">Accountant</h1>
        <p className="mt-2 max-w-xl text-sm text-muted">One accountant can sign in and manage fees.</p>
        {loading ? <p className="mt-6 text-sm text-muted">Loading</p> : null}
        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}
        {notice ? <p className="mt-4 text-sm text-success">{notice}</p> : null}

        {!loading && !accountant ? (
          <form onSubmit={create} className="mt-6 grid max-w-xl gap-3 rounded-2xl border border-line bg-card p-4 min-[1300px]:max-w-none">
            <p className="font-serif text-2xl">Add accountant</p>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Name</span>
              <input required value={name} onChange={(event) => setName(event.target.value)} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Email</span>
              <input
                required
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                className={fieldClass}
              />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Password</span>
              <input
                required
                type="password"
                minLength={6}
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                className={fieldClass}
              />
            </label>
            <button type="submit" disabled={pending} className={buttonClass}>
              {pending ? "Saving" : "Add accountant"}
            </button>
          </form>
        ) : null}

        {accountant ? (
          <form onSubmit={update} className="mt-6 grid max-w-xl gap-3 rounded-2xl border border-line bg-card p-4 min-[1300px]:max-w-none">
            <p className="font-serif text-2xl">{accountant.name}</p>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Name</span>
              <input required value={name} onChange={(event) => setName(event.target.value)} className={fieldClass} />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Email</span>
              <input
                required
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                className={fieldClass}
              />
            </label>
            <label className="block">
              <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">New password</span>
              <input
                type="password"
                minLength={6}
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                className={fieldClass}
                placeholder="Leave blank to keep the current password"
              />
            </label>
            <div className="flex items-center gap-3">
              <button type="submit" disabled={pending} className={buttonClass}>
                {pending ? "Saving" : "Update"}
              </button>
              <button type="button" onClick={remove} className="text-sm font-semibold text-terracotta">
                Delete
              </button>
            </div>
          </form>
        ) : null}
      </div>
    </DeskShell>
  );
}
