import { Suspense } from "react";
import { AuthGate } from "@/components/auth-gate";
import { SessionDesk } from "../page";

export default function SessionGroupPage({ params }: { params: Promise<{ group: string }> }) {
  return (
    <Suspense fallback={<p className="px-5 py-6 text-sm text-muted">Loading session</p>}>
      <SessionGroup params={params} />
    </Suspense>
  );
}

async function SessionGroup({ params }: { params: Promise<{ group: string }> }) {
  const { group } = await params;
  return (
    <AuthGate allow="super_admin">
      <SessionDesk group={decodeURIComponent(group)} />
    </AuthGate>
  );
}
