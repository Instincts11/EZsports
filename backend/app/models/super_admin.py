from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.academy import Academy
    from app.models.accountant import Accountant
    from app.models.coach import Coach
    from app.models.session_assignment import SessionAssignment
    from app.models.student import Student
    from app.models.user import User


class SuperAdmin(Base):
    __tablename__ = "super_admins"

    admin_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.user_id"), unique=True)
    academy_id: Mapped[int] = mapped_column(ForeignKey("academies.academy_id"))
    name: Mapped[str] = mapped_column(String(255))
    mobile: Mapped[str | None] = mapped_column(String(20), nullable=True)

    user: Mapped["User"] = relationship(back_populates="super_admin")
    academy: Mapped["Academy"] = relationship(back_populates="super_admins")
    accountants: Mapped[list["Accountant"]] = relationship(back_populates="super_admin")
    coaches: Mapped[list["Coach"]] = relationship(back_populates="super_admin")
    students: Mapped[list["Student"]] = relationship(back_populates="super_admin")
    session_assignments: Mapped[list["SessionAssignment"]] = relationship(back_populates="assigned_by_admin")
