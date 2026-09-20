from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.core.exceptions import ForbiddenError
from app.models.enums import UserRole
from app.schemas import HomeDashboardResponse, LeaveCreate, LeaveResponse, MatchCreate, MatchResponse
from app.services.attendance_service import create_leave, list_leaves
from app.services.home_service import create_match, get_home_dashboard, get_match, list_matches
from app.services.people_service import get_coach, update_coach
from app.schemas import CoachResponse, CoachUpdate

router = APIRouter(tags=["Coach App"])


@router.get("/home", response_model=HomeDashboardResponse)
def home(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.COACH, UserRole.SUPER_ADMIN)),
) -> HomeDashboardResponse:
    return get_home_dashboard(db, current)


@router.get("/matches", response_model=list[MatchResponse])
def read_matches(
    date_from: date | None = Query(default=None),
    date_to: date | None = Query(default=None),
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[MatchResponse]:
    return list_matches(db, date_from, date_to)


@router.post("/matches", response_model=MatchResponse)
def add_match(
    payload: MatchCreate,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> MatchResponse:
    return create_match(db, payload)


@router.get("/matches/{match_id}", response_model=MatchResponse)
def read_match(
    match_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> MatchResponse:
    return get_match(db, match_id)


@router.get("/profile", response_model=CoachResponse)
def read_profile(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.COACH)),
) -> CoachResponse:
    if current.coach_id is None:
        raise ForbiddenError()
    return get_coach(db, current.coach_id)


@router.patch("/profile", response_model=CoachResponse)
def edit_profile(
    payload: CoachUpdate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.COACH)),
) -> CoachResponse:
    if current.coach_id is None:
        raise ForbiddenError()
    return update_coach(db, current.coach_id, payload)


@router.get("/leaves", response_model=list[LeaveResponse])
def read_leaves(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.COACH, UserRole.SUPER_ADMIN)),
) -> list[LeaveResponse]:
    return list_leaves(db, current)


@router.post("/leaves", response_model=LeaveResponse)
def add_leave(
    payload: LeaveCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.COACH)),
) -> LeaveResponse:
    return create_leave(db, current, payload)
