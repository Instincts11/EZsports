from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import AttendanceStatus

if TYPE_CHECKING:
    from app.models.coach import Coach
    from app.models.session import Session
    from app.models.student import Student


class StudentAttendance(Base):
    __tablename__ = "student_attendances"
    __table_args__ = (UniqueConstraint("session_id", "student_id", name="uq_student_attendance_session"),)

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    session_id: Mapped[int] = mapped_column(ForeignKey("sessions.session_id"))
    student_id: Mapped[int] = mapped_column(ForeignKey("students.student_id"))
    marked_by_coach_id: Mapped[int] = mapped_column(ForeignKey("coaches.coach_id"))
    status: Mapped[AttendanceStatus] = mapped_column(default=AttendanceStatus.PRESENT)

    session: Mapped["Session"] = relationship(back_populates="student_attendances")
    student: Mapped["Student"] = relationship(back_populates="attendances")
    marked_by_coach: Mapped["Coach"] = relationship(back_populates="marked_student_attendances")
