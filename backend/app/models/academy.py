from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.batch import Batch
    from app.models.super_admin import SuperAdmin


class Academy(Base):
    __tablename__ = "academies"

    academy_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255))
    sport: Mapped[str] = mapped_column(String(100), default="Multi-sport")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    super_admins: Mapped[list["SuperAdmin"]] = relationship(back_populates="academy")
    batches: Mapped[list["Batch"]] = relationship(back_populates="academy")
