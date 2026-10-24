"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useSessionToken } from "@/components/use-session-token";
import { api } from "@/lib/api";
import type { Me } from "@/lib/types";

export function AuthGate({
  allow,
  children,
}: {
  allow: "super_admin" | "accountant";
  children: React.ReactNode;
}) {
  const router = useRouter();
  const token = useSessionToken();
  const [role, setRole] = useState<string | null>(null);

  useEffect(() => {
    if (!token) {
      router.replace("/");
      return;
    }
    let active = true;
    api<Me>("/auth/me")
      .then((me) => {
        if (!active) return;
        setRole(me.role);
        if (me.role !== allow) {
          router.replace(me.role === "accountant" ? "/fees" : "/academy");
        }
      })
      .catch(() => {
        if (active) router.replace("/");
      });
    return () => {
      active = false;
    };
  }, [allow, router, token]);

  if (!token || role !== allow) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-ink">
        <p className="text-xs font-bold tracking-[0.2em] text-terracotta">ID SPORTS</p>
      </div>
    );
  }

  return children;
}
