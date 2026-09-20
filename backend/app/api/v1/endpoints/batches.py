from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import BatchCreate, BatchResponse, EnrollmentCreate, EnrollmentResponse, MessageResponse, StudentResponse
from app.services.operations_service import create_batch, enroll_student, get_batch, list_batches, unenroll_student
from app.services.people_service import list_students

router = APIRouter(prefix="/batches", tags=["Batches"])


@router.post("", response_model=BatchResponse)
def add_batch(
    payload: BatchCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> BatchResponse:
    return create_batch(db, current, payload)


@router.get("", response_model=list[BatchResponse])
def read_batches(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[BatchResponse]:
    return list_batches(db, current)


@router.get("/{batch_id}", response_model=BatchResponse)
def read_batch(
    batch_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> BatchResponse:
    return get_batch(db, batch_id)


@router.get("/{batch_id}/students", response_model=list[StudentResponse])
def read_batch_roster(
    batch_id: int,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[StudentResponse]:
    return list_students(db, current, batch_id)


@router.post("/enrollments", response_model=EnrollmentResponse)
def add_enrollment(
    payload: EnrollmentCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> EnrollmentResponse:
    return enroll_student(db, current, payload)


@router.delete("/enrollments/{enrollment_id}", response_model=MessageResponse, status_code=status.HTTP_200_OK)
def remove_enrollment(
    enrollment_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> MessageResponse:
    unenroll_student(db, enrollment_id)
    return MessageResponse(message="Enrollment removed")
