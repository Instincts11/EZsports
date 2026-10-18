from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import UserRole

if TYPE_CHECKING:
    from app.models.accountant import Accountant
    from app.models.coach import Coach
    from app.models.student import Student
    from app.models.super_admin import SuperAdmin


class User(Base):
    __tablename__ = "users"

    user_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[UserRole] = mapped_column(default=UserRole.COACH)
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    super_admin: Mapped["SuperAdmin | None"] = relationship(back_populates="user")
    accountant: Mapped["Accountant | None"] = relationship(back_populates="user")
    coach: Mapped["Coach | None"] = relationship(back_populates="user")
    student: Mapped["Student | None"] = relationship(back_populates="user")
