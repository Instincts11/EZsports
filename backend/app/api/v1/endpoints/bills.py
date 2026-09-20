from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import BillCreate, BillResponse, BillUpdate
from app.services.finance_service import create_bill, list_bills, update_bill

router = APIRouter(prefix="/bills", tags=["Bills"])


@router.post("", response_model=BillResponse)
def add_bill(
    payload: BillCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.ACCOUNTANT)),
) -> BillResponse:
    return create_bill(db, current, payload)


@router.get("", response_model=list[BillResponse])
def read_bills(
    student_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.ACCOUNTANT, UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[BillResponse]:
    return list_bills(db, student_id)


@router.patch("/{bill_id}", response_model=BillResponse)
def edit_bill(
    bill_id: int,
    payload: BillUpdate,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.ACCOUNTANT)),
) -> BillResponse:
    return update_bill(db, bill_id, payload)
