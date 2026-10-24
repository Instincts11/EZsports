from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import CoachCreate, CoachResponse, CoachUpdate, MessageResponse
from app.services.people_service import create_coach, delete_coach, get_coach, list_coaches, update_coach

router = APIRouter(prefix="/coaches", tags=["Coaches"])


@router.post("", response_model=CoachResponse)
def add_coach(
    payload: CoachCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> CoachResponse:
    return create_coach(db, current, payload)


@router.get("", response_model=list[CoachResponse])
def read_coaches(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH, UserRole.ACCOUNTANT)),
) -> list[CoachResponse]:
    return list_coaches(db, current)


@router.delete("/{coach_id}", response_model=MessageResponse)
def remove_coach(
    coach_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> MessageResponse:
    delete_coach(db, coach_id)
    return MessageResponse(message="Coach deleted")


@router.get("/{coach_id}", response_model=CoachResponse)
def read_coach(
    coach_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH, UserRole.ACCOUNTANT)),
) -> CoachResponse:
    return get_coach(db, coach_id)


@router.patch("/{coach_id}", response_model=CoachResponse)
def edit_coach(
    coach_id: int,
    payload: CoachUpdate,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> CoachResponse:
    return update_coach(db, coach_id, payload)
