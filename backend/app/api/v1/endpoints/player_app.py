from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.core.exceptions import ConflictError, NotFoundError
from app.core.security import hash_password
from app.models import Student, User, UserRole
from app.schemas import (
    MatchResponse,
    PlayerAttendanceItem,
    PlayerHomeResponse,
    PlayerSessionItem,
    PlayerSessionResponseUpdate,
    StudentResponse,
    StudentUpdate,
)
from app.services.player_service import (
    get_player_home,
    list_player_attendance,
    list_player_matches,
    list_player_sessions,
    update_player_session_response,
)

router = APIRouter(prefix="/player", tags=["Player"])


def _player_student(db: Session, current: CurrentUser) -> Student:
    student = db.query(Student).filter(Student.user_id == current.user.user_id).first()
    if student is None:
        raise NotFoundError("Player profile not found")
    return student


@router.get("/home", response_model=PlayerHomeResponse)
def read_player_home(
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> PlayerHomeResponse:
    return get_player_home(db, current)


@router.get("/sessions", response_model=list[PlayerSessionItem])
def read_player_sessions(
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> list[PlayerSessionItem]:
    return list_player_sessions(db, current)


@router.put("/sessions/{session_id}/response", response_model=PlayerSessionItem)
def update_session_response(
    session_id: int,
    payload: PlayerSessionResponseUpdate,
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> PlayerSessionItem:
    """Check in to a session, or skip it with a reason. An empty reason undoes the skip."""
    return update_player_session_response(db, current, session_id, payload)


@router.get("/matches", response_model=list[MatchResponse])
def read_player_matches(
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> list[MatchResponse]:
    return list_player_matches(db, current)


@router.get("/attendance", response_model=list[PlayerAttendanceItem])
def read_player_attendance(
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> list[PlayerAttendanceItem]:
    return list_player_attendance(db, current)


@router.get("/profile", response_model=StudentResponse)
def get_player_profile(
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> StudentResponse:
    return StudentResponse.model_validate(_player_student(db, current))


@router.patch("/profile", response_model=StudentResponse)
def update_player_profile(
    payload: StudentUpdate,
    current: CurrentUser = Depends(require_roles(UserRole.PLAYER)),
    db: Session = Depends(get_db),
) -> StudentResponse:
    student = _player_student(db, current)
    data = payload.model_dump(exclude_unset=True)
    password = data.pop("password", None)
    email = data.pop("email", None)
    if password:
        current.user.password_hash = hash_password(password)
    if email and email != current.user.email:
        if db.query(User).filter(User.email == email, User.user_id != current.user.user_id).first():
            raise ConflictError("That email is already in use")
        current.user.email = email
    if "name" not in data and ("first_name" in data or "last_name" in data):
        first = data.get("first_name", student.first_name) or ""
        last = data.get("last_name", student.last_name) or ""
        data["name"] = f"{first} {last}".strip() or student.name
    for field, value in data.items():
        setattr(student, field, value)
    db.commit()
    db.refresh(student)
    return StudentResponse.model_validate(student)
