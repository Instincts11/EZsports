"use client";

import { FormEvent, useState } from "react";
import { AppTabs } from "@/components/app-tabs";
import { Field, SaveBar, Section } from "@/components/fields";
import { PageContent } from "@/components/page-content";
import { ApiError, api } from "@/lib/api";
import { changedText } from "@/lib/patch";
import type { Coach } from "@/lib/types";

const keys = [
  "name",
  "email",
  "mobile",
  "dob",
  "gender",
  "emergency_contact",
  "certifications",
  "experience",
  "address",
  "headline",
  "password",
] as const;

type CoachField = (typeof keys)[number];
type CoachForm = Record<CoachField, string>;
type CoachTab = "profile" | "home" | "fixtures" | "sessions";

const coachTabs = [
  { id: "profile", label: "Profile" },
  { id: "home", label: "Home" },
  { id: "fixtures", label: "Fixtures" },
  { id: "sessions", label: "Sessions" },
] as const;

function toForm(coach: Coach): CoachForm {
  return {
    name: coach.name ?? "",
    email: coach.email ?? "",
    mobile: coach.mobile ?? "",
    dob: coach.dob ? coach.dob.slice(0, 10) : "",
    gender: coach.gender ?? "",
    emergency_contact: coach.emergency_contact ?? "",
    certifications: coach.certifications ?? "",
    experience: coach.experience ?? "",
    address: coach.address ?? "",
    headline: coach.headline ?? "",
    password: "",
  };
}

export function CoachEditor({
  coach,
  onSaved,
  onBack,
  onDeleted,
}: {
  coach: Coach;
  onSaved: (coach: Coach) => void;
  onBack: () => void;
  onDeleted: () => void;
}) {
  const [baseline, setBaseline] = useState(coach);
  const [form, setForm] = useState<CoachForm>(() => toForm(coach));
  const [pending, setPending] = useState(false);
  const [notice, setNotice] = useState("");
  const [error, setError] = useState("");
  const [tab, setTab] = useState<CoachTab>("profile");

  function setField(key: CoachField, value: string) {
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
      ["name", "email", "mobile"],
      "Name, email, and mobile are required.",
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
      const saved = await api<Coach>(`/coaches/${coach.coach_id}`, {
        method: "PATCH",
        body: JSON.stringify(patch),
      });
      setBaseline(saved);
      setForm(toForm(saved));
      setNotice("Saved");
      onSaved(saved);
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The coach could not be saved.");
    } finally {
      setPending(false);
    }
  }

  async function removeCoach() {
    if (!window.confirm(`Delete ${baseline.name}?`)) return;
    setPending(true);
    setError("");
    try {
      await api(`/coaches/${baseline.coach_id}`, { method: "DELETE" });
      onDeleted();
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The coach could not be deleted.");
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
          <p className="text-sm text-muted">Same sections as the coach app</p>
        </div>
        <button type="button" onClick={removeCoach} className="text-sm font-semibold text-terracotta">
          Delete
        </button>
      </div>
      <AppTabs tabs={coachTabs} value={tab} onChange={setTab} />
      <div className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
        {tab === "profile" ? (
        <form onSubmit={onSubmit} className="flex flex-col gap-4">
        <Section title="Identity">
          <Field label="Name" value={form.name} onChange={(value) => setField("name", value)} />
          <Field label="Mobile" value={form.mobile} onChange={(value) => setField("mobile", value)} />
          <Field label="Date of birth" type="date" value={form.dob} onChange={(value) => setField("dob", value)} />
          <Field label="Gender" value={form.gender} onChange={(value) => setField("gender", value)} />
          <Field label="Email" type="email" value={form.email} onChange={(value) => setField("email", value)} wide />
        </Section>
        <Section title="Contact">
          <Field
            label="Emergency number"
            value={form.emergency_contact}
            onChange={(value) => setField("emergency_contact", value)}
          />
          <Field label="Address" value={form.address} onChange={(value) => setField("address", value)} wide multiline />
        </Section>
        <Section title="Coaching">
          <Field
            label="Certifications"
            value={form.certifications}
            onChange={(value) => setField("certifications", value)}
            wide
            multiline
          />
          <Field
            label="Experience"
            value={form.experience}
            onChange={(value) => setField("experience", value)}
            wide
          />
          <Field
            label="Headline shown to players"
            value={form.headline}
            onChange={(value) => setField("headline", value)}
            wide
          />
          <Field
            label="New password"
            type="password"
            value={form.password}
            onChange={(value) => setField("password", value)}
            wide
          />
        </Section>
        <SaveBar pending={pending} notice={notice} error={error} />
        </form>
        ) : null}
        <PageContent
          kind="coach"
          personId={baseline.coach_id}
          onChanged={() => onSaved(baseline)}
          panels={
            tab === "home"
              ? ["batch", "sessions"]
              : tab === "fixtures"
                ? ["fixtures"]
                : tab === "sessions"
                  ? ["sessions", "leave"]
                  : ["fee"]
          }
          titles={
            tab === "home"
              ? { batch: "Batch on the home card", sessions: "Home" }
              : tab === "fixtures"
                ? { fixtures: "Fixtures" }
                : tab === "sessions"
                  ? { sessions: "Sessions" }
                  : { fee: "Fee" }
          }
          hints={
            tab === "home"
              ? {
                  batch: "Meeting point and focus appear on the coach home session card.",
                  sessions: "Ground, time, and note appear on the coach home. The academy notice is edited on Academy.",
                }
              : tab === "fixtures"
                ? { fixtures: "These fixtures appear on the coach Fixtures tab and on the player Fixtures tab for that batch." }
                : tab === "sessions"
                  ? { sessions: "This is the coach Sessions tab, including attendance." }
                  : { fee: "Shown when this coach has a fee." }
          }
        />
      </div>
    </div>
  );
}
