from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import AccountantCreate, AccountantResponse
from app.services.people_service import assign_accountant, get_my_accountant, list_accountants

router = APIRouter(prefix="/accountants", tags=["Accountants"])


@router.post("", response_model=AccountantResponse)
def create_accountant(
    payload: AccountantCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> AccountantResponse:
    return assign_accountant(db, current, payload)


@router.get("/me", response_model=AccountantResponse)
def read_my_accountant(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.ACCOUNTANT)),
) -> AccountantResponse:
    return get_my_accountant(db, current)


@router.get("", response_model=list[AccountantResponse])
def read_accountants(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.ACCOUNTANT)),
) -> list[AccountantResponse]:
    return list_accountants(db, current)
