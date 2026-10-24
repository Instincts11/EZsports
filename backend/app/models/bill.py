from __future__ import annotations

from datetime import date
from decimal import Decimal
from typing import TYPE_CHECKING

from sqlalchemy import CheckConstraint, Date, ForeignKey, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import BillStatus

if TYPE_CHECKING:
    from app.models.accountant import Accountant
    from app.models.coach import Coach
    from app.models.student import Student


class Bill(Base):
    __tablename__ = "bills"
    __table_args__ = (
        CheckConstraint(
            "(student_id IS NOT NULL AND coach_id IS NULL) OR (student_id IS NULL AND coach_id IS NOT NULL)",
            name="ck_bill_one_person",
        ),
    )

    bill_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    student_id: Mapped[int | None] = mapped_column(ForeignKey("students.student_id"), nullable=True)
    coach_id: Mapped[int | None] = mapped_column(ForeignKey("coaches.coach_id"), nullable=True)
    accountant_id: Mapped[int] = mapped_column(ForeignKey("accountants.accountant_id"))
    amount: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    due_date: Mapped[date] = mapped_column(Date)
    status: Mapped[BillStatus] = mapped_column(default=BillStatus.DUE)

    student: Mapped["Student | None"] = relationship(back_populates="bills")
    coach: Mapped["Coach | None"] = relationship(back_populates="bills")
    accountant: Mapped["Accountant"] = relationship(back_populates="bills")
