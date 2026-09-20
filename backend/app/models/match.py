from __future__ import annotations

from datetime import date, time
from typing import TYPE_CHECKING

from sqlalchemy import Date, ForeignKey, String, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import MatchStatus

if TYPE_CHECKING:
    from app.models.batch import Batch


class Match(Base):
    __tablename__ = "matches"

    match_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    batch_id: Mapped[int] = mapped_column(ForeignKey("batches.batch_id"))
    title: Mapped[str] = mapped_column(String(255))
    date: Mapped[date] = mapped_column(Date, index=True)
    start: Mapped[time] = mapped_column(Time)
    end: Mapped[time] = mapped_column(Time)
    status: Mapped[MatchStatus] = mapped_column(default=MatchStatus.UPCOMING)
    opponent: Mapped[str | None] = mapped_column(String(255), nullable=True)

    batch: Mapped["Batch"] = relationship(back_populates="matches")
