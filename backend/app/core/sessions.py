from datetime import date, datetime, time, timedelta, timezone

from app.models import User
from app.models.enums import UserRole

ACADEMY_TZ = timezone(timedelta(hours=5, minutes=30))
DAILY_ROLES = (UserRole.COACH, UserRole.PLAYER)


def academy_day(moment: datetime) -> date:
    if moment.tzinfo is None:
        moment = moment.replace(tzinfo=timezone.utc)
    return moment.astimezone(ACADEMY_TZ).date()


def day_starts_at(moment: datetime) -> datetime:
    return datetime.combine(academy_day(moment), time.min, tzinfo=ACADEMY_TZ)


def day_ends_at(moment: datetime) -> datetime:
    return day_starts_at(moment) + timedelta(days=1)


def session_is_current(user: User, now: datetime) -> bool:
    return bool(user.is_logged_in) and user.logged_in_at is not None and academy_day(user.logged_in_at) == academy_day(now)
