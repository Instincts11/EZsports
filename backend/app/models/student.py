from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import BillStatus

if TYPE_CHECKING:
    from app.models.bill import Bill
    from app.models.enrollment import Enrollment
    from app.models.student_attendance import StudentAttendance
    from app.models.super_admin import SuperAdmin


class Student(Base):
    __tablename__ = "students"

    student_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    admin_id: Mapped[int] = mapped_column(ForeignKey("super_admins.admin_id"))
    name: Mapped[str] = mapped_column(String(255))
    parent_mobile: Mapped[str] = mapped_column(String(20))
    photo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    fee_status: Mapped[BillStatus] = mapped_column(default=BillStatus.PAID)

    super_admin: Mapped["SuperAdmin"] = relationship(back_populates="students")
    enrollments: Mapped[list["Enrollment"]] = relationship(back_populates="student")
    bills: Mapped[list["Bill"]] = relationship(back_populates="student")
    attendances: Mapped[list["StudentAttendance"]] = relationship(back_populates="student")
