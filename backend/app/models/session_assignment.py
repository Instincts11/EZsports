from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.coach import Coach
    from app.models.session import Session
    from app.models.super_admin import SuperAdmin


class SessionAssignment(Base):
    __tablename__ = "session_assignments"
    __table_args__ = (UniqueConstraint("session_id", "coach_id", name="uq_assignment_session_coach"),)

    assignment_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    session_id: Mapped[int] = mapped_column(ForeignKey("sessions.session_id"))
    coach_id: Mapped[int] = mapped_column(ForeignKey("coaches.coach_id"))
    assigned_by: Mapped[int] = mapped_column(ForeignKey("super_admins.admin_id"))

    session: Mapped["Session"] = relationship(back_populates="assignments")
    coach: Mapped["Coach"] = relationship(back_populates="assignments")
    assigned_by_admin: Mapped["SuperAdmin"] = relationship(back_populates="session_assignments")
