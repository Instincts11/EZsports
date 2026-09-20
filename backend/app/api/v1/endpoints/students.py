from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import StudentCreate, StudentResponse, StudentUpdate
from app.services.people_service import create_student, get_student, list_students, update_student

router = APIRouter(prefix="/students", tags=["Students"])


@router.post("", response_model=StudentResponse)
def add_student(
    payload: StudentCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> StudentResponse:
    return create_student(db, current, payload)


@router.get("", response_model=list[StudentResponse])
def read_students(
    batch_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH, UserRole.ACCOUNTANT)),
) -> list[StudentResponse]:
    return list_students(db, current, batch_id)


@router.get("/{student_id}", response_model=StudentResponse)
def read_student(
    student_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH, UserRole.ACCOUNTANT)),
) -> StudentResponse:
    return get_student(db, student_id)


@router.patch("/{student_id}", response_model=StudentResponse)
def edit_student(
    student_id: int,
    payload: StudentUpdate,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> StudentResponse:
    return update_student(db, student_id, payload)
