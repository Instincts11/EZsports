from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, get_current_user, require_roles
from app.models.enums import UserRole
from app.schemas import AcademyResponse, AcademyUpdate
from app.services.academy_service import get_academy, update_academy

router = APIRouter(prefix="/academy", tags=["Academy"])


@router.get("", response_model=AcademyResponse)
def read_academy(
    current: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AcademyResponse:
    return get_academy(db, current)


@router.patch("", response_model=AcademyResponse)
def edit_academy(
    payload: AcademyUpdate,
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
    db: Session = Depends(get_db),
) -> AcademyResponse:
    return update_academy(db, current, payload)
