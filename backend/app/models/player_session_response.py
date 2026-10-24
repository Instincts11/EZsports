from __future__ import annotations

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class PlayerSessionResponse(Base):
    __tablename__ = "player_session_responses"
    __table_args__ = (UniqueConstraint("session_id", "student_id", name="uq_player_session_response"),)

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    session_id: Mapped[int] = mapped_column(ForeignKey("sessions.session_id"))
    student_id: Mapped[int] = mapped_column(ForeignKey("students.student_id"))
    checked_in: Mapped[bool] = mapped_column(default=False)
    skip_reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
