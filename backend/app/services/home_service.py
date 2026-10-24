from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import AppError, NotFoundError
from app.models import Academy, Batch, Match, Session as TrainingSession, SessionAssignment, StudentAttendance
from app.schemas import AttendanceSummary, HomeDashboardResponse, MatchCreate, MatchResponse, MatchUpdate
from app.services import require_record
from app.services.attendance_service import coach_attendance_summary
from app.services.operations_service import _session_response


def get_home_dashboard(db: Session, current: CurrentUser) -> HomeDashboardResponse:
    if current.academy_id is None:
        raise NotFoundError("Academy not found")
    academy = require_record(db.get(Academy, current.academy_id), "Academy not found")
    today = date.today()
    query = db.query(TrainingSession).options(
        joinedload(TrainingSession.batch).joinedload(Batch.enrollments),
        joinedload(TrainingSession.assignments).joinedload(SessionAssignment.coach),
        joinedload(TrainingSession.coach_attendances),
    ).filter(TrainingSession.date == today)
    if current.coach_id:
        query = query.join(SessionAssignment).filter(SessionAssignment.coach_id == current.coach_id)
    sessions = query.order_by(TrainingSession.start).all()
    matches = (
        db.query(Match)
        .options(joinedload(Match.batch))
        .filter(Match.date >= today)
        .order_by(Match.date, Match.start)
        .limit(5)
        .all()
    )
    summary = coach_attendance_summary(db, current.coach_id) if current.coach_id else None
    session_ids = [session.session_id for session in sessions]
    marked = dict(
        db.query(StudentAttendance.session_id, func.count(StudentAttendance.id))
        .filter(StudentAttendance.session_id.in_(session_ids))
        .group_by(StudentAttendance.session_id)
        .all()
    ) if session_ids else {}
    today_sessions = []
    for session in sessions:
        item = _session_response(session)
        item.students_marked = marked.get(session.session_id, 0)
        item.my_attendance_status = next(
            (row.status for row in session.coach_attendances if row.coach_id == current.coach_id),
            None,
        )
        today_sessions.append(item)
    return HomeDashboardResponse(
        academy_name=academy.name,
        notice=academy.notice,
        phone=academy.phone,
        address=academy.address,
        range_start=academy.range_start,
        range_end=academy.range_end,
        date=today,
        sessions_today=len(sessions),
        attendance=summary or AttendanceSummary(days=0, attended=0, missed=0),
        upcoming_sessions=today_sessions,
        upcoming_matches=[_match_response(match) for match in matches],
    )


def _match_response(match: Match) -> MatchResponse:
    return MatchResponse(
        match_id=match.match_id,
        batch_id=match.batch_id,
        batch_name=match.batch.name if match.batch else None,
        title=match.title,
        date=match.date,
        start=match.start,
        end=match.end,
        status=match.status,
        opponent=match.opponent,
        venue=match.venue,
        result=match.result,
    )


def delete_match(db: Session, match_id: int) -> None:
    match = require_record(db.get(Match, match_id), "Match not found")
    db.delete(match)
    db.commit()


def create_match(db: Session, payload: MatchCreate) -> MatchResponse:
    require_record(db.get(Batch, payload.batch_id), "Batch not found")
    match = Match(
        batch_id=payload.batch_id,
        title=payload.title,
        date=payload.date,
        start=payload.start,
        end=payload.end,
        opponent=payload.opponent,
        venue=payload.venue,
        result=payload.result,
        status=payload.status,
    )
    db.add(match)
    db.commit()
    db.refresh(match)
    return _match_response(match)


def list_matches(
    db: Session,
    date_from: date | None = None,
    date_to: date | None = None,
) -> list[MatchResponse]:
    query = db.query(Match).options(joinedload(Match.batch))
    if date_from:
        query = query.filter(Match.date >= date_from)
    if date_to:
        query = query.filter(Match.date <= date_to)
    return [_match_response(match) for match in query.order_by(Match.date, Match.start).all()]


def update_match(db: Session, match_id: int, payload: MatchUpdate) -> MatchResponse:
    match = require_record(
        db.query(Match).options(joinedload(Match.batch)).filter(Match.match_id == match_id).first(),
        "Match not found",
    )
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise AppError(422, "No fixture changes were sent")
    if "batch_id" in changes:
        require_record(db.get(Batch, changes["batch_id"]), "Batch not found")
    for field, value in changes.items():
        setattr(match, field, value)
    db.commit()
    db.refresh(match)
    return _match_response(match)


def get_match(db: Session, match_id: int) -> MatchResponse:
    match = require_record(
        db.query(Match).options(joinedload(Match.batch)).filter(Match.match_id == match_id).first(),
        "Match not found",
    )
    return _match_response(match)
