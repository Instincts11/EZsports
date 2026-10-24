export type TokenResponse = {
  access_token: string;
  token_type: string;
  role: string;
};

export type Me = {
  user_id: number;
  email: string;
  role: string;
  name: string | null;
  academy_name: string | null;
};

export type Accountant = {
  accountant_id: number;
  admin_id: number;
  name: string;
  email: string | null;
  assigned_at: string | null;
};

export type AcademyAdmin = {
  admin_id: number;
  name: string;
  email: string | null;
  mobile: string | null;
  academy_name: string | null;
};

export type Academy = {
  academy_id: number;
  name: string;
  sport: string;
  notice: string | null;
  phone: string | null;
  address: string | null;
  range_start: string | null;
  range_end: string | null;
};

export type Batch = {
  batch_id: number;
  name: string;
  days: string;
  sport: string;
  meeting_point: string | null;
  focus: string | null;
  kit: string | null;
  student_count: number;
};

export type Coach = {
  coach_id: number;
  name: string;
  mobile: string;
  dob: string | null;
  gender: string | null;
  emergency_contact: string | null;
  certifications: string | null;
  experience: string | null;
  address: string | null;
  headline: string | null;
  email: string | null;
};

export type Student = {
  student_id: number;
  name: string;
  first_name: string | null;
  last_name: string | null;
  dob: string | null;
  gender: string | null;
  mobile: string | null;
  emergency_contact: string | null;
  parent_mobile: string;
  email: string | null;
  guardian_name: string | null;
  position: string | null;
  preferred_foot: string | null;
  school: string | null;
  school_class: string | null;
  jersey: string | null;
  blood_group: string | null;
  allergies: string | null;
  coach_note: string | null;
  fee_status: string;
  batch_name: string | null;
  attended: number;
  total_sessions: number;
  bill_amount: string | number | null;
  bill_due_date: string | null;
  bill_status: string | null;
};

export type Enrollment = {
  enrollment_id: number;
  batch_id: number;
  student_id: number;
  batch_name: string | null;
};

export type SessionCoach = {
  assignment_id: number;
  coach_id: number;
  coach_name: string | null;
};

export type TrainingSession = {
  session_id: number;
  batch_id: number;
  batch_name: string | null;
  date: string;
  start: string;
  end: string;
  ground: string | null;
  note: string | null;
  meeting_point: string | null;
  focus: string | null;
  kit: string | null;
  coaches: SessionCoach[];
};

export type Fixture = {
  match_id: number;
  batch_id: number;
  batch_name: string | null;
  title: string;
  date: string;
  start: string;
  end: string;
  status: string;
  opponent: string | null;
  venue: string | null;
  result: string | null;
};

export type Leave = {
  leave_id: number;
  coach_id: number;
  from_date: string;
  to_date: string;
  reason: string;
  status: string;
};

export type Bill = {
  bill_id: number;
  student_id: number | null;
  coach_id: number | null;
  person_name: string | null;
  amount: string | number;
  due_date: string;
  status: string;
};
