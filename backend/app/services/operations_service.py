from datetime import date

from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import AppError, ConflictError, ForbiddenError
from app.models import (
    Batch,
    CoachAttendance,
    Enrollment,
    Match,
    Session as TrainingSession,
    SessionAssignment,
    StudentAttendance,
    UserRole,
)
from app.schemas import (
    AssignmentCreate,
    AssignmentMove,
    AssignmentResponse,
    BatchCreate,
    BatchResponse,
    BatchUpdate,
    EnrollmentCreate,
    EnrollmentResponse,
    SessionCoachBrief,
    SessionCreate,
    SessionResponse,
    SessionUpdate,
)
from app.services import require_record


def _batch_response(batch: Batch) -> BatchResponse:
    return BatchResponse(
        batch_id=batch.batch_id,
        academy_id=batch.academy_id,
        name=batch.name,
        days=batch.days,
        sport=batch.sport,
        meeting_point=batch.meeting_point,
        focus=batch.focus,
        kit=batch.kit,
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


def update_batch(db: Session, batch_id: int, payload: BatchUpdate) -> BatchResponse:
    batch = require_record(
        db.query(Batch).options(joinedload(Batch.enrollments)).filter(Batch.batch_id == batch_id).first(),
        "Batch not found",
    )
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise AppError(422, "No batch changes were sent")
    for field, value in changes.items():
        setattr(batch, field, value)
    db.commit()
    db.refresh(batch)
    return _batch_response(batch)


def list_enrollments(db: Session, student_id: int | None = None) -> list[EnrollmentResponse]:
    query = db.query(Enrollment).options(joinedload(Enrollment.batch))
    if student_id is not None:
        query = query.filter(Enrollment.student_id == student_id)
    return [
        EnrollmentResponse(
            enrollment_id=row.enrollment_id,
            batch_id=row.batch_id,
            student_id=row.student_id,
            batch_name=row.batch.name if row.batch is not None else None,
        )
        for row in query.order_by(Enrollment.enrollment_id).all()
    ]


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
        coaches=[
            SessionCoachBrief(
                assignment_id=assignment.assignment_id,
                coach_id=assignment.coach_id,
                coach_name=assignment.coach.name if assignment.coach is not None else None,
            )
            for assignment in session.assignments
        ],
        ground=session.ground,
        note=session.note,
        meeting_point=session.batch.meeting_point if session.batch else None,
        focus=session.batch.focus if session.batch else None,
        kit=session.batch.kit if session.batch else None,
    )


def _load_session(db: Session, session_id: int) -> TrainingSession:
    return require_record(
        db.query(TrainingSession)
        .options(
            joinedload(TrainingSession.batch).joinedload(Batch.enrollments),
            joinedload(TrainingSession.assignments).joinedload(SessionAssignment.coach),
            joinedload(TrainingSession.coach_attendances),
        )
        .filter(TrainingSession.session_id == session_id)
        .first(),
        "Session not found",
    )


def create_session(db: Session, payload: SessionCreate) -> SessionResponse:
    require_record(db.get(Batch, payload.batch_id), "Batch not found")
    session = TrainingSession(
        batch_id=payload.batch_id,
        date=payload.date,
        start=payload.start,
        end=payload.end,
        ground=payload.ground,
        note=payload.note,
    )
    db.add(session)
    db.commit()
    return _session_response(_load_session(db, session.session_id))


def update_session(db: Session, session_id: int, payload: SessionUpdate) -> SessionResponse:
    session = require_record(db.get(TrainingSession, session_id), "Session not found")
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise AppError(422, "No session changes were sent")
    if "batch_id" in changes:
        require_record(db.get(Batch, changes["batch_id"]), "Batch not found")
    for field, value in changes.items():
        setattr(session, field, value)
    db.commit()
    return _session_response(_load_session(db, session_id))


def list_sessions(
    db: Session,
    current: CurrentUser,
    batch_id: int | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
) -> list[SessionResponse]:
    query = db.query(TrainingSession).options(
        joinedload(TrainingSession.batch).joinedload(Batch.enrollments),
        joinedload(TrainingSession.assignments).joinedload(SessionAssignment.coach),
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
    return _session_response(_load_session(db, session_id))


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


def delete_assignment(db: Session, assignment_id: int) -> None:
    assignment = require_record(db.get(SessionAssignment, assignment_id), "Assignment not found")
    db.delete(assignment)
    db.commit()


def _delete_session_rows(db: Session, session_id: int) -> None:
    db.query(SessionAssignment).filter(SessionAssignment.session_id == session_id).delete(synchronize_session=False)
    db.query(CoachAttendance).filter(CoachAttendance.session_id == session_id).delete(synchronize_session=False)
    db.query(StudentAttendance).filter(StudentAttendance.session_id == session_id).delete(synchronize_session=False)
    session = db.get(TrainingSession, session_id)
    if session is not None:
        db.delete(session)


def delete_session(db: Session, session_id: int) -> None:
    require_record(db.get(TrainingSession, session_id), "Session not found")
    _delete_session_rows(db, session_id)
    db.commit()


def delete_batch(db: Session, batch_id: int) -> None:
    require_record(db.get(Batch, batch_id), "Batch not found")
    session_ids = [
        session.session_id
        for session in db.query(TrainingSession).filter(TrainingSession.batch_id == batch_id).all()
    ]
    for session_id in session_ids:
        _delete_session_rows(db, session_id)
    db.query(Match).filter(Match.batch_id == batch_id).delete(synchronize_session=False)
    db.query(Enrollment).filter(Enrollment.batch_id == batch_id).delete(synchronize_session=False)
    batch = db.get(Batch, batch_id)
    if batch is not None:
        db.delete(batch)
    db.commit()


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
