from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.core.exceptions import NotFoundError
from app.models import Student, UserRole
from app.schemas import StudentResponse, StudentUpdate

router = APIRouter(prefix="/player", tags=["Player"])


def _player_student(db: Session, current: CurrentUser) -> Student:
    student = db.query(Student).filter(Student.user_id == current.user.user_id).first()
    if student is None:
        raise NotFoundError("Player profile not found")
    return student


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
    if "name" not in data and ("first_name" in data or "last_name" in data):
        first = data.get("first_name", student.first_name) or ""
        last = data.get("last_name", student.last_name) or ""
        data["name"] = f"{first} {last}".strip() or student.name
    for field, value in data.items():
        setattr(student, field, value)
    db.commit()
    db.refresh(student)
    return StudentResponse.model_validate(student)
