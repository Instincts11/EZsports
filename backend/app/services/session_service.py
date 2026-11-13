from datetime import datetime, timedelta, timezone

from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import create_access_token
from app.core.sessions import DAILY_ROLES, day_ends_at, day_starts_at
from app.models import User
from app.schemas import TokenResponse


def start_session(db: Session, user: User) -> TokenResponse:
    now = datetime.now(timezone.utc)
    user.is_logged_in = True
    user.logged_in_at = now
    db.commit()
    if user.role in DAILY_ROLES:
        expires_at = day_ends_at(now)
    else:
        expires_at = now + timedelta(minutes=settings.access_token_expire_minutes)
    token = create_access_token(str(user.user_id), user.role.value, expires_at)
    return TokenResponse(access_token=token, role=user.role, expires_at=expires_at)


def end_session(db: Session, user: User) -> None:
    user.is_logged_in = False
    db.commit()


def reset_finished_sessions(db: Session) -> int:
    today_starts = day_starts_at(datetime.now(timezone.utc))
    count = (
        db.query(User)
        .filter(
            User.is_logged_in.is_(True),
            User.role.in_(DAILY_ROLES),
            or_(User.logged_in_at.is_(None), User.logged_in_at < today_starts),
        )
        .update({User.is_logged_in: False}, synchronize_session=False)
    )
    db.commit()
    return count
