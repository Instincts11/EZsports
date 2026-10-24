"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { DateRangeButton } from "@/components/date-range-popup";
import { api } from "@/lib/api";
import { clearToken } from "@/lib/session";
import type { Me } from "@/lib/types";

let railExpanded = false;
let phoneMenuOpen = true;

export function DeskShell({
  active,
  mode,
  children,
}: {
  active: "academy" | "admins" | "coaches" | "players" | "batches" | "sessions" | "accountant" | "fees";
  mode: "admin" | "accountant";
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [academy, setAcademy] = useState("");
  const [email, setEmail] = useState("");
  const [expanded, setExpanded] = useState(railExpanded);
  const [narrow, setNarrow] = useState(false);
  const [narrowOpen, setNarrowOpen] = useState(phoneMenuOpen);
  const labelsOpen = narrow ? narrowOpen : expanded;

  useEffect(() => {
    const query = window.matchMedia("(max-width: 600px)");
    let wasNarrow = query.matches;
    const apply = () => {
      const matches = query.matches;
      if (matches && !wasNarrow) phoneMenuOpen = true;
      wasNarrow = matches;
      setNarrow(matches);
      setNarrowOpen(phoneMenuOpen);
    };
    apply();
    query.addEventListener("change", apply);
    return () => query.removeEventListener("change", apply);
  }, []);

  function chooseLink() {
    if (window.matchMedia("(max-width: 600px)").matches) {
      phoneMenuOpen = false;
      setNarrowOpen(false);
      return;
    }
    railExpanded = true;
    setExpanded(true);
  }

  function toggleRail() {
    if (narrow) {
      setNarrowOpen((open) => {
        phoneMenuOpen = !open;
        return !open;
      });
      return;
    }
    setExpanded((open) => {
      railExpanded = !open;
      return !open;
    });
  }

  function showContent() {
    phoneMenuOpen = false;
    setNarrowOpen(false);
  }

  useEffect(() => {
    api<Me>("/auth/me")
      .then((me) => {
        setAcademy(me.academy_name || "Academy");
        setEmail(me.email);
      })
      .catch(() => {
        router.replace("/");
      });
  }, [router]);

  function signOut() {
    clearToken();
    router.replace("/");
  }

  return (
    <div data-expanded={labelsOpen ? "true" : "false"} className="desk group/rail relative flex h-screen flex-row bg-cream">
      {narrow && narrowOpen ? (
        <button type="button" aria-label="Close sidebar" onClick={showContent} className="absolute inset-0 z-20 bg-[#a3a3a3]" />
      ) : null}
      <aside
        onClick={() => {
          if (narrow && narrowOpen) showContent();
        }}
        className={`desk-rail relative z-30 flex shrink-0 flex-col gap-2 overflow-x-hidden overflow-y-auto bg-rail text-cream-text group-data-[expanded=true]/rail:w-56 group-data-[expanded=true]/rail:items-stretch group-data-[expanded=true]/rail:px-5 group-data-[expanded=true]/rail:py-6 min-[1025px]:h-full min-[1025px]:w-56 min-[1025px]:items-stretch min-[1025px]:overflow-visible min-[1025px]:px-5 min-[1025px]:py-6 ${
          narrow && narrowOpen
            ? "h-full w-52 px-4 py-4"
            : "h-full w-16 items-center px-2 py-4"
        }`}
      >
        <div className="flex w-full flex-col items-center justify-center gap-2 group-data-[expanded=true]/rail:flex-row group-data-[expanded=true]/rail:justify-between min-[1025px]:flex-row min-[1025px]:justify-start">
          <div className="text-center group-data-[expanded=true]/rail:text-left min-[1025px]:text-left">
            <p className="hidden text-xs font-bold tracking-[0.2em] text-terracotta group-data-[expanded=true]/rail:block min-[1025px]:block">ID SPORTS</p>
            <span className="grid size-10 place-items-center text-terracotta group-data-[expanded=true]/rail:hidden min-[1025px]:hidden" aria-hidden="true">
              <MarkIcon />
            </span>
            {academy ? <p className="mt-1 hidden text-sm text-muted group-data-[expanded=true]/rail:block min-[1025px]:block">{academy}</p> : null}
          </div>
          <button
            type="button"
            onClick={toggleRail}
            aria-label={labelsOpen ? "Close sidebar" : "Open sidebar"}
            title={labelsOpen ? "Close sidebar" : "Open sidebar"}
            className="flex size-10 items-center justify-center rounded-xl text-cream-text/80 hover:bg-white/5 min-[1025px]:hidden"
          >
            {labelsOpen ? <CloseIcon /> : <SidebarIcon />}
          </button>
        </div>
        <nav className="mt-6 flex w-full flex-col items-center gap-1 group-data-[expanded=true]/rail:mt-8 group-data-[expanded=true]/rail:items-stretch min-[1025px]:mt-8 min-[1025px]:items-stretch">
          {mode === "accountant" ? (
            <RailLink href="/fees" active={active === "fees"} label="Fees" icon={<FeesIcon />} onOpen={chooseLink} />
          ) : (
            <>
              <RailLink href="/academy" active={active === "academy"} label="Academy" icon={<AcademyIcon />} onOpen={chooseLink} />
              <RailLink href="/admins" active={active === "admins"} label="Admins" icon={<AdminsIcon />} onOpen={chooseLink} />
              <RailLink href="/coaches" active={active === "coaches"} label="Coaches" icon={<CoachesIcon />} onOpen={chooseLink} />
              <RailLink href="/players" active={active === "players"} label="Players" icon={<PlayersIcon />} onOpen={chooseLink} />
              <RailLink href="/batches" active={active === "batches"} label="Batches" icon={<BatchesIcon />} onOpen={chooseLink} />
              <RailLink href="/sessions" active={active === "sessions"} label="Sessions" icon={<SessionsIcon />} onOpen={chooseLink} />
              <RailLink href="/accountant" active={active === "accountant"} label="Accountant" icon={<AccountantIcon />} onOpen={chooseLink} />
              <DateRangeButton onOpen={chooseLink} />
            </>
          )}
        </nav>
        <div className="mt-auto flex w-full flex-col items-center gap-3 min-[1025px]:block">
          {email ? <p className="hidden text-xs text-muted group-data-[expanded=true]/rail:mb-3 group-data-[expanded=true]/rail:block min-[1025px]:mb-3 min-[1025px]:block">{email}</p> : null}
          <button
            type="button"
            onClick={signOut}
            title="Sign out"
            aria-label="Sign out"
            className="flex size-10 items-center justify-center gap-0 rounded-xl text-sm text-cream-text/80 hover:bg-white/5 hover:text-white group-data-[expanded=true]/rail:h-auto group-data-[expanded=true]/rail:w-auto group-data-[expanded=true]/rail:justify-start group-data-[expanded=true]/rail:gap-3 group-data-[expanded=true]/rail:rounded-none group-data-[expanded=true]/rail:bg-transparent group-data-[expanded=true]/rail:hover:bg-transparent min-[1025px]:h-auto min-[1025px]:w-auto min-[1025px]:justify-start min-[1025px]:gap-3 min-[1025px]:rounded-none min-[1025px]:bg-transparent min-[1025px]:hover:bg-transparent"
          >
            <span className="inline shrink-0">
              <SignOutIcon />
            </span>
            <span className="hidden group-data-[expanded=true]/rail:inline min-[1025px]:inline">Sign out</span>
          </button>
        </div>
      </aside>
      <div className="desk-content relative flex min-h-0 min-w-0 flex-1 flex-col bg-cream">{children}</div>
    </div>
  );
}

function RailLink({
  href,
  active,
  label,
  icon,
  onOpen,
}: {
  href: string;
  active: boolean;
  label: string;
  icon: React.ReactNode;
  onOpen: () => void;
}) {
  return (
    <Link
      href={href}
      title={label}
      aria-label={label}
      onClick={onOpen}
      className={`flex size-10 w-auto items-center justify-center gap-0 rounded-xl px-0 py-2 text-sm font-semibold group-data-[expanded=true]/rail:h-auto group-data-[expanded=true]/rail:w-auto group-data-[expanded=true]/rail:justify-start group-data-[expanded=true]/rail:gap-3 group-data-[expanded=true]/rail:px-3 min-[1025px]:h-auto min-[1025px]:w-auto min-[1025px]:justify-start min-[1025px]:gap-3 min-[1025px]:px-3 ${
        active ? "text-terracotta" : "text-cream-text/80 hover:bg-white/5"
      }`}
    >
      <span className="inline shrink-0">{icon}</span>
      <span className="hidden group-data-[expanded=true]/rail:inline min-[1025px]:inline">{label}</span>
    </Link>
  );
}

function MarkIcon() {
  return (
    <RailSvg>
      <rect x="3.5" y="3.5" width="17" height="17" rx="5" />
      <path d="M8 15V9l4 3.2L16 9v6" />
    </RailSvg>
  );
}

function SidebarIcon() {
  return (
    <RailSvg>
      <rect x="3.5" y="4" width="17" height="16" rx="2" />
      <path d="M9 4v16" />
    </RailSvg>
  );
}

function CloseIcon() {
  return (
    <RailSvg>
      <path d="M6 6l12 12M18 6 6 18" />
    </RailSvg>
  );
}

function RailSvg({ children }: { children: React.ReactNode }) {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
      {children}
    </svg>
  );
}

function AcademyIcon() {
  return (
    <RailSvg>
      <path d="M4 20V9l8-5 8 5v11" />
      <path d="M9 20v-6h6v6" />
    </RailSvg>
  );
}

function AdminsIcon() {
  return (
    <RailSvg>
      <path d="M12 3 5 6v6c0 4.2 2.8 6.8 7 8.5 4.2-1.7 7-4.3 7-8.5V6l-7-3z" />
    </RailSvg>
  );
}

function CoachesIcon() {
  return (
    <RailSvg>
      <circle cx="12" cy="8" r="3" />
      <path d="M5.5 19.5c1.4-3 3.4-4.5 6.5-4.5s5.1 1.5 6.5 4.5" />
    </RailSvg>
  );
}

function PlayersIcon() {
  return (
    <RailSvg>
      <circle cx="8" cy="8" r="2.4" />
      <circle cx="16" cy="8" r="2.4" />
      <path d="M3.5 19c.9-2.4 2.4-3.8 4.5-3.8s3.6 1.4 4.5 3.8" />
      <path d="M11.5 19c.9-2.4 2.4-3.8 4.5-3.8s3.6 1.4 4.5 3.8" />
    </RailSvg>
  );
}

function BatchesIcon() {
  return (
    <RailSvg>
      <path d="M12 3 3 8l9 5 9-5-9-5z" />
      <path d="M3 12l9 5 9-5" />
      <path d="M3 16l9 5 9-5" />
    </RailSvg>
  );
}

function SessionsIcon() {
  return (
    <RailSvg>
      <rect x="3.5" y="5" width="17" height="15.5" rx="2" />
      <path d="M8 3.5v3M16 3.5v3M3.5 10h17" />
    </RailSvg>
  );
}

function AccountantIcon() {
  return (
    <RailSvg>
      <rect x="5" y="3" width="14" height="18" rx="2" />
      <path d="M8 7h8M8 12h.01M12 12h.01M16 12h.01M8 16h.01M12 16h.01M16 16h.01" />
    </RailSvg>
  );
}

function FeesIcon() {
  return (
    <RailSvg>
      <path d="M7 3h10v18l-2.2-1.4L12.5 21l-2.3-1.4L8 21l-2.2-1.4L7 21V3z" />
      <path d="M10 8h4M10 12h4" />
    </RailSvg>
  );
}

function SignOutIcon() {
  return (
    <RailSvg>
      <path d="M10 7V5.5A1.5 1.5 0 0 1 11.5 4H19v16h-7.5A1.5 1.5 0 0 1 10 18.5V17" />
      <path d="M14 12H4m0 0 3-3M4 12l3 3" />
    </RailSvg>
  );
}
