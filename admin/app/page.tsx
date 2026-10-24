"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { SignInForm } from "@/components/sign-in-form";
import { useSessionToken } from "@/components/use-session-token";
import { api } from "@/lib/api";
import { clearToken } from "@/lib/session";
import type { Me } from "@/lib/types";

export default function HomePage() {
  const router = useRouter();
  const token = useSessionToken();

  useEffect(() => {
    if (!token) return;
    let active = true;
    api<Me>("/auth/me")
      .then((me) => {
        if (!active) return;
        router.replace(me.role === "accountant" ? "/fees" : "/academy");
      })
      .catch(() => {
        if (active) clearToken();
      });
    return () => {
      active = false;
    };
  }, [router, token]);

  if (!token) return <SignInForm />;

  return (
    <div className="flex min-h-screen items-center justify-center bg-ink">
      <p className="text-xs font-bold tracking-[0.2em] text-terracotta">ID SPORTS</p>
    </div>
  );
}
