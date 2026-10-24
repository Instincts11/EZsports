"use client";

import { FormEvent, useEffect, useState } from "react";
import { Field, SaveBar, Section } from "@/components/fields";
import { ApiError, api } from "@/lib/api";
import type { Batch, Coach, Student } from "@/lib/types";

function blank(value: string): string | null {
  const cleaned = value.trim();
  return cleaned || null;
}

export function AddCoachForm({
  onCancel,
  onCreated,
}: {
  onCancel: () => void;
  onCreated: (coach: Coach) => void;
}) {
  const [name, setName] = useState("");
  const [mobile, setMobile] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [dob, setDob] = useState("");
  const [gender, setGender] = useState("");
  const [emergency, setEmergency] = useState("");
  const [address, setAddress] = useState("");
  const [certifications, setCertifications] = useState("");
  const [experience, setExperience] = useState("");
  const [headline, setHeadline] = useState("");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    if (!name.trim() || !mobile.trim() || !email.trim() || !password.trim()) {
      setError("Name, mobile, email, and password are required.");
      return;
    }
    setPending(true);
    setError("");
    try {
      const created = await api<Coach>("/coaches", {
        method: "POST",
        body: JSON.stringify({
          name: name.trim(),
          mobile: mobile.trim(),
          email: email.trim(),
          password,
          dob: blank(dob),
          gender: blank(gender),
          emergency_contact: blank(emergency),
          address: blank(address),
          certifications: blank(certifications),
          experience: blank(experience),
          headline: blank(headline),
        }),
      });
      onCreated(created);
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The coach could not be added.");
    } finally {
      setPending(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex min-h-0 flex-1 flex-col">
      <FormHeader title="New coach" subtitle="This profile appears on the coach app." onCancel={onCancel} />
      <div className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
        <Section title="Sign-in">
          <Field label="Name" value={name} onChange={setName} />
          <Field label="Mobile" value={mobile} onChange={setMobile} />
          <Field label="Email" type="email" value={email} onChange={setEmail} />
          <Field label="Password" type="password" value={password} onChange={setPassword} />
        </Section>
        <Section title="Shown on the coach page">
          <Field label="Date of birth" type="date" value={dob} onChange={setDob} />
          <Field label="Gender" value={gender} onChange={setGender} />
          <Field label="Emergency number" value={emergency} onChange={setEmergency} />
          <Field label="Experience" value={experience} onChange={setExperience} />
          <Field label="Certifications" value={certifications} onChange={setCertifications} wide multiline />
          <Field label="Address" value={address} onChange={setAddress} wide multiline />
          <Field label="Headline shown to players" value={headline} onChange={setHeadline} wide />
        </Section>
        <SaveBar pending={pending} notice="" error={error} label="Add coach" />
      </div>
    </form>
  );
}

export function AddPlayerForm({
  onCancel,
  onCreated,
}: {
  onCancel: () => void;
  onCreated: (student: Student) => void;
}) {
  const [name, setName] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [mobile, setMobile] = useState("");
  const [parentMobile, setParentMobile] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [dob, setDob] = useState("");
  const [gender, setGender] = useState("");
  const [guardian, setGuardian] = useState("");
  const [emergency, setEmergency] = useState("");
  const [position, setPosition] = useState("");
  const [foot, setFoot] = useState("");
  const [school, setSchool] = useState("");
  const [schoolClass, setSchoolClass] = useState("");
  const [jersey, setJersey] = useState("");
  const [blood, setBlood] = useState("");
  const [allergies, setAllergies] = useState("");
  const [note, setNote] = useState("");
  const [batchId, setBatchId] = useState("");
  const [batches, setBatches] = useState<Batch[]>([]);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    api<Batch[]>("/batches")
      .then(setBatches)
      .catch(() => setBatches([]));
  }, []);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    if (!name.trim() || !parentMobile.trim() || !mobile.trim() || !email.trim() || !password.trim()) {
      setError("Name, mobile, parent mobile, email, and password are required.");
      return;
    }
    setPending(true);
    setError("");
    try {
      let created = await api<Student>("/students", {
        method: "POST",
        body: JSON.stringify({
          name: name.trim(),
          first_name: blank(firstName),
          last_name: blank(lastName),
          mobile: mobile.trim(),
          parent_mobile: parentMobile.trim(),
          email: email.trim(),
          password,
          dob: blank(dob),
          gender: blank(gender),
          guardian_name: blank(guardian),
          emergency_contact: blank(emergency),
          position: blank(position),
          preferred_foot: blank(foot),
          school: blank(school),
          school_class: blank(schoolClass),
          jersey: blank(jersey),
          blood_group: blank(blood),
          allergies: blank(allergies),
          coach_note: blank(note),
        }),
      });
      if (batchId) {
        await api("/batches/enrollments", {
          method: "POST",
          body: JSON.stringify({ batch_id: Number(batchId), student_id: created.student_id }),
        });
        created = await api<Student>(`/students/${created.student_id}`);
      }
      onCreated(created);
    } catch (cause) {
      setError(cause instanceof ApiError ? cause.message : "The player could not be added.");
    } finally {
      setPending(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex min-h-0 flex-1 flex-col">
      <FormHeader title="New player" subtitle="These details appear on the player and coach apps." onCancel={onCancel} />
      <div className="flex flex-1 flex-col gap-4 overflow-y-auto px-3 py-5 sm:px-5">
        <Section title="Sign-in">
          <Field label="Full name" value={name} onChange={setName} />
          <Field label="Mobile" value={mobile} onChange={setMobile} />
          <Field label="Email" type="email" value={email} onChange={setEmail} />
          <Field label="Password" type="password" value={password} onChange={setPassword} />
        </Section>
        <Section title="Shown on the player page">
          <Field label="First name" value={firstName} onChange={setFirstName} />
          <Field label="Last name" value={lastName} onChange={setLastName} />
          <Field label="Date of birth" type="date" value={dob} onChange={setDob} />
          <Field label="Gender" value={gender} onChange={setGender} />
          <Field label="Parent mobile" value={parentMobile} onChange={setParentMobile} />
          <Field label="Guardian" value={guardian} onChange={setGuardian} />
          <Field label="Emergency number" value={emergency} onChange={setEmergency} />
          <Field label="Position" value={position} onChange={setPosition} />
          <Field label="Preferred foot" value={foot} onChange={setFoot} />
          <Field label="School" value={school} onChange={setSchool} />
          <Field label="Class" value={schoolClass} onChange={setSchoolClass} />
          <Field label="Jersey" value={jersey} onChange={setJersey} />
          <Field label="Blood group" value={blood} onChange={setBlood} />
          <Field label="Allergies" value={allergies} onChange={setAllergies} wide multiline />
          <Field label="Note for this player" value={note} onChange={setNote} wide multiline />
          <label className="block sm:col-span-2">
            <span className="mb-1.5 block text-xs font-semibold tracking-wide text-muted">Batch</span>
            <select
              value={batchId}
              onChange={(event) => setBatchId(event.target.value)}
              className="w-full rounded-xl border border-line bg-cream px-3 py-2 text-sm outline-none focus:border-terracotta"
            >
              <option value="">No batch yet</option>
              {batches.map((batch) => (
                <option key={batch.batch_id} value={batch.batch_id}>
                  {batch.name}
                </option>
              ))}
            </select>
          </label>
        </Section>
        <SaveBar pending={pending} notice="" error={error} label="Add player" />
      </div>
    </form>
  );
}

function FormHeader({ title, subtitle, onCancel }: { title: string; subtitle: string; onCancel: () => void }) {
  return (
    <div className="flex items-center gap-3 border-b border-line px-5 py-4">
      <button type="button" onClick={onCancel} className="text-sm font-semibold text-terracotta">
        Back
      </button>
      <div>
        <h2 className="font-serif text-3xl font-medium">{title}</h2>
        <p className="text-sm text-muted">{subtitle}</p>
      </div>
    </div>
  );
}
