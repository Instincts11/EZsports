from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import ConflictError, ForbiddenError
from app.models import Accountant, Coach, Student, UserRole
from app.models.enums import BillStatus
from app.schemas import (
    AccountantCreate,
    AccountantResponse,
    CoachCreate,
    CoachResponse,
    CoachUpdate,
    StudentCreate,
    StudentResponse,
    StudentUpdate,
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
        email=coach.user.email if coach.user else None,
    )


def create_coach(db: Session, current: CurrentUser, payload: CoachCreate) -> CoachResponse:
    if current.admin_id is None:
        raise ForbiddenError()
    user = create_login_user(db, payload.email, payload.password, UserRole.COACH)
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
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(coach, field, value)
    db.commit()
    db.refresh(coach)
    return _coach_response(coach)


def create_student(db: Session, current: CurrentUser, payload: StudentCreate) -> StudentResponse:
    if current.admin_id is None:
        raise ForbiddenError()
    student = Student(
        admin_id=current.admin_id,
        name=payload.name,
        parent_mobile=payload.parent_mobile,
        photo_url=payload.photo_url,
        fee_status=BillStatus.PAID,
    )
    db.add(student)
    db.commit()
    db.refresh(student)
    return StudentResponse.model_validate(student)


def list_students(db: Session, current: CurrentUser, batch_id: int | None = None) -> list[StudentResponse]:
    query = db.query(Student)
    if current.admin_id:
        query = query.filter(Student.admin_id == current.admin_id)
    if batch_id:
        query = query.join(Student.enrollments).filter_by(batch_id=batch_id)
    return [StudentResponse.model_validate(student) for student in query.all()]


def get_student(db: Session, student_id: int) -> StudentResponse:
    student = require_record(db.get(Student, student_id), "Student not found")
    return StudentResponse.model_validate(student)


def update_student(db: Session, student_id: int, payload: StudentUpdate) -> StudentResponse:
    student = require_record(db.get(Student, student_id), "Student not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(student, field, value)
    db.commit()
    db.refresh(student)
    return StudentResponse.model_validate(student)
