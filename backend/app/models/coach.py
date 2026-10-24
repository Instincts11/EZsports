from __future__ import annotations

from datetime import date
from typing import TYPE_CHECKING

from sqlalchemy import Date, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.bill import Bill
    from app.models.coach_attendance import CoachAttendance
    from app.models.leave import Leave
    from app.models.session_assignment import SessionAssignment
    from app.models.student_attendance import StudentAttendance
    from app.models.super_admin import SuperAdmin
    from app.models.user import User


class Coach(Base):
    __tablename__ = "coaches"

    coach_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.user_id"), unique=True)
    admin_id: Mapped[int] = mapped_column(ForeignKey("super_admins.admin_id"))
    name: Mapped[str] = mapped_column(String(255))
    mobile: Mapped[str] = mapped_column(String(20))
    dob: Mapped[date | None] = mapped_column(Date, nullable=True)
    gender: Mapped[str | None] = mapped_column(String(20), nullable=True)
    emergency_contact: Mapped[str | None] = mapped_column(String(20), nullable=True)
    certifications: Mapped[str | None] = mapped_column(Text, nullable=True)
    experience: Mapped[str | None] = mapped_column(String(255), nullable=True)
    headline: Mapped[str | None] = mapped_column(String(255), nullable=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    photo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    user: Mapped["User"] = relationship(back_populates="coach")
    super_admin: Mapped["SuperAdmin"] = relationship(back_populates="coaches")
    assignments: Mapped[list["SessionAssignment"]] = relationship(back_populates="coach")
    attendances: Mapped[list["CoachAttendance"]] = relationship(back_populates="coach")
    marked_student_attendances: Mapped[list["StudentAttendance"]] = relationship(back_populates="marked_by_coach")
    leaves: Mapped[list["Leave"]] = relationship(back_populates="coach")
    bills: Mapped[list["Bill"]] = relationship(back_populates="coach")
