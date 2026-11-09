from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.academy import Academy
    from app.models.coach import Coach
    from app.models.enrollment import Enrollment
    from app.models.match import Match
    from app.models.session import Session


class Batch(Base):
    __tablename__ = "batches"

    batch_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    academy_id: Mapped[int] = mapped_column(ForeignKey("academies.academy_id"))
    name: Mapped[str] = mapped_column(String(255))
    days: Mapped[str] = mapped_column(String(100))
    sport: Mapped[str] = mapped_column(String(100))
    centre: Mapped[str | None] = mapped_column(String(255), nullable=True)
    meeting_point: Mapped[str | None] = mapped_column(String(255), nullable=True)
    focus: Mapped[str | None] = mapped_column(String(255), nullable=True)
    kit: Mapped[str | None] = mapped_column(String(255), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    coach_id: Mapped[int | None] = mapped_column(ForeignKey("coaches.coach_id"), nullable=True)

    academy: Mapped["Academy"] = relationship(back_populates="batches")
    coach: Mapped["Coach | None"] = relationship()
    enrollments: Mapped[list["Enrollment"]] = relationship(back_populates="batch")
    sessions: Mapped[list["Session"]] = relationship(back_populates="batch")
    matches: Mapped[list["Match"]] = relationship(back_populates="batch")
