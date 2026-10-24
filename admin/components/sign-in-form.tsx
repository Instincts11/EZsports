"use client";

import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";
import { ApiError, api } from "@/lib/api";
import { setToken } from "@/lib/session";
import type { TokenResponse } from "@/lib/types";

export function SignInForm() {
  const router = useRouter();
  const [error, setError] = useState("");
  const [pending, setPending] = useState(false);

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const identifier = String(form.get("email") ?? "").trim();
    const password = String(form.get("password") ?? "");
    setError("");
    setPending(true);
    try {
      const result = await api<TokenResponse>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ identifier, password }),
      });
      if (result.role === "super_admin") {
        setToken(result.access_token);
        router.replace("/academy");
        return;
      }
      if (result.role === "accountant") {
        setToken(result.access_token);
        router.replace("/fees");
        return;
      }
      setError("Sign in with the super admin or accountant account.");
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "Sign-in failed.");
    } finally {
      setPending(false);
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-ink px-4">
      <form
        onSubmit={onSubmit}
        className="w-full max-w-md rounded-3xl bg-cream px-8 py-10 shadow-[0_24px_80px_rgba(0,0,0,0.35)]"
      >
        <p className="text-xs font-bold tracking-[0.2em] text-terracotta">ID SPORTS</p>
        <h1 className="mt-3 font-serif text-4xl font-medium text-ink-text">Academy desk</h1>
        <p className="mt-2 text-sm text-muted">Super admin updates people. Accountant updates fees.</p>

        <label className="mt-8 block">
          <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Email</span>
          <input
            name="email"
            type="email"
            autoComplete="email"
            required
            placeholder="name@idsports.com"
            className="w-full rounded-xl border border-line bg-card px-3 py-2.5 text-sm outline-none focus:border-terracotta"
          />
        </label>
        <label className="mt-4 block">
          <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Password</span>
          <input
            name="password"
            type="password"
            autoComplete="current-password"
            required
            className="w-full rounded-xl border border-line bg-card px-3 py-2.5 text-sm outline-none focus:border-terracotta"
          />
        </label>

        {error ? <p className="mt-4 text-sm text-terracotta">{error}</p> : null}

        <button
          type="submit"
          disabled={pending}
          className="mt-6 w-full rounded-xl bg-terracotta px-4 py-3 text-sm font-bold text-white hover:bg-terracotta-dark disabled:opacity-60"
        >
          {pending ? "Signing in" : "Sign in"}
        </button>
      </form>
    </main>
  );
}
