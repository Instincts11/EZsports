"use client";

import { FormEvent, useState } from "react";
import { AppTabs } from "@/components/app-tabs";
import { Field, SaveBar, Section } from "@/components/fields";
import { PageContent } from "@/components/page-content";
import { ApiError, api } from "@/lib/api";
import { formatDate, rupees } from "@/lib/format";
import { changedText } from "@/lib/patch";
import type { Student } from "@/lib/types";

const keys = [
  "name",
  "first_name",
  "last_name",
  "dob",
  "gender",
  "jersey",
  "mobile",
  "parent_mobile",
  "guardian_name",
  "emergency_contact",
  "position",
  "preferred_foot",
  "school",
  "school_class",
  "blood_group",
  "allergies",
  "email",
  "password",
  "coach_note",
] as const;

type PlayerField = (typeof keys)[number];
type PlayerForm = Record<PlayerField, string>;
type PlayerTab = "profile" | "home" | "fixtures" | "schedule";

const playerTabs = [
  { id: "profile", label: "Profile" },
  { id: "home", label: "Home" },
  { id: "fixtures", label: "Fixtures" },
  { id: "schedule", label: "Schedule" },
] as const;

function toForm(student: Student): PlayerForm {
  return {
    name: student.name ?? "",
    first_name: student.first_name ?? "",
    last_name: student.last_name ?? "",
    dob: student.dob && /^\d{4}-\d{2}-\d{2}/.test(student.dob) ? student.dob.slice(0, 10) : (student.dob ?? ""),
    gender: student.gender ?? "",
    jersey: student.jersey ?? "",
    mobile: student.mobile ?? "",
    parent_mobile: student.parent_mobile ?? "",
    guardian_name: student.guardian_name ?? "",
    emergency_contact: student.emergency_contact ?? "",
    position: student.position ?? "",
    preferred_foot: student.preferred_foot ?? "",
    school: student.school ?? "",
    school_class: student.school_class ?? "",
    blood_group: student.blood_group ?? "",
    allergies: student.allergies ?? "",
    email: student.email ?? "",
    password: "",
    coach_note: student.coach_note ?? "",
  };
}

function feeLine(student: Student): string {
  const status = student.bill_status || student.fee_status || "Not set";
  const amount = rupees(student.bill_amount);
  const due = student.bill_due_date ? formatDate(student.bill_due_date) : "";
  return [amount, status, due].filter(Boolean).join(" · ");
}

export function PlayerEditor({
  student,
  onSaved,
  onBack,
  onDeleted,
}: {
  student: Student;
  onSaved: (student: Student) => void;
  onBack: () => void;
  onDeleted: () => void;
}) {
  const [baseline, setBaseline] = useState(student);
  const [form, setForm] = useState<PlayerForm>(() => toForm(student));
  const [pending, setPending] = useState(false);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");
  const [tab, setTab] = useState<PlayerTab>("profile");

  function setField(key: PlayerField, value: string) {
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
      ["name", "parent_mobile"],
      "Name and parent mobile are required.",
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
      const saved = await api<Student>(`/students/${student.student_id}`, {
        method: "PATCH",
        body: JSON.stringify(patch),
      });
      setBaseline(saved);
      setForm(toForm(saved));
      setNotice("Saved");
      onSaved(saved);
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The player could not be saved.");
    } finally {
      setPending(false);
    }
  }

  function refresh() {
    api<Student>(`/students/${baseline.student_id}`)
      .then((saved) => {
        setBaseline(saved);
        setForm(toForm(saved));
        onSaved(saved);
      })
      .catch(() => undefined);
  }

  async function removePlayer() {
    if (!window.confirm(`Delete ${baseline.name}?`)) return;
    setPending(true);
    setError("");
    try {
      await api(`/students/${baseline.student_id}`, { method: "DELETE" });
      onDeleted();
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The player could not be deleted.");
      setPending(false);
    }
  }

  return (
    <div className="flex min-h-0 flex-1 flex-col">
      <div className="flex items-center gap-3 border-b border-line px-5 py-4">
        <button type="button" onClick={onBack} className="text-sm font-semibold text-terracotta lg:hidden">
          Back
        </button>
        <div className="min-w-0 flex-1">
          <h2 className="font-serif text-3xl font-medium">{baseline.name}</h2>
          <p className="text-sm text-muted">Same sections as the player app</p>
        </div>
        <button type="button" onClick={removePlayer} className="text-sm font-semibold text-terracotta">
          Delete
        </button>
      </div>
      <AppTabs tabs={playerTabs} value={tab} onChange={setTab} />
      <div className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
        {tab === "profile" ? (
        <form onSubmit={onSubmit} className="flex flex-col gap-4">
        <div className="grid gap-3 sm:grid-cols-3">
          <Fact label="Batch" value={baseline.batch_name || "No batch"} />
          <Fact label="Fee" value={feeLine(baseline)} />
          <Fact
            label="Attendance"
            value={`${baseline.attended} of ${baseline.total_sessions} present`}
          />
        </div>
        <Section title="Identity">
          <Field label="First name" value={form.first_name} onChange={(value) => setField("first_name", value)} />
          <Field label="Last name" value={form.last_name} onChange={(value) => setField("last_name", value)} />
          <Field label="Full name" value={form.name} onChange={(value) => setField("name", value)} />
          <Field label="Date of birth" type="date" value={form.dob} onChange={(value) => setField("dob", value)} />
          <Field label="Gender" value={form.gender} onChange={(value) => setField("gender", value)} />
          <Field label="Jersey" value={form.jersey} onChange={(value) => setField("jersey", value)} />
          <Field label="Email" type="email" value={form.email} onChange={(value) => setField("email", value)} wide />
          <Field
            label="Sign-in password"
            type="password"
            value={form.password}
            onChange={(value) => setField("password", value)}
            wide
          />
        </Section>
        <Section title="Family">
          <Field label="Mobile" value={form.mobile} onChange={(value) => setField("mobile", value)} />
          <Field
            label="Parent mobile"
            value={form.parent_mobile}
            onChange={(value) => setField("parent_mobile", value)}
          />
          <Field label="Guardian" value={form.guardian_name} onChange={(value) => setField("guardian_name", value)} />
          <Field
            label="Emergency number"
            value={form.emergency_contact}
            onChange={(value) => setField("emergency_contact", value)}
          />
        </Section>
        <Section title="Football">
          <Field label="Position" value={form.position} onChange={(value) => setField("position", value)} />
          <Field
            label="Preferred foot"
            value={form.preferred_foot}
            onChange={(value) => setField("preferred_foot", value)}
          />
        </Section>
        <Section title="School and health">
          <Field label="School" value={form.school} onChange={(value) => setField("school", value)} />
          <Field label="Class" value={form.school_class} onChange={(value) => setField("school_class", value)} />
          <Field label="Blood group" value={form.blood_group} onChange={(value) => setField("blood_group", value)} />
          <Field
            label="Allergies"
            value={form.allergies}
            onChange={(value) => setField("allergies", value)}
            wide
            multiline
          />
          <Field
            label="Note for this player"
            value={form.coach_note}
            onChange={(value) => setField("coach_note", value)}
            wide
            multiline
          />
        </Section>
        <SaveBar pending={pending} notice={notice} error={error} />
        </form>
        ) : null}
        <PageContent
          kind="player"
          personId={baseline.student_id}
          onChanged={refresh}
          panels={
            tab === "home"
              ? ["sessions", "fixtures"]
              : tab === "fixtures"
                ? ["fixtures"]
                : tab === "schedule"
                  ? ["batch", "sessions"]
                  : ["fee"]
          }
          titles={
            tab === "home"
              ? { sessions: "Home", fixtures: "Fixture on home" }
              : tab === "fixtures"
                ? { fixtures: "Fixtures" }
                : tab === "schedule"
                  ? { batch: "Batch", sessions: "Schedule" }
                  : { fee: "Fee" }
          }
          hints={
            tab === "home"
              ? {
                  sessions: "Today's session card on the player home. The academy notice is edited on Academy.",
                  fixtures: "The next fixture on the player home. The full list is on Fixtures.",
                }
              : tab === "fixtures"
                ? { fixtures: "Shown on the player Fixtures tab for this player's batches." }
                : tab === "schedule"
                  ? {
                      batch: "Batch name, meeting point, and focus appear on the player schedule.",
                      sessions: "Date, ground, and note appear on the player schedule.",
                    }
                  : { fee: "Shown on this player's profile for the coach." }
          }
        />
      </div>
    </div>
  );
}

function Fact({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-line bg-card px-4 py-3">
      <p className="text-xs font-semibold tracking-wide text-muted uppercase">{label}</p>
      <p className="mt-1 text-sm font-semibold leading-snug wrap-break-word">{value}</p>
    </div>
  );
}
