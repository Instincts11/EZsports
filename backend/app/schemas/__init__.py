from datetime import date, datetime, time
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, EmailStr

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


class AccountantCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class AccountantResponse(ORMModel):
    accountant_id: int
    admin_id: int
    name: str
    email: EmailStr | None = None
    assigned_at: datetime | None = None


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


class CoachUpdate(BaseModel):
    name: str | None = None
    mobile: str | None = None
    dob: date | None = None
    gender: str | None = None
    emergency_contact: str | None = None
    certifications: str | None = None
    experience: str | None = None
    address: str | None = None
    photo_url: str | None = None


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
    email: EmailStr | None = None


class StudentCreate(BaseModel):
    name: str
    parent_mobile: str
    photo_url: str | None = None


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


class StudentResponse(ORMModel):
    student_id: int
    admin_id: int
    user_id: int | None = None
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
    fee_status: BillStatus
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


class BatchResponse(ORMModel):
    batch_id: int
    academy_id: int
    name: str
    days: str
    sport: str
    student_count: int = 0


class EnrollmentCreate(BaseModel):
    batch_id: int
    student_id: int


class EnrollmentResponse(ORMModel):
    enrollment_id: int
    batch_id: int
    student_id: int


class SessionCreate(BaseModel):
    batch_id: int
    date: date
    start: time
    end: time


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
    student_id: int
    amount: Decimal
    due_date: date
    status: BillStatus = BillStatus.DUE


class BillUpdate(BaseModel):
    amount: Decimal | None = None
    due_date: date | None = None
    status: BillStatus | None = None


class BillResponse(ORMModel):
    bill_id: int
    student_id: int
    accountant_id: int
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


class MatchCreate(BaseModel):
    batch_id: int
    title: str
    date: date
    start: time
    end: time
    opponent: str | None = None
    status: MatchStatus = MatchStatus.UPCOMING


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


class LeaveCreate(BaseModel):
    from_date: date
    to_date: date
    reason: str


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
    date: date
    sessions_today: int
    attendance: AttendanceSummary
    upcoming_sessions: list[SessionResponse]
    upcoming_matches: list[MatchResponse]
