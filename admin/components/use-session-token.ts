"use client";

import { useSyncExternalStore } from "react";
import { getToken } from "@/lib/session";

function subscribe(onStoreChange: () => void) {
  window.addEventListener("ezsports-session", onStoreChange);
  return () => window.removeEventListener("ezsports-session", onStoreChange);
}

export function useSessionToken(): string | null {
  return useSyncExternalStore(subscribe, getToken, () => null);
}
