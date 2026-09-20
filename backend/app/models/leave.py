from __future__ import annotations

from datetime import date
from typing import TYPE_CHECKING

from sqlalchemy import Date, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import LeaveStatus

if TYPE_CHECKING:
    from app.models.coach import Coach


class Leave(Base):
    __tablename__ = "leaves"

    leave_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    coach_id: Mapped[int] = mapped_column(ForeignKey("coaches.coach_id"))
    from_date: Mapped[date] = mapped_column(Date)
    to_date: Mapped[date] = mapped_column(Date)
    reason: Mapped[str] = mapped_column(Text)
    status: Mapped[LeaveStatus] = mapped_column(default=LeaveStatus.PENDING)

    coach: Mapped["Coach"] = relationship(back_populates="leaves")
