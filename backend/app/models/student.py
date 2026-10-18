from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.enums import BillStatus

if TYPE_CHECKING:
    from app.models.bill import Bill
    from app.models.enrollment import Enrollment
    from app.models.student_attendance import StudentAttendance
    from app.models.super_admin import SuperAdmin
    from app.models.user import User


class Student(Base):
    __tablename__ = "students"

    student_id: Mapped[int] = mapped_column(primary_key=True, index=True)
    admin_id: Mapped[int] = mapped_column(ForeignKey("super_admins.admin_id"))
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.user_id"), unique=True, nullable=True)
    name: Mapped[str] = mapped_column(String(255))
    first_name: Mapped[str | None] = mapped_column(String(120), nullable=True)
    last_name: Mapped[str | None] = mapped_column(String(120), nullable=True)
    dob: Mapped[str | None] = mapped_column(String(40), nullable=True)
    gender: Mapped[str | None] = mapped_column(String(40), nullable=True)
    mobile: Mapped[str | None] = mapped_column(String(20), nullable=True, index=True)
    emergency_contact: Mapped[str | None] = mapped_column(String(20), nullable=True)
    parent_mobile: Mapped[str] = mapped_column(String(20))
    guardian_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    position: Mapped[str | None] = mapped_column(String(120), nullable=True)
    preferred_foot: Mapped[str | None] = mapped_column(String(40), nullable=True)
    school: Mapped[str | None] = mapped_column(String(255), nullable=True)
    school_class: Mapped[str | None] = mapped_column(String(40), nullable=True)
    jersey: Mapped[str | None] = mapped_column(String(20), nullable=True)
    blood_group: Mapped[str | None] = mapped_column(String(20), nullable=True)
    allergies: Mapped[str | None] = mapped_column(Text, nullable=True)
    photo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    fee_status: Mapped[BillStatus] = mapped_column(default=BillStatus.PAID)
    otp_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    super_admin: Mapped["SuperAdmin"] = relationship(back_populates="students")
    user: Mapped["User | None"] = relationship(back_populates="student")
    enrollments: Mapped[list["Enrollment"]] = relationship(back_populates="student")
    bills: Mapped[list["Bill"]] = relationship(back_populates="student")
    attendances: Mapped[list["StudentAttendance"]] = relationship(back_populates="student")
