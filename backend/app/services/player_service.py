from datetime import date

from sqlalchemy.orm import Session, joinedload, selectinload

from app.core.dependencies import CurrentUser
from app.core.exceptions import NotFoundError
from app.models import (
    AttendanceStatus,
    Batch,
    Bill,
    Enrollment,
    Match,
    PlayerSessionResponse,
    Session as TrainingSession,
    SessionAssignment,
    Student,
    StudentAttendance,
)
from app.schemas import (
    AttendanceSummary,
    MatchResponse,
    PlayerAttendanceItem,
    PlayerHomeResponse,
    PlayerSessionItem,
    PlayerSessionResponseUpdate,
)
from app.services.home_service import _match_response


def _student(db: Session, current: CurrentUser) -> Student:
    if current.student_id is None:
        raise NotFoundError("Player profile not found")
    student = (
        db.query(Student)
        .options(joinedload(Student.super_admin))
        .filter(Student.student_id == current.student_id)
        .first()
    )
    if student is None:
        raise NotFoundError("Player profile not found")
    return student


def _batch_ids(db: Session, student_id: int) -> list[int]:
    rows = db.query(Enrollment.batch_id).filter(Enrollment.student_id == student_id).all()
    return [row[0] for row in rows]


def _session_query(db: Session, batch_ids: list[int]):
    return (
        db.query(TrainingSession)
        .options(
            selectinload(TrainingSession.batch).selectinload(Batch.enrollments),
            selectinload(TrainingSession.assignments).selectinload(SessionAssignment.coach),
            selectinload(TrainingSession.student_attendances),
        )
        .filter(TrainingSession.batch_id.in_(batch_ids))
        .order_by(TrainingSession.date, TrainingSession.start)
    )


def _responses(db: Session, student_id: int) -> dict[int, PlayerSessionResponse]:
    rows = db.query(PlayerSessionResponse).filter(PlayerSessionResponse.student_id == student_id).all()
    return {row.session_id: row for row in rows}


def _player_session(
    session: TrainingSession,
    student_id: int,
    response: PlayerSessionResponse | None = None,
) -> PlayerSessionItem:
    coach_name = None
    coach_headline = None
    if session.assignments and session.assignments[0].coach is not None:
        coach_name = session.assignments[0].coach.name
        coach_headline = session.assignments[0].coach.headline
    status = next(
        (row.status for row in session.student_attendances if row.student_id == student_id),
        None,
    )
    return PlayerSessionItem(
        session_id=session.session_id,
        batch_id=session.batch_id,
        batch_name=session.batch.name if session.batch else None,
        date=session.date,
        start=session.start,
        end=session.end,
        coach_name=coach_name,
        student_count=len(session.batch.enrollments) if session.batch else 0,
        attendance_status=status,
        ground=session.ground,
        note=session.note,
        meeting_point=session.batch.meeting_point if session.batch else None,
        focus=session.batch.focus if session.batch else None,
        kit=session.batch.kit if session.batch else None,
        coach_headline=coach_headline,
        checked_in=response.checked_in if response else False,
        skip_reason=response.skip_reason if response else None,
    )


def list_player_sessions(db: Session, current: CurrentUser) -> list[PlayerSessionItem]:
    student = _student(db, current)
    batch_ids = _batch_ids(db, student.student_id)
    if not batch_ids:
        return []
    sessions = _session_query(db, batch_ids).all()
    responses = _responses(db, student.student_id)
    return [
        _player_session(session, student.student_id, responses.get(session.session_id))
        for session in sessions
    ]


def update_player_session_response(
    db: Session,
    current: CurrentUser,
    session_id: int,
    payload: PlayerSessionResponseUpdate,
) -> PlayerSessionItem:
    student = _student(db, current)
    batch_ids = _batch_ids(db, student.student_id)
    session = _session_query(db, batch_ids).filter(TrainingSession.session_id == session_id).first() if batch_ids else None
    if session is None:
        raise NotFoundError("Session not found in your batches")
    response = (
        db.query(PlayerSessionResponse)
        .filter(
            PlayerSessionResponse.session_id == session_id,
            PlayerSessionResponse.student_id == student.student_id,
        )
        .first()
    )
    if response is None:
        response = PlayerSessionResponse(session_id=session_id, student_id=student.student_id, checked_in=False)
        db.add(response)
    data = payload.model_dump(exclude_unset=True)
    if "checked_in" in data and data["checked_in"] is not None:
        response.checked_in = data["checked_in"]
        if response.checked_in:
            response.skip_reason = None
    if "skip_reason" in data:
        reason = (data["skip_reason"] or "").strip()
        response.skip_reason = reason or None
        if response.skip_reason:
            response.checked_in = False
    db.commit()
    db.refresh(response)
    return _player_session(session, student.student_id, response)


def list_player_matches(db: Session, current: CurrentUser) -> list[MatchResponse]:
    student = _student(db, current)
    batch_ids = _batch_ids(db, student.student_id)
    if not batch_ids:
        return []
    matches = (
        db.query(Match)
        .options(joinedload(Match.batch))
        .filter(Match.batch_id.in_(batch_ids))
        .order_by(Match.date, Match.start)
        .all()
    )
    return [_match_response(match) for match in matches]


def list_player_attendance(db: Session, current: CurrentUser) -> list[PlayerAttendanceItem]:
    student = _student(db, current)
    rows = (
        db.query(StudentAttendance)
        .options(joinedload(StudentAttendance.session).joinedload(TrainingSession.batch))
        .filter(StudentAttendance.student_id == student.student_id)
        .all()
    )
    rows.sort(key=lambda row: (row.session.date, row.session.start), reverse=True)
    return [
        PlayerAttendanceItem(
            session_id=row.session_id,
            date=row.session.date,
            batch_name=row.session.batch.name if row.session.batch else None,
            status=row.status,
        )
        for row in rows
    ]


def _attendance_summary(rows: list[PlayerAttendanceItem]) -> AttendanceSummary:
    attended = sum(1 for row in rows if row.status == AttendanceStatus.PRESENT)
    missed = sum(1 for row in rows if row.status == AttendanceStatus.ABSENT)
    return AttendanceSummary(days=len(rows), attended=attended, missed=missed)


def get_player_home(db: Session, current: CurrentUser) -> PlayerHomeResponse:
    student = _student(db, current)
    today = date.today()
    sessions = list_player_sessions(db, current)
    matches = list_player_matches(db, current)
    attendance = list_player_attendance(db, current)
    bill = (
        db.query(Bill)
        .filter(Bill.student_id == student.student_id)
        .order_by(Bill.due_date.desc())
        .first()
    )
    academy_name = "ID Sports Academy"
    notice = None
    phone = None
    address = None
    if student.super_admin is not None and student.super_admin.academy is not None:
        academy_name = student.super_admin.academy.name
        notice = student.super_admin.academy.notice
        phone = student.super_admin.academy.phone
        address = student.super_admin.academy.address
    return PlayerHomeResponse(
        academy_name=academy_name,
        notice=notice,
        phone=phone,
        address=address,
        player_name=student.name,
        date=today,
        sessions_today=sum(1 for session in sessions if session.date == today),
        fee_status=bill.status if bill else student.fee_status,
        fee_amount=bill.amount if bill else None,
        fee_due_date=bill.due_date if bill else None,
        attendance=_attendance_summary(attendance),
        today_sessions=[session for session in sessions if session.date == today],
        upcoming_sessions=[session for session in sessions if session.date > today][:6],
        matches=[match for match in matches if match.date >= today][:5],
    )
