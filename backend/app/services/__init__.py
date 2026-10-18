from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictError, NotFoundError, UnauthorizedError
from app.core.security import create_access_token, hash_password, verify_password
from app.models import Accountant, Coach, Student, SuperAdmin, User, UserRole
from app.schemas import LoginRequest, MeResponse, TokenResponse

_APP_ROLES = (UserRole.COACH, UserRole.PLAYER, UserRole.SUPER_ADMIN, UserRole.ACCOUNTANT)


def _mobile_key(raw: str) -> str | None:
    digits = "".join(ch for ch in raw if ch.isdigit())
    if len(digits) < 10:
        return None
    return digits[-10:]


def _candidates_for_identifier(db: Session, identifier: str) -> list[User]:
    cleaned = identifier.strip()
    if not cleaned:
        return []
    if "@" in cleaned:
        user = db.query(User).filter(func.lower(User.email) == cleaned.lower()).first()
        return [user] if user is not None else []

    mobile = _mobile_key(cleaned)
    if mobile is None:
        return []

    matches: list[User] = []
    coaches = db.query(Coach).filter(func.substr(Coach.mobile, -10) == mobile).all()
    students = (
        db.query(Student)
        .filter(Student.user_id.isnot(None), func.substr(Student.mobile, -10) == mobile)
        .all()
    )
    for record in (*coaches, *students):
        user = record.user
        if user is not None and all(existing.user_id != user.user_id for existing in matches):
            matches.append(user)
    return matches


def authenticate(db: Session, payload: LoginRequest) -> TokenResponse:
    from app.services.signup_service import consume_emailed_password

    candidates = _candidates_for_identifier(db, payload.identifier)
    matched = [
        user
        for user in candidates
        if user.is_active and verify_password(payload.password, user.password_hash)
    ]
    if not matched:
        matched = [
            user
            for user in candidates
            if user.is_active
            and user.role in _APP_ROLES
            and consume_emailed_password(db, user, payload.password)
        ]
    if len(matched) > 1:
        raise UnauthorizedError("This number matches more than one account. Sign in with email.")
    if len(matched) != 1:
        raise UnauthorizedError("Invalid email, mobile, or password")
    user = matched[0]
    if user.role not in _APP_ROLES:
        raise UnauthorizedError("This account cannot sign in here")
    token = create_access_token(str(user.user_id), user.role.value)
    return TokenResponse(access_token=token, role=user.role)


def get_me(db: Session, user: User) -> MeResponse:
    name = None
    academy_id = None
    admin_id = None
    accountant_id = None
    coach_id = None
    student_id = None

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
    elif user.role == UserRole.PLAYER:
        student = db.query(Student).filter(Student.user_id == user.user_id).first()
        if student:
            name = student.name
            admin_id = student.admin_id
            student_id = student.student_id
            if student.super_admin:
                academy_id = student.super_admin.academy_id

    return MeResponse(
        user_id=user.user_id,
        email=user.email,
        role=user.role,
        name=name,
        academy_id=academy_id,
        admin_id=admin_id,
        accountant_id=accountant_id,
        coach_id=coach_id,
        student_id=student_id,
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
