from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, get_current_user
from app.schemas import LoginRequest, MeResponse, TokenResponse
from app.services import authenticate, get_me

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    return authenticate(db, payload)


@router.get(
    "/me",
    response_model=MeResponse,
    summary="Current user",
)
def me(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)) -> MeResponse:
    """Requires `Authorization: Bearer <access_token>` from POST /api/v1/auth/login."""
    return get_me(db, current.user)
