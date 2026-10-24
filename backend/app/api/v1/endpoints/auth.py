from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, get_current_user
from app.core.exceptions import AppError
from app.core.security import hash_password, verify_password
from app.schemas import (
    ChangePasswordRequest,
    EmailRequest,
    LoginRequest,
    MeResponse,
    MessageResponse,
    MobileRequest,
    OtpRequestResponse,
    OtpVerifyRequest,
    PlayerSignupRequest,
    TokenResponse,
)
from app.services import authenticate, get_me
from app.services.signup_service import (
    request_login_otp,
    request_signup_otp,
    send_login_password,
    verify_login_otp,
    verify_signup_otp,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    return authenticate(db, payload)


@router.post(
    "/login/send-password",
    response_model=MessageResponse,
    summary="Email a sign-in password",
)
def login_send_password(payload: EmailRequest, db: Session = Depends(get_db)) -> MessageResponse:
    """Sends a password to the coach or player email. It is typed in from that message."""
    return send_login_password(db, payload)


@router.post(
    "/signup/request-otp",
    response_model=OtpRequestResponse,
    summary="Request one-time signup OTP",
)
def signup_request_otp(payload: PlayerSignupRequest, db: Session = Depends(get_db)) -> OtpRequestResponse:
    """Stores signup details temporarily and issues a one-time OTP for initial registration."""
    return request_signup_otp(db, payload)


@router.post(
    "/signup/verify-otp",
    response_model=TokenResponse,
    summary="Verify signup OTP and create player account",
)
def signup_verify_otp(payload: OtpVerifyRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Consumes the OTP once, persists all signup data, and returns a login token."""
    return verify_signup_otp(db, payload)


@router.post(
    "/login/request-otp",
    response_model=OtpRequestResponse,
    summary="Send a login OTP for a coach or player mobile",
)
def login_request_otp(payload: MobileRequest, db: Session = Depends(get_db)) -> OtpRequestResponse:
    """Finds the coach or player for this mobile and issues a one-time code."""
    return request_login_otp(db, payload)


@router.post(
    "/login/verify-otp",
    response_model=TokenResponse,
    summary="Verify login OTP and authorize coach or player",
)
def login_verify_otp(payload: OtpVerifyRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Consumes the OTP and returns a token for the matching coach or player."""
    return verify_login_otp(db, payload)


@router.get(
    "/me",
    response_model=MeResponse,
    summary="Current user",
)
def me(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)) -> MeResponse:
    """Requires `Authorization: Bearer <access_token>` from POST /api/v1/auth/login."""
    return get_me(db, current.user)


@router.post(
    "/change-password",
    response_model=MessageResponse,
    summary="Change the signed-in user's password",
)
def change_password(
    payload: ChangePasswordRequest,
    current: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    if not verify_password(payload.current_password, current.user.password_hash):
        raise AppError(400, "Current password is incorrect")
    if len(payload.new_password) < 6:
        raise AppError(400, "New password must be at least 6 characters")
    current.user.password_hash = hash_password(payload.new_password)
    db.commit()
    return MessageResponse(message="Password updated")
