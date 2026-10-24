from datetime import date

from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import AppError, ForbiddenError, NotFoundError
from app.models import (
    Coach,
    CoachAttendance,
    Enrollment,
    Leave,
    PlayerSessionResponse,
    Session as TrainingSession,
    SessionAssignment,
    Student,
    StudentAttendance,
)
from app.models.enums import AttendanceStatus, UserRole
from app.schemas import (
    AttendanceMark,
    AttendanceSummary,
    CoachAttendanceResponse,
    LeaveCreate,
    LeaveResponse,
    LeaveUpdate,
    SessionRosterStudent,
    StudentAttendanceMark,
    StudentAttendanceResponse,
)
from app.services import require_record


def mark_coach_attendance(
    db: Session,
    current: CurrentUser,
    session_id: int,
    payload: AttendanceMark,
    coach_id: int | None = None,
) -> CoachAttendanceResponse:
    target_coach_id = coach_id or current.coach_id
    if target_coach_id is None:
        raise ForbiddenError()
    if current.role.value == "coach" and current.coach_id != target_coach_id:
        raise ForbiddenError("Coaches can only mark their own attendance")
    require_record(db.get(TrainingSession, session_id), "Session not found")
    record = (
        db.query(CoachAttendance)
        .filter(CoachAttendance.session_id == session_id, CoachAttendance.coach_id == target_coach_id)
        .first()
    )
    if record:
        record.status = payload.status
    else:
        record = CoachAttendance(session_id=session_id, coach_id=target_coach_id, status=payload.status)
        db.add(record)
    db.commit()
    db.refresh(record)
    return CoachAttendanceResponse.model_validate(record)


def list_coach_attendance(db: Session, session_id: int) -> list[CoachAttendanceResponse]:
    rows = db.query(CoachAttendance).filter(CoachAttendance.session_id == session_id).all()
    return [CoachAttendanceResponse.model_validate(row) for row in rows]


def _marker_coach_id(db: Session, current: CurrentUser, session_id: int) -> int:
    if current.coach_id is not None:
        return current.coach_id
    if current.role != UserRole.SUPER_ADMIN:
        raise ForbiddenError("Only a coach can mark student attendance")
    assignment = db.query(SessionAssignment).filter(SessionAssignment.session_id == session_id).first()
    if assignment is not None:
        return assignment.coach_id
    coach = db.query(Coach).first()
    if coach is None:
        raise ForbiddenError("Assign a coach before marking attendance")
    return coach.coach_id


def mark_student_attendance(
    db: Session,
    current: CurrentUser,
    session_id: int,
    payload: StudentAttendanceMark,
) -> StudentAttendanceResponse:
    marker_id = _marker_coach_id(db, current, session_id)
    require_record(db.get(TrainingSession, session_id), "Session not found")
    require_record(db.get(Student, payload.student_id), "Student not found")
    record = (
        db.query(StudentAttendance)
        .filter(
            StudentAttendance.session_id == session_id,
            StudentAttendance.student_id == payload.student_id,
        )
        .first()
    )
    if record:
        record.status = payload.status
        record.marked_by_coach_id = marker_id
    else:
        record = StudentAttendance(
            session_id=session_id,
            student_id=payload.student_id,
            marked_by_coach_id=marker_id,
            status=payload.status,
        )
        db.add(record)
    db.commit()
    db.refresh(record)
    return StudentAttendanceResponse.model_validate(record)


def list_student_attendance(db: Session, session_id: int) -> list[StudentAttendanceResponse]:
    rows = db.query(StudentAttendance).filter(StudentAttendance.session_id == session_id).all()
    return [StudentAttendanceResponse.model_validate(row) for row in rows]


def session_roster(db: Session, session_id: int) -> list[SessionRosterStudent]:
    session = require_record(
        db.query(TrainingSession).options(joinedload(TrainingSession.batch)).filter(TrainingSession.session_id == session_id).first(),
        "Session not found",
    )
    enrollments = db.query(Enrollment).options(joinedload(Enrollment.student)).filter(Enrollment.batch_id == session.batch_id).all()
    attendance_map = {
        row.student_id: row.status
        for row in db.query(StudentAttendance).filter(StudentAttendance.session_id == session_id).all()
    }
    responses = {
        row.student_id: row
        for row in db.query(PlayerSessionResponse).filter(PlayerSessionResponse.session_id == session_id).all()
    }
    return [
        SessionRosterStudent(
            student_id=item.student.student_id,
            name=item.student.name,
            photo_url=item.student.photo_url,
            fee_status=item.student.fee_status,
            attendance_status=attendance_map.get(item.student.student_id),
            checked_in=bool(responses.get(item.student.student_id) and responses[item.student.student_id].checked_in),
            skip_reason=responses[item.student.student_id].skip_reason if item.student.student_id in responses else None,
        )
        for item in enrollments
    ]


def coach_attendance_summary(db: Session, coach_id: int, month: date | None = None) -> AttendanceSummary:
    month = month or date.today()
    rows = (
        db.query(CoachAttendance)
        .join(TrainingSession, CoachAttendance.session_id == TrainingSession.session_id)
        .filter(
            CoachAttendance.coach_id == coach_id,
            TrainingSession.date >= month.replace(day=1),
        )
        .all()
    )
    attended = len([row for row in rows if row.status == AttendanceStatus.PRESENT])
    missed = len([row for row in rows if row.status == AttendanceStatus.ABSENT])
    return AttendanceSummary(days=len(rows), attended=attended, missed=missed)


def create_leave(db: Session, current: CurrentUser, payload: LeaveCreate) -> LeaveResponse:
    if current.coach_id is None:
        raise ForbiddenError()
    leave = Leave(
        coach_id=current.coach_id,
        from_date=payload.from_date,
        to_date=payload.to_date,
        reason=payload.reason,
    )
    db.add(leave)
    db.commit()
    db.refresh(leave)
    return LeaveResponse.model_validate(leave)


def update_leave(db: Session, leave_id: int, payload: LeaveUpdate) -> LeaveResponse:
    leave = require_record(db.get(Leave, leave_id), "Leave not found")
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise AppError(422, "No leave changes were sent")
    for field, value in changes.items():
        setattr(leave, field, value)
    db.commit()
    db.refresh(leave)
    return LeaveResponse.model_validate(leave)


def list_leaves(db: Session, current: CurrentUser) -> list[LeaveResponse]:
    query = db.query(Leave)
    if current.coach_id:
        query = query.filter(Leave.coach_id == current.coach_id)
    return [LeaveResponse.model_validate(row) for row in query.all()]
