from datetime import date

from sqlalchemy.orm import Session

from app.core.exceptions import ConflictError, NotFoundError, UnauthorizedError
from app.core.security import create_access_token, hash_password, verify_password
from app.models import Accountant, Coach, SuperAdmin, User, UserRole
from app.schemas import LoginRequest, MeResponse, TokenResponse


def authenticate(db: Session, payload: LoginRequest) -> TokenResponse:
    user = db.query(User).filter(User.email == payload.email).first()
    if user is None or not verify_password(payload.password, user.password_hash):
        raise UnauthorizedError("Invalid email or password")
    token = create_access_token(str(user.user_id), user.role.value)
    return TokenResponse(access_token=token, role=user.role)


def get_me(db: Session, user: User) -> MeResponse:
    name = None
    academy_id = None
    admin_id = None
    accountant_id = None
    coach_id = None

    if user.role == UserRole.SUPER_ADMIN and user.super_admin:
        name = user.super_admin.name
        academy_id = user.super_admin.academy_id
        admin_id = user.super_admin.admin_id
    elif user.role == UserRole.ACCOUNTANT and user.accountant:
        name = user.accountant.name
        admin_id = user.accountant.admin_id
        accountant_id = user.accountant.accountant_id
        academy_id = user.accountant.super_admin.academy_id
    elif user.role == UserRole.COACH and user.coach:
        name = user.coach.name
        admin_id = user.coach.admin_id
        coach_id = user.coach.coach_id
        academy_id = user.coach.super_admin.academy_id

    return MeResponse(
        user_id=user.user_id,
        email=user.email,
        role=user.role,
        name=name,
        academy_id=academy_id,
        admin_id=admin_id,
        accountant_id=accountant_id,
        coach_id=coach_id,
    )


def create_login_user(db: Session, email: str, password: str, role: UserRole) -> User:
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise ConflictError("A user with this email already exists")
    user = User(email=email, password_hash=hash_password(password), role=role)
    db.add(user)
    db.flush()
    return user


def require_record(record, detail: str):
    if record is None:
        raise NotFoundError(detail)
    return record


def today() -> date:
    return date.today()
