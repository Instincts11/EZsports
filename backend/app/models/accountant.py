from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.bill import Bill
    from app.models.super_admin import SuperAdmin
    from app.models.user import User


class Accountant(Base):
    __tablename__ = "accountants"

    accountant_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.user_id"), unique=True)
    admin_id: Mapped[int] = mapped_column(ForeignKey("super_admins.admin_id"))
    name: Mapped[str] = mapped_column(String(255))
    assigned_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped["User"] = relationship(back_populates="accountant")
    super_admin: Mapped["SuperAdmin"] = relationship(back_populates="accountants")
    bills: Mapped[list["Bill"]] = relationship(back_populates="accountant")
