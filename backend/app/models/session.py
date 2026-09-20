from __future__ import annotations

from datetime import date, time
from typing import TYPE_CHECKING

from sqlalchemy import Date, ForeignKey, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.batch import Batch
    from app.models.coach_attendance import CoachAttendance
    from app.models.session_assignment import SessionAssignment
    from app.models.student_attendance import StudentAttendance


class Session(Base):
    __tablename__ = "sessions"

    session_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    batch_id: Mapped[int] = mapped_column(ForeignKey("batches.batch_id"))
    date: Mapped[date] = mapped_column(Date, index=True)
    start: Mapped[time] = mapped_column(Time)
    end: Mapped[time] = mapped_column(Time)

    batch: Mapped["Batch"] = relationship(back_populates="sessions")
    assignments: Mapped[list["SessionAssignment"]] = relationship(back_populates="session")
    coach_attendances: Mapped[list["CoachAttendance"]] = relationship(back_populates="session")
    student_attendances: Mapped[list["StudentAttendance"]] = relationship(back_populates="session")
