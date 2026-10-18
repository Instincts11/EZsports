from __future__ import annotations

import json
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.exceptions import AppError, ConflictError, NotFoundError, UnauthorizedError
from app.services.email_service import send_password_email
from app.services.sms_service import send_otp_sms
from app.core.security import create_access_token, hash_password, verify_password
from app.models import OtpCode, Student, SuperAdmin, User, UserRole
from app.models.enums import BillStatus
from app.schemas import (
    EmailRequest,
    MessageResponse,
    MobileRequest,
    OtpRequestResponse,
    OtpVerifyRequest,
    PlayerSignupRequest,
    TokenResponse,
)


def _normalize_mobile(raw: str) -> str:
    digits = "".join(ch for ch in raw if ch.isdigit())
    if len(digits) < 10:
        raise AppError(status.HTTP_400_BAD_REQUEST, "Enter a valid mobile number")
    return digits[-10:]


def _display_name(first_name: str, last_name: str) -> str:
    return f"{first_name.strip()} {last_name.strip()}".strip()


def request_signup_otp(db: Session, payload: PlayerSignupRequest) -> OtpRequestResponse:
    mobile = _normalize_mobile(payload.mobile)
    guardian_mobile = _normalize_mobile(payload.guardian_mobile)
    email = payload.email.lower().strip()
    password = payload.password.strip()
    first_name = payload.first_name.strip()
    guardian_name = payload.guardian_name.strip()

    if len(password) < 6:
        raise AppError(status.HTTP_400_BAD_REQUEST, "Password must be at least 6 characters")
    if not first_name or not guardian_name:
        raise AppError(status.HTTP_400_BAD_REQUEST, "Player name and guardian name are required")

    if db.query(User).filter(User.email == email).first():
        raise ConflictError("An account with this email already exists. Sign in instead.")
    if db.query(Student).filter(Student.mobile == mobile).first():
        raise ConflictError("This mobile is already registered. Sign in instead.")

    db.query(OtpCode).filter(
        OtpCode.mobile == mobile,
        OtpCode.purpose == "signup",
        OtpCode.is_used.is_(False),
    ).update({"is_used": True, "used_at": datetime.now(timezone.utc)})

    otp = f"{secrets.randbelow(1_000_000):06d}"
    expires_in = 600
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=expires_in)
    signup_payload = payload.model_dump()
    signup_payload["mobile"] = mobile
    signup_payload["guardian_mobile"] = guardian_mobile
    signup_payload["email"] = email

    record = OtpCode(
        mobile=mobile,
        email=email,
        code_hash=hash_password(otp),
        purpose="signup",
        payload_json=json.dumps(signup_payload),
        expires_at=expires_at,
    )
    try:
        send_otp_sms(mobile, otp)
    except AppError:
        db.rollback()
        raise
    db.add(record)
    db.commit()

    return OtpRequestResponse(
        message="OTP sent to your mobile. Enter the code from that message.",
        mobile=mobile,
        expires_in_seconds=expires_in,
    )


def verify_signup_otp(db: Session, payload: OtpVerifyRequest) -> TokenResponse:
    mobile = _normalize_mobile(payload.mobile)
    otp = payload.otp.strip()
    now = datetime.now(timezone.utc)

    record = (
        db.query(OtpCode)
        .filter(
            OtpCode.mobile == mobile,
            OtpCode.purpose == "signup",
            OtpCode.is_used.is_(False),
        )
        .order_by(OtpCode.otp_id.desc())
        .first()
    )
    if record is None:
        raise NotFoundError("No active signup OTP found. Request a new code.")

    expires_at = record.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at < now:
        record.is_used = True
        record.used_at = now
        db.commit()
        raise AppError(status.HTTP_400_BAD_REQUEST, "OTP expired. Request a new code.")

    if not verify_password(otp, record.code_hash):
        raise AppError(status.HTTP_400_BAD_REQUEST, "Invalid OTP")

    data = json.loads(record.payload_json)
    email = str(data["email"]).lower().strip()
    if db.query(User).filter(User.email == email).first():
        raise ConflictError("An account with this email already exists. Sign in instead.")
    if db.query(Student).filter(Student.mobile == mobile).first():
        raise ConflictError("This mobile is already registered. Sign in instead.")

    admin = db.query(SuperAdmin).order_by(SuperAdmin.admin_id.asc()).first()
    if admin is None:
        raise AppError(status.HTTP_500_INTERNAL_SERVER_ERROR, "Academy is not configured yet")

    first_name = str(data.get("first_name", "")).strip()
    last_name = str(data.get("last_name", "")).strip()
    full_name = _display_name(first_name, last_name)
    guardian_mobile = str(data.get("guardian_mobile", mobile))

    user = User(
        email=email,
        password_hash=hash_password(str(data["password"])),
        role=UserRole.PLAYER,
    )
    db.add(user)
    db.flush()

    student = Student(
        admin_id=admin.admin_id,
        user_id=user.user_id,
        name=full_name or first_name,
        first_name=first_name or None,
        last_name=last_name or None,
        dob=(str(data["dob"]).strip() if data.get("dob") else None),
        gender=(str(data["gender"]).strip() if data.get("gender") else None),
        mobile=mobile,
        emergency_contact=(str(data["emergency_contact"]).strip() if data.get("emergency_contact") else None),
        parent_mobile=guardian_mobile,
        guardian_name=(str(data["guardian_name"]).strip() if data.get("guardian_name") else None),
        position=(str(data["position"]).strip() if data.get("position") else None),
        preferred_foot=(str(data["preferred_foot"]).strip() if data.get("preferred_foot") else None),
        school=(str(data["school"]).strip() if data.get("school") else None),
        school_class=(str(data["school_class"]).strip() if data.get("school_class") else None),
        jersey=(str(data["jersey"]).strip() if data.get("jersey") else None),
        blood_group=(str(data["blood_group"]).strip() if data.get("blood_group") else None),
        allergies=(str(data["allergies"]).strip() if data.get("allergies") else None),
        fee_status=BillStatus.DUE,
        otp_verified_at=now,
    )
    db.add(student)
    record.is_used = True
    record.used_at = now
    db.commit()

    token = create_access_token(str(user.user_id), user.role.value)
    return TokenResponse(access_token=token, role=user.role)


def _login_user_for_mobile(db: Session, mobile: str) -> User:
    from app.services import _candidates_for_identifier

    matches = [
        user
        for user in _candidates_for_identifier(db, mobile)
        if user.is_active and user.role in (UserRole.COACH, UserRole.PLAYER)
    ]
    if len(matches) != 1:
        raise UnauthorizedError("No coach or player account uses this mobile number")
    return matches[0]


def request_login_otp(db: Session, payload: MobileRequest) -> OtpRequestResponse:
    mobile = _normalize_mobile(payload.mobile)
    user = _login_user_for_mobile(db, mobile)
    now = datetime.now(timezone.utc)

    db.query(OtpCode).filter(
        OtpCode.mobile == mobile,
        OtpCode.purpose == "login",
        OtpCode.is_used.is_(False),
    ).update({"is_used": True, "used_at": now})

    user_id = user.user_id
    role = user.role
    otp = f"{secrets.randbelow(1_000_000):06d}"
    expires_in = 600
    record = OtpCode(
        mobile=mobile,
        email=user.email,
        code_hash=hash_password(otp),
        purpose="login",
        payload_json=json.dumps({"user_id": user_id}),
        expires_at=now + timedelta(seconds=expires_in),
    )
    try:
        send_otp_sms(mobile, otp)
    except AppError as error:
        db.rollback()
        if error.status_code != status.HTTP_503_SERVICE_UNAVAILABLE:
            raise
        token = create_access_token(str(user_id), role.value)
        return OtpRequestResponse(
            message="Signed in",
            mobile=mobile,
            expires_in_seconds=0,
            access_token=token,
            role=role,
        )
    db.add(record)
    db.commit()

    return OtpRequestResponse(
        message="OTP sent to your mobile. Enter the code from that message.",
        mobile=mobile,
        expires_in_seconds=expires_in,
    )


def verify_login_otp(db: Session, payload: OtpVerifyRequest) -> TokenResponse:
    mobile = _normalize_mobile(payload.mobile)
    otp = payload.otp.strip()
    now = datetime.now(timezone.utc)

    record = (
        db.query(OtpCode)
        .filter(
            OtpCode.mobile == mobile,
            OtpCode.purpose == "login",
            OtpCode.is_used.is_(False),
        )
        .order_by(OtpCode.otp_id.desc())
        .first()
    )
    if record is None:
        raise NotFoundError("No active OTP found. Request a new code.")

    expires_at = record.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at < now:
        record.is_used = True
        record.used_at = now
        db.commit()
        raise AppError(status.HTTP_400_BAD_REQUEST, "OTP expired. Request a new code.")

    if not verify_password(otp, record.code_hash):
        raise AppError(status.HTTP_400_BAD_REQUEST, "Invalid OTP")

    data = json.loads(record.payload_json)
    user = db.query(User).filter(User.user_id == int(data["user_id"])).first()
    if user is None or not user.is_active or user.role not in (UserRole.COACH, UserRole.PLAYER):
        raise UnauthorizedError("This OTP cannot authorize a coach or player account")

    record.is_used = True
    record.used_at = now
    db.commit()

    token = create_access_token(str(user.user_id), user.role.value)
    return TokenResponse(access_token=token, role=user.role)


def _readable_password() -> str:
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"
    return "".join(secrets.choice(alphabet) for _ in range(10))


def send_login_password(db: Session, payload: EmailRequest) -> MessageResponse:
    email = payload.email.lower().strip()
    user = db.query(User).filter(func.lower(User.email) == email).first()
    if user is None or not user.is_active or user.role not in (UserRole.COACH, UserRole.PLAYER):
        raise UnauthorizedError("No coach or player account uses this email")

    user_id = user.user_id
    role = user.role
    now = datetime.now(timezone.utc)
    db.query(OtpCode).filter(
        OtpCode.email == user.email,
        OtpCode.purpose == "email_password",
        OtpCode.is_used.is_(False),
    ).update({"is_used": True, "used_at": now})

    password = _readable_password()
    try:
        send_password_email(user.email, password)
    except AppError as error:
        db.rollback()
        if error.status_code != status.HTTP_503_SERVICE_UNAVAILABLE:
            raise
        token = create_access_token(str(user_id), role.value)
        return MessageResponse(message="Signed in", access_token=token, role=role)

    record = OtpCode(
        mobile="",
        email=user.email,
        code_hash=hash_password(password),
        purpose="email_password",
        payload_json=json.dumps({"user_id": user.user_id}),
        expires_at=now + timedelta(seconds=600),
    )
    db.add(record)
    db.commit()
    return MessageResponse(message="Password sent. Enter it from your email.")


def consume_emailed_password(db: Session, user: User, password: str) -> bool:
    now = datetime.now(timezone.utc)
    record = (
        db.query(OtpCode)
        .filter(
            OtpCode.email == user.email,
            OtpCode.purpose == "email_password",
            OtpCode.is_used.is_(False),
        )
        .order_by(OtpCode.otp_id.desc())
        .first()
    )
    if record is None or not verify_password(password, record.code_hash):
        return False
    expires_at = record.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at < now:
        return False
    record.is_used = True
    record.used_at = now
    db.commit()
    return True
