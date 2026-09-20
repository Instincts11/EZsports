from dataclasses import dataclass

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.exceptions import ForbiddenError, UnauthorizedError
from app.models import Accountant, Coach, SuperAdmin, User, UserRole

bearer_scheme = HTTPBearer(auto_error=False)


@dataclass
class CurrentUser:
    user: User
    role: UserRole
    academy_id: int | None = None
    admin_id: int | None = None
    accountant_id: int | None = None
    coach_id: int | None = None


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> CurrentUser:
    if credentials is None or not credentials.credentials:
        raise UnauthorizedError()
    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.secret_key,
            algorithms=[settings.algorithm],
        )
        user_id = payload.get("sub")
        if user_id is None:
            raise UnauthorizedError()
    except JWTError as exc:
        raise UnauthorizedError("Invalid or expired token") from exc

    user = db.get(User, int(user_id))
    if user is None or not user.is_active:
        raise UnauthorizedError()

    current = CurrentUser(user=user, role=user.role)

    if user.role == UserRole.SUPER_ADMIN:
        admin = db.query(SuperAdmin).filter(SuperAdmin.user_id == user.user_id).first()
        if admin:
            current.admin_id = admin.admin_id
            current.academy_id = admin.academy_id
    elif user.role == UserRole.ACCOUNTANT:
        accountant = db.query(Accountant).filter(Accountant.user_id == user.user_id).first()
        if accountant:
            current.accountant_id = accountant.accountant_id
            current.admin_id = accountant.admin_id
            current.academy_id = accountant.super_admin.academy_id
    elif user.role == UserRole.COACH:
        coach = db.query(Coach).filter(Coach.user_id == user.user_id).first()
        if coach:
            current.coach_id = coach.coach_id
            current.admin_id = coach.admin_id
            current.academy_id = coach.super_admin.academy_id

    return current


def require_roles(*roles: UserRole):
    def _checker(current: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if current.role not in roles:
            raise ForbiddenError()
        return current

    return _checker
