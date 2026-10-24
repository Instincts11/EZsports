from datetime import date, datetime, time

DateValue = date
TimeValue = time
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, EmailStr, model_validator

from app.models.enums import AttendanceStatus, BillStatus, LeaveStatus, MatchStatus, UserRole


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class MessageResponse(BaseModel):
    message: str
    access_token: str | None = None
    role: UserRole | None = None


class LoginRequest(BaseModel):
    identifier: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: UserRole


class MeResponse(ORMModel):
    user_id: int
    email: EmailStr
    role: UserRole
    name: str | None = None
    mobile: str | None = None
    academy_name: str | None = None
    academy_id: int | None = None
    admin_id: int | None = None
    accountant_id: int | None = None
    coach_id: int | None = None
    student_id: int | None = None


class AcademyCreate(BaseModel):
    name: str
    sport: str = "Multi-sport"


class AcademyResponse(ORMModel):
    academy_id: int
    name: str
    sport: str
    notice: str | None = None
    phone: str | None = None
    address: str | None = None
    range_start: DateValue | None = None
    range_end: DateValue | None = None


class AcademyUpdate(BaseModel):
    name: str | None = None
    sport: str | None = None
    notice: str | None = None
    phone: str | None = None
    address: str | None = None
    range_start: DateValue | None = None
    range_end: DateValue | None = None


class AccountantCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class AccountantUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
    password: str | None = None


class AccountantResponse(ORMModel):
    accountant_id: int
    admin_id: int
    name: str
    email: EmailStr | None = None
    assigned_at: datetime | None = None


class SuperAdminResponse(ORMModel):
    admin_id: int
    name: str
    email: EmailStr | None = None
    mobile: str | None = None
    academy_name: str | None = None


class CoachCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    mobile: str
    dob: date | None = None
    gender: str | None = None
    emergency_contact: str | None = None
    certifications: str | None = None
    experience: str | None = None
    address: str | None = None
    photo_url: str | None = None
    headline: str | None = None


class CoachUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
    mobile: str | None = None
    dob: date | None = None
    gender: str | None = None
    emergency_contact: str | None = None
    certifications: str | None = None
    experience: str | None = None
    address: str | None = None
    photo_url: str | None = None
    headline: str | None = None
    password: str | None = None


class CoachResponse(ORMModel):
    coach_id: int
    admin_id: int
    name: str
    mobile: str
    dob: date | None = None
    gender: str | None = None
    emergency_contact: str | None = None
    certifications: str | None = None
    experience: str | None = None
    address: str | None = None
    photo_url: str | None = None
    headline: str | None = None
    email: EmailStr | None = None


class StudentCreate(BaseModel):
    name: str
    parent_mobile: str
    photo_url: str | None = None
    first_name: str | None = None
    last_name: str | None = None
    dob: str | None = None
    gender: str | None = None
    mobile: str | None = None
    emergency_contact: str | None = None
    guardian_name: str | None = None
    position: str | None = None
    preferred_foot: str | None = None
    school: str | None = None
    school_class: str | None = None
    jersey: str | None = None
    blood_group: str | None = None
    allergies: str | None = None
    coach_note: str | None = None
    email: EmailStr | None = None
    password: str | None = None


class StudentUpdate(BaseModel):
    name: str | None = None
    first_name: str | None = None
    last_name: str | None = None
    dob: str | None = None
    gender: str | None = None
    mobile: str | None = None
    emergency_contact: str | None = None
    parent_mobile: str | None = None
    guardian_name: str | None = None
    position: str | None = None
    preferred_foot: str | None = None
    school: str | None = None
    school_class: str | None = None
    jersey: str | None = None
    blood_group: str | None = None
    allergies: str | None = None
    photo_url: str | None = None
    email: EmailStr | None = None
    password: str | None = None
    coach_note: str | None = None


class StudentAttendanceBrief(BaseModel):
    date: date
    batch_name: str | None = None
    status: AttendanceStatus


class StudentResponse(ORMModel):
    student_id: int
    admin_id: int
    user_id: int | None = None
    email: EmailStr | None = None
    name: str
    first_name: str | None = None
    last_name: str | None = None
    dob: str | None = None
    gender: str | None = None
    mobile: str | None = None
    emergency_contact: str | None = None
    parent_mobile: str
    guardian_name: str | None = None
    position: str | None = None
    preferred_foot: str | None = None
    school: str | None = None
    school_class: str | None = None
    jersey: str | None = None
    blood_group: str | None = None
    allergies: str | None = None
    photo_url: str | None = None
    coach_note: str | None = None
    fee_status: BillStatus
    batch_name: str | None = None
    attended: int = 0
    total_sessions: int = 0
    bill_amount: Decimal | None = None
    bill_due_date: date | None = None
    bill_status: BillStatus | None = None
    attendance_marks: list[StudentAttendanceBrief] = []
    otp_verified_at: datetime | None = None


class PlayerSignupRequest(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str = ""
    dob: str | None = None
    gender: str | None = None
    mobile: str
    emergency_contact: str | None = None
    guardian_name: str
    guardian_mobile: str
    position: str | None = None
    preferred_foot: str | None = None
    school: str | None = None
    school_class: str | None = None
    jersey: str | None = None
    blood_group: str | None = None
    allergies: str | None = None


class OtpRequestResponse(BaseModel):
    message: str
    mobile: str
    expires_in_seconds: int
    otp: str | None = None
    access_token: str | None = None
    role: UserRole | None = None


class OtpVerifyRequest(BaseModel):
    mobile: str
    otp: str


class MobileRequest(BaseModel):
    mobile: str


class EmailRequest(BaseModel):
    email: EmailStr


class BatchCreate(BaseModel):
    name: str
    days: str
    sport: str


class BatchUpdate(BaseModel):
    name: str | None = None
    days: str | None = None
    sport: str | None = None
    meeting_point: str | None = None
    focus: str | None = None
    kit: str | None = None


class BatchResponse(ORMModel):
    batch_id: int
    academy_id: int
    name: str
    days: str
    sport: str
    meeting_point: str | None = None
    focus: str | None = None
    kit: str | None = None
    student_count: int = 0


class EnrollmentCreate(BaseModel):
    batch_id: int
    student_id: int


class EnrollmentResponse(ORMModel):
    enrollment_id: int
    batch_id: int
    student_id: int
    batch_name: str | None = None


class SessionCreate(BaseModel):
    batch_id: int
    date: date
    start: time
    end: time
    ground: str | None = None
    note: str | None = None


class SessionUpdate(BaseModel):
    batch_id: int | None = None
    date: DateValue | None = None
    start: TimeValue | None = None
    end: TimeValue | None = None
    ground: str | None = None
    note: str | None = None


class SessionCoachBrief(BaseModel):
    assignment_id: int
    coach_id: int
    coach_name: str | None = None


class SessionResponse(ORMModel):
    session_id: int
    batch_id: int
    batch_name: str | None = None
    date: date
    start: time
    end: time
    student_count: int = 0
    coach_count: int = 0
    assigned_coach_count: int = 0
    coaches: list[SessionCoachBrief] = []
    ground: str | None = None
    note: str | None = None
    meeting_point: str | None = None
    focus: str | None = None
    kit: str | None = None
    my_attendance_status: AttendanceStatus | None = None
    students_marked: int = 0


class AssignmentCreate(BaseModel):
    session_id: int
    coach_id: int


class AssignmentMove(BaseModel):
    session_id: int


class AssignmentResponse(ORMModel):
    assignment_id: int
    session_id: int
    coach_id: int
    coach_name: str | None = None
    assigned_by: int


class BillCreate(BaseModel):
    student_id: int | None = None
    coach_id: int | None = None
    amount: Decimal
    due_date: date
    status: BillStatus = BillStatus.DUE

    @model_validator(mode="after")
    def one_account(self) -> "BillCreate":
        if (self.student_id is None) == (self.coach_id is None):
            raise ValueError("Choose either a player or a coach")
        return self


class BillUpdate(BaseModel):
    amount: Decimal | None = None
    due_date: date | None = None
    status: BillStatus | None = None


class BillResponse(ORMModel):
    bill_id: int
    student_id: int | None = None
    coach_id: int | None = None
    accountant_id: int
    person_name: str | None = None
    amount: Decimal
    due_date: date
    status: BillStatus


class AttendanceMark(BaseModel):
    status: AttendanceStatus = AttendanceStatus.PRESENT


class StudentAttendanceMark(BaseModel):
    student_id: int
    status: AttendanceStatus


class CoachAttendanceResponse(ORMModel):
    id: int
    session_id: int
    coach_id: int
    status: AttendanceStatus


class StudentAttendanceResponse(ORMModel):
    id: int
    session_id: int
    student_id: int
    marked_by_coach_id: int
    status: AttendanceStatus


class SessionRosterStudent(ORMModel):
    student_id: int
    name: str
    photo_url: str | None = None
    fee_status: BillStatus
    attendance_status: AttendanceStatus | None = None
    checked_in: bool = False
    skip_reason: str | None = None


class MatchCreate(BaseModel):
    batch_id: int
    title: str
    date: date
    start: time
    end: time
    opponent: str | None = None
    venue: str | None = None
    result: str | None = None
    status: MatchStatus = MatchStatus.UPCOMING


class MatchUpdate(BaseModel):
    batch_id: int | None = None
    title: str | None = None
    date: DateValue | None = None
    start: TimeValue | None = None
    end: TimeValue | None = None
    opponent: str | None = None
    venue: str | None = None
    result: str | None = None
    status: MatchStatus | None = None


class MatchResponse(ORMModel):
    match_id: int
    batch_id: int
    batch_name: str | None = None
    title: str
    date: date
    start: time
    end: time
    status: MatchStatus
    opponent: str | None = None
    venue: str | None = None
    result: str | None = None


class LeaveCreate(BaseModel):
    from_date: date
    to_date: date
    reason: str


class LeaveUpdate(BaseModel):
    from_date: date | None = None
    to_date: date | None = None
    reason: str | None = None
    status: LeaveStatus | None = None


class LeaveResponse(ORMModel):
    leave_id: int
    coach_id: int
    from_date: date
    to_date: date
    reason: str
    status: LeaveStatus


class AttendanceSummary(BaseModel):
    days: int
    attended: int
    missed: int


class HomeDashboardResponse(BaseModel):
    academy_name: str
    notice: str | None = None
    phone: str | None = None
    address: str | None = None
    range_start: date | None = None
    range_end: date | None = None
    date: date
    sessions_today: int
    attendance: AttendanceSummary
    upcoming_sessions: list[SessionResponse]
    upcoming_matches: list[MatchResponse]


class PlayerSessionItem(BaseModel):
    session_id: int
    batch_id: int
    batch_name: str | None = None
    date: date
    start: time
    end: time
    coach_name: str | None = None
    student_count: int = 0
    attendance_status: AttendanceStatus | None = None
    ground: str | None = None
    note: str | None = None
    meeting_point: str | None = None
    focus: str | None = None
    kit: str | None = None
    coach_headline: str | None = None
    checked_in: bool = False
    skip_reason: str | None = None


class PlayerSessionResponseUpdate(BaseModel):
    checked_in: bool | None = None
    skip_reason: str | None = None


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class PlayerAttendanceItem(BaseModel):
    session_id: int
    date: date
    batch_name: str | None = None
    status: AttendanceStatus


class PlayerHomeResponse(BaseModel):
    academy_name: str
    notice: str | None = None
    phone: str | None = None
    address: str | None = None
    player_name: str
    date: date
    sessions_today: int
    fee_status: BillStatus
    fee_amount: Decimal | None = None
    fee_due_date: date | None = None
    attendance: AttendanceSummary
    today_sessions: list[PlayerSessionItem]
    upcoming_sessions: list[PlayerSessionItem]
    matches: list[MatchResponse]
