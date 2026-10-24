from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import SuperAdminResponse
from app.services.people_service import list_admins

router = APIRouter(prefix="/admins", tags=["Admins"])


@router.get("", response_model=list[SuperAdminResponse])
def read_admins(
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> list[SuperAdminResponse]:
    return list_admins(db, current)
