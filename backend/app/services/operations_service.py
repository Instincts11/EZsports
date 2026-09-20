from datetime import date

from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import ConflictError, ForbiddenError
from app.models import Batch, Enrollment, Session as TrainingSession, SessionAssignment, UserRole
from app.schemas import (
    AssignmentCreate,
    AssignmentMove,
    AssignmentResponse,
    BatchCreate,
    BatchResponse,
    EnrollmentCreate,
    EnrollmentResponse,
    SessionCreate,
    SessionResponse,
)
from app.services import require_record


def _batch_response(batch: Batch) -> BatchResponse:
    return BatchResponse(
        batch_id=batch.batch_id,
        academy_id=batch.academy_id,
        name=batch.name,
        days=batch.days,
        sport=batch.sport,
        student_count=len(batch.enrollments),
    )


def create_batch(db: Session, current: CurrentUser, payload: BatchCreate) -> BatchResponse:
    if current.academy_id is None:
        raise ForbiddenError()
    batch = Batch(
        academy_id=current.academy_id,
        name=payload.name,
        days=payload.days,
        sport=payload.sport,
    )
    db.add(batch)
    db.commit()
    db.refresh(batch)
    return _batch_response(batch)


def list_batches(db: Session, current: CurrentUser) -> list[BatchResponse]:
    query = db.query(Batch).options(joinedload(Batch.enrollments))
    if current.academy_id:
        query = query.filter(Batch.academy_id == current.academy_id)
    return [_batch_response(batch) for batch in query.all()]


def get_batch(db: Session, batch_id: int) -> BatchResponse:
    batch = require_record(
        db.query(Batch).options(joinedload(Batch.enrollments)).filter(Batch.batch_id == batch_id).first(),
        "Batch not found",
    )
    return _batch_response(batch)


def enroll_student(db: Session, current: CurrentUser, payload: EnrollmentCreate) -> EnrollmentResponse:
    if current.role != UserRole.SUPER_ADMIN:
        raise ForbiddenError("Only Super Admin can enroll students")
    exists = (
        db.query(Enrollment)
        .filter(Enrollment.batch_id == payload.batch_id, Enrollment.student_id == payload.student_id)
        .first()
    )
    if exists:
        raise ConflictError("Student is already enrolled in this batch")
    enrollment = Enrollment(batch_id=payload.batch_id, student_id=payload.student_id)
    db.add(enrollment)
    db.commit()
    db.refresh(enrollment)
    return EnrollmentResponse.model_validate(enrollment)


def unenroll_student(db: Session, enrollment_id: int) -> None:
    enrollment = require_record(db.get(Enrollment, enrollment_id), "Enrollment not found")
    db.delete(enrollment)
    db.commit()


def _session_response(session: TrainingSession) -> SessionResponse:
    return SessionResponse(
        session_id=session.session_id,
        batch_id=session.batch_id,
        batch_name=session.batch.name if session.batch else None,
        date=session.date,
        start=session.start,
        end=session.end,
        student_count=len(session.batch.enrollments) if session.batch else 0,
        coach_count=len(session.coach_attendances),
        assigned_coach_count=len(session.assignments),
    )


def create_session(db: Session, payload: SessionCreate) -> SessionResponse:
    require_record(db.get(Batch, payload.batch_id), "Batch not found")
    session = TrainingSession(
        batch_id=payload.batch_id,
        date=payload.date,
        start=payload.start,
        end=payload.end,
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    session = (
        db.query(TrainingSession)
        .options(
            joinedload(TrainingSession.batch).joinedload(Batch.enrollments),
            joinedload(TrainingSession.assignments),
            joinedload(TrainingSession.coach_attendances),
        )
        .filter(TrainingSession.session_id == session.session_id)
        .first()
    )
    return _session_response(session)


def list_sessions(
    db: Session,
    current: CurrentUser,
    batch_id: int | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
) -> list[SessionResponse]:
    query = db.query(TrainingSession).options(
        joinedload(TrainingSession.batch).joinedload(Batch.enrollments),
        joinedload(TrainingSession.assignments),
        joinedload(TrainingSession.coach_attendances),
    )
    if batch_id:
        query = query.filter(TrainingSession.batch_id == batch_id)
    if date_from:
        query = query.filter(TrainingSession.date >= date_from)
    if date_to:
        query = query.filter(TrainingSession.date <= date_to)
    if current.role.value == "coach" and current.coach_id:
        query = query.join(SessionAssignment).filter(SessionAssignment.coach_id == current.coach_id)
    sessions = query.order_by(TrainingSession.date, TrainingSession.start).all()
    return [_session_response(session) for session in sessions]


def get_session(db: Session, session_id: int) -> SessionResponse:
    session = require_record(
        db.query(TrainingSession)
        .options(
            joinedload(TrainingSession.batch).joinedload(Batch.enrollments),
            joinedload(TrainingSession.assignments),
            joinedload(TrainingSession.coach_attendances),
        )
        .filter(TrainingSession.session_id == session_id)
        .first(),
        "Session not found",
    )
    return _session_response(session)


def assign_coach(db: Session, current: CurrentUser, payload: AssignmentCreate) -> AssignmentResponse:
    if current.admin_id is None:
        raise ForbiddenError()
    exists = (
        db.query(SessionAssignment)
        .filter(
            SessionAssignment.session_id == payload.session_id,
            SessionAssignment.coach_id == payload.coach_id,
        )
        .first()
    )
    if exists:
        raise ConflictError("Coach is already assigned to this session")
    assignment = SessionAssignment(
        session_id=payload.session_id,
        coach_id=payload.coach_id,
        assigned_by=current.admin_id,
    )
    db.add(assignment)
    db.commit()
    db.refresh(assignment)
    return AssignmentResponse(
        assignment_id=assignment.assignment_id,
        session_id=assignment.session_id,
        coach_id=assignment.coach_id,
        coach_name=assignment.coach.name if assignment.coach else None,
        assigned_by=assignment.assigned_by,
    )


def move_coach(db: Session, assignment_id: int, payload: AssignmentMove) -> AssignmentResponse:
    assignment = require_record(db.get(SessionAssignment, assignment_id), "Assignment not found")
    assignment.session_id = payload.session_id
    db.commit()
    db.refresh(assignment)
    return AssignmentResponse(
        assignment_id=assignment.assignment_id,
        session_id=assignment.session_id,
        coach_id=assignment.coach_id,
        coach_name=assignment.coach.name if assignment.coach else None,
        assigned_by=assignment.assigned_by,
    )


def list_session_coaches(db: Session, session_id: int) -> list[AssignmentResponse]:
    rows = (
        db.query(SessionAssignment)
        .options(joinedload(SessionAssignment.coach))
        .filter(SessionAssignment.session_id == session_id)
        .all()
    )
    return [
        AssignmentResponse(
            assignment_id=row.assignment_id,
            session_id=row.session_id,
            coach_id=row.coach_id,
            coach_name=row.coach.name if row.coach else None,
            assigned_by=row.assigned_by,
        )
        for row in rows
    ]
