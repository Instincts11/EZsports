from datetime import datetime, timezone

from fastapi import status
from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload, selectinload

from app.core.dependencies import CurrentUser
from app.core.exceptions import AppError, ConflictError, ForbiddenError, NotFoundError
from app.core.security import hash_password
from app.models import (
    Accountant,
    Bill,
    Coach,
    CoachAttendance,
    Enrollment,
    Leave,
    Session as TrainingSession,
    SessionAssignment,
    Student,
    StudentAttendance,
    SuperAdmin,
    User,
    UserRole,
)
from app.models.enums import AttendanceStatus, BillStatus
from app.schemas import (
    AccountantCreate,
    AccountantResponse,
    AccountantUpdate,
    CoachCreate,
    CoachResponse,
    CoachUpdate,
    StudentAttendanceBrief,
    StudentCreate,
    StudentResponse,
    StudentUpdate,
    SuperAdminResponse,
)
from app.services import create_login_user, require_record


def assign_accountant(db: Session, current: CurrentUser, payload: AccountantCreate) -> AccountantResponse:
    if current.admin_id is None:
        raise ForbiddenError()
    existing = db.query(Accountant).filter(Accountant.admin_id == current.admin_id).first()
    if existing:
        raise ConflictError("This academy already has an accountant")
    user = create_login_user(db, payload.email, payload.password, UserRole.ACCOUNTANT)
    accountant = Accountant(user_id=user.user_id, admin_id=current.admin_id, name=payload.name)
    db.add(accountant)
    db.commit()
    db.refresh(accountant)
    return _accountant_response(accountant)


def _accountant_response(accountant: Accountant) -> AccountantResponse:
    return AccountantResponse(
        accountant_id=accountant.accountant_id,
        admin_id=accountant.admin_id,
        name=accountant.name,
        email=accountant.user.email if accountant.user else None,
        assigned_at=accountant.assigned_at,
    )


def _accountant_query(db: Session):
    return db.query(Accountant).options(joinedload(Accountant.user))


def list_accountants(db: Session, current: CurrentUser) -> list[AccountantResponse]:
    query = _accountant_query(db)
    if current.role == UserRole.ACCOUNTANT and current.accountant_id:
        query = query.filter(Accountant.accountant_id == current.accountant_id)
    elif current.admin_id:
        query = query.filter(Accountant.admin_id == current.admin_id)
    return [_accountant_response(row) for row in query.all()]


def get_my_accountant(db: Session, current: CurrentUser) -> AccountantResponse:
    if current.accountant_id is None:
        raise ForbiddenError("Only an accountant can view this profile")
    accountant = require_record(
        _accountant_query(db).filter(Accountant.accountant_id == current.accountant_id).first(),
        "Accountant not found",
    )
    return _accountant_response(accountant)


def _coach_response(coach: Coach) -> CoachResponse:
    return CoachResponse(
        coach_id=coach.coach_id,
        admin_id=coach.admin_id,
        name=coach.name,
        mobile=coach.mobile,
        dob=coach.dob,
        gender=coach.gender,
        emergency_contact=coach.emergency_contact,
        certifications=coach.certifications,
        experience=coach.experience,
        address=coach.address,
        photo_url=coach.photo_url,
        headline=coach.headline,
        email=coach.user.email if coach.user else None,
    )


def create_coach(db: Session, current: CurrentUser, payload: CoachCreate) -> CoachResponse:
    if current.admin_id is None:
        raise ForbiddenError()
    _require_password(payload.password)
    user = create_login_user(db, payload.email.lower().strip(), payload.password, UserRole.COACH)
    coach = Coach(
        user_id=user.user_id,
        admin_id=current.admin_id,
        name=payload.name,
        mobile=payload.mobile,
        dob=payload.dob,
        gender=payload.gender,
        emergency_contact=payload.emergency_contact,
        certifications=payload.certifications,
        experience=payload.experience,
        address=payload.address,
        photo_url=payload.photo_url,
        headline=_blank(payload.headline),
    )
    db.add(coach)
    db.commit()
    db.refresh(coach)
    return _coach_response(coach)


def list_coaches(db: Session, current: CurrentUser) -> list[CoachResponse]:
    query = db.query(Coach)
    if current.admin_id:
        query = query.filter(Coach.admin_id == current.admin_id)
    return [_coach_response(coach) for coach in query.all()]


def get_coach(db: Session, coach_id: int) -> CoachResponse:
    coach = require_record(db.get(Coach, coach_id), "Coach not found")
    return _coach_response(coach)


def update_coach(db: Session, coach_id: int, payload: CoachUpdate) -> CoachResponse:
    coach = require_record(db.get(Coach, coach_id), "Coach not found")
    changes = payload.model_dump(exclude_unset=True)
    email = changes.pop("email", None)
    password = _clean_password(changes.pop("password", None))
    for field, value in changes.items():
        setattr(coach, field, value)
    if password is not None:
        if coach.user is None:
            raise NotFoundError("This coach has no sign-in account")
        coach.user.password_hash = hash_password(password)
    if email is not None:
        if coach.user is None:
            raise NotFoundError("This coach has no sign-in account")
        cleaned = email.lower().strip()
        taken = (
            db.query(User)
            .filter(func.lower(User.email) == cleaned, User.user_id != coach.user_id)
            .first()
        )
        if taken is not None:
            raise ConflictError("An account with this email already exists")
        coach.user.email = cleaned
    db.commit()
    db.refresh(coach)
    return _coach_response(coach)


def _student_response(student: Student) -> StudentResponse:
    batches = [enrollment.batch.name for enrollment in student.enrollments if enrollment.batch is not None]
    rows = list(student.attendances)
    attended = sum(1 for row in rows if row.status == AttendanceStatus.PRESENT)
    bills = sorted(student.bills, key=lambda bill: bill.due_date, reverse=True)
    latest = bills[0] if bills else None
    marks = []
    for row in rows:
        session = row.session
        if session is None:
            continue
        marks.append(
            StudentAttendanceBrief(
                date=session.date,
                batch_name=session.batch.name if session.batch is not None else None,
                status=row.status,
            )
        )
    marks.sort(key=lambda item: item.date, reverse=True)
    return StudentResponse.model_validate(student).model_copy(
        update={
            "batch_name": ", ".join(batches) if batches else None,
            "attended": attended,
            "total_sessions": len(rows),
            "bill_amount": latest.amount if latest is not None else None,
            "bill_due_date": latest.due_date if latest is not None else None,
            "bill_status": latest.status if latest is not None else None,
            "attendance_marks": marks,
            "email": student.user.email if student.user is not None else None,
        }
    )


def _students_query(db: Session):
    return db.query(Student).options(
        selectinload(Student.enrollments).joinedload(Enrollment.batch),
        selectinload(Student.bills),
        selectinload(Student.user),
        selectinload(Student.attendances).joinedload(StudentAttendance.session).joinedload(TrainingSession.batch),
    )


def create_student(db: Session, current: CurrentUser, payload: StudentCreate) -> StudentResponse:
    if current.admin_id is None:
        raise ForbiddenError()
    email = payload.email.lower().strip() if payload.email else None
    password = _clean_password(payload.password)
    if (email is None) != (password is None):
        raise AppError(status.HTTP_400_BAD_REQUEST, "Email and password are both required for a player sign-in")
    mobile = _blank(payload.mobile)
    if mobile and db.query(Student).filter(Student.mobile == mobile).first():
        raise ConflictError("This mobile is already registered")
    user = create_login_user(db, email, password, UserRole.PLAYER) if email and password else None
    student = Student(
        admin_id=current.admin_id,
        user_id=user.user_id if user is not None else None,
        name=payload.name.strip(),
        parent_mobile=payload.parent_mobile.strip(),
        photo_url=payload.photo_url,
        first_name=_blank(payload.first_name),
        last_name=_blank(payload.last_name),
        dob=_blank(payload.dob),
        gender=_blank(payload.gender),
        mobile=mobile,
        emergency_contact=_blank(payload.emergency_contact),
        guardian_name=_blank(payload.guardian_name),
        position=_blank(payload.position),
        preferred_foot=_blank(payload.preferred_foot),
        school=_blank(payload.school),
        school_class=_blank(payload.school_class),
        jersey=_blank(payload.jersey),
        blood_group=_blank(payload.blood_group),
        allergies=_blank(payload.allergies),
        coach_note=_blank(payload.coach_note),
        fee_status=BillStatus.PAID,
        otp_verified_at=datetime.now(timezone.utc) if user is not None else None,
    )
    db.add(student)
    db.commit()
    db.refresh(student)
    loaded = require_record(_students_query(db).filter(Student.student_id == student.student_id).first(), "Student not found")
    return _student_response(loaded)


def list_students(db: Session, current: CurrentUser, batch_id: int | None = None) -> list[StudentResponse]:
    query = _students_query(db)
    if current.admin_id:
        query = query.filter(Student.admin_id == current.admin_id)
    if batch_id:
        query = query.join(Student.enrollments).filter_by(batch_id=batch_id)
    return [_student_response(student) for student in query.all()]


def get_student(db: Session, student_id: int) -> StudentResponse:
    student = require_record(_students_query(db).filter(Student.student_id == student_id).first(), "Student not found")
    return _student_response(student)


def update_student(db: Session, student_id: int, payload: StudentUpdate) -> StudentResponse:
    student = require_record(db.get(Student, student_id), "Student not found")
    changes = payload.model_dump(exclude_unset=True)
    email = changes.pop("email", None)
    password = _clean_password(changes.pop("password", None))
    mobile = changes.get("mobile")
    if mobile and db.query(Student).filter(Student.mobile == mobile, Student.student_id != student.student_id).first():
        raise ConflictError("This mobile is already registered")
    for field, value in changes.items():
        setattr(student, field, value)
    if student.user is None and (email or password):
        if not email or not password:
            raise AppError(status.HTTP_400_BAD_REQUEST, "Email and password are both required to create a sign-in")
        user = create_login_user(db, email.lower().strip(), password, UserRole.PLAYER)
        student.user_id = user.user_id
        student.otp_verified_at = datetime.now(timezone.utc)
        email = None
    elif password is not None:
        if student.user is None:
            raise NotFoundError("This player has no sign-in account")
        student.user.password_hash = hash_password(password)
    if email is not None:
        if student.user is None:
            raise AppError(status.HTTP_400_BAD_REQUEST, "Add a password to create this player's sign-in")
        cleaned = email.lower().strip()
        taken = (
            db.query(User)
            .filter(func.lower(User.email) == cleaned, User.user_id != student.user_id)
            .first()
        )
        if taken is not None:
            raise ConflictError("An account with this email already exists")
        student.user.email = cleaned
    db.commit()
    loaded = require_record(_students_query(db).filter(Student.student_id == student_id).first(), "Student not found")
    return _student_response(loaded)


def delete_coach(db: Session, coach_id: int) -> None:
    coach = require_record(db.get(Coach, coach_id), "Coach not found")
    replacement = db.query(Coach).filter(Coach.coach_id != coach_id).order_by(Coach.coach_id).first()
    marks = db.query(StudentAttendance).filter(StudentAttendance.marked_by_coach_id == coach_id)
    if replacement is None:
        marks.delete(synchronize_session=False)
    else:
        marks.update({StudentAttendance.marked_by_coach_id: replacement.coach_id}, synchronize_session=False)
    db.query(SessionAssignment).filter(SessionAssignment.coach_id == coach_id).delete(synchronize_session=False)
    db.query(CoachAttendance).filter(CoachAttendance.coach_id == coach_id).delete(synchronize_session=False)
    db.query(Leave).filter(Leave.coach_id == coach_id).delete(synchronize_session=False)
    db.query(Bill).filter(Bill.coach_id == coach_id).delete(synchronize_session=False)
    user = coach.user
    db.delete(coach)
    if user is not None:
        db.delete(user)
    db.commit()


def delete_student(db: Session, student_id: int) -> None:
    student = require_record(db.get(Student, student_id), "Student not found")
    db.query(Enrollment).filter(Enrollment.student_id == student_id).delete(synchronize_session=False)
    db.query(StudentAttendance).filter(StudentAttendance.student_id == student_id).delete(synchronize_session=False)
    db.query(Bill).filter(Bill.student_id == student_id).delete(synchronize_session=False)
    user = student.user
    db.delete(student)
    if user is not None:
        db.delete(user)
    db.commit()


def update_accountant(db: Session, accountant_id: int, payload: AccountantUpdate) -> AccountantResponse:
    accountant = require_record(db.get(Accountant, accountant_id), "Accountant not found")
    changes = payload.model_dump(exclude_unset=True)
    email = changes.pop("email", None)
    password = _clean_password(changes.pop("password", None))
    for field, value in changes.items():
        setattr(accountant, field, value)
    if password is not None:
        if accountant.user is None:
            raise NotFoundError("This accountant has no sign-in account")
        accountant.user.password_hash = hash_password(password)
    if email is not None:
        if accountant.user is None:
            raise NotFoundError("This accountant has no sign-in account")
        cleaned = email.lower().strip()
        taken = db.query(User).filter(func.lower(User.email) == cleaned, User.user_id != accountant.user_id).first()
        if taken is not None:
            raise ConflictError("An account with this email already exists")
        accountant.user.email = cleaned
    db.commit()
    db.refresh(accountant)
    return _accountant_response(accountant)


def delete_accountant(db: Session, accountant_id: int) -> None:
    accountant = require_record(db.get(Accountant, accountant_id), "Accountant not found")
    if db.query(Bill).filter(Bill.accountant_id == accountant_id).first() is not None:
        raise ConflictError("This accountant still has fees")
    user = accountant.user
    db.delete(accountant)
    if user is not None:
        db.delete(user)
    db.commit()


def _blank(value: str | None) -> str | None:
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned or None


def _clean_password(value: str | None) -> str | None:
    password = _blank(value)
    if password is None:
        return None
    _require_password(password)
    return password


def _require_password(password: str) -> None:
    if len(password.strip()) < 6:
        raise AppError(status.HTTP_400_BAD_REQUEST, "Password must be at least 6 characters")


def list_admins(db: Session, current: CurrentUser) -> list[SuperAdminResponse]:
    query = db.query(SuperAdmin).options(joinedload(SuperAdmin.user), joinedload(SuperAdmin.academy))
    if current.admin_id is not None:
        query = query.filter(SuperAdmin.admin_id == current.admin_id)
    admins = query.order_by(SuperAdmin.name).all()
    return [
        SuperAdminResponse(
            admin_id=admin.admin_id,
            name=admin.name,
            email=admin.user.email if admin.user is not None else None,
            mobile=admin.mobile,
            academy_name=admin.academy.name if admin.academy is not None else None,
        )
        for admin in admins
    ]
