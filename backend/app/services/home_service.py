from datetime import date

from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import NotFoundError
from app.models import Academy, Batch, Match, Session as TrainingSession, SessionAssignment
from app.schemas import AttendanceSummary, HomeDashboardResponse, MatchCreate, MatchResponse
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
        joinedload(TrainingSession.assignments),
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
    return HomeDashboardResponse(
        academy_name=academy.name,
        date=today,
        sessions_today=len(sessions),
        attendance=summary or AttendanceSummary(days=0, attended=0, missed=0),
        upcoming_sessions=[_session_response(session) for session in sessions],
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
    )


def create_match(db: Session, payload: MatchCreate) -> MatchResponse:
    require_record(db.get(Batch, payload.batch_id), "Batch not found")
    match = Match(
        batch_id=payload.batch_id,
        title=payload.title,
        date=payload.date,
        start=payload.start,
        end=payload.end,
        opponent=payload.opponent,
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


def get_match(db: Session, match_id: int) -> MatchResponse:
    match = require_record(
        db.query(Match).options(joinedload(Match.batch)).filter(Match.match_id == match_id).first(),
        "Match not found",
    )
    return _match_response(match)
