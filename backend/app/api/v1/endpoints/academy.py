from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, get_current_user
from app.schemas import AcademyResponse
from app.services.academy_service import get_academy

router = APIRouter(prefix="/academy", tags=["Academy"])


@router.get("", response_model=AcademyResponse)
def read_academy(
    current: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AcademyResponse:
    return get_academy(db, current)
