from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import SuperAdminResponse, SuperAdminUpdate
from app.services.people_service import list_admins, update_admin

router = APIRouter(prefix="/admins", tags=["Admins"])


@router.get("", response_model=list[SuperAdminResponse])
def read_admins(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> list[SuperAdminResponse]:
    return list_admins(db, current)


@router.patch("/{admin_id}", response_model=SuperAdminResponse)
def edit_admin(
    admin_id: int,
    payload: SuperAdminUpdate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> SuperAdminResponse:
    return update_admin(db, current, admin_id, payload)
