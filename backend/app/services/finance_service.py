from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import CurrentUser
from app.core.exceptions import AppError, ForbiddenError
from app.models import Accountant, Bill, Coach, Student
from app.models.enums import BillStatus, UserRole
from app.schemas import BillCreate, BillResponse, BillUpdate
from app.services import require_record


def _sync_student_fee_status(db: Session, student_id: int) -> None:
    student = require_record(db.get(Student, student_id), "Player not found")
    open_bill = (
        db.query(Bill)
        .filter(Bill.student_id == student_id, Bill.status.in_([BillStatus.DUE, BillStatus.OVERDUE]))
        .first()
    )
    student.fee_status = open_bill.status if open_bill else BillStatus.PAID


def _bill_response(bill: Bill) -> BillResponse:
    person_name = None
    if bill.student is not None:
        person_name = bill.student.name
    elif bill.coach is not None:
        person_name = bill.coach.name
    return BillResponse.model_validate(bill).model_copy(update={"person_name": person_name})


def _in_academy(bill: Bill, admin_id: int | None) -> bool:
    if admin_id is None:
        return True
    if bill.student is not None and bill.student.admin_id == admin_id:
        return True
    return bill.coach is not None and bill.coach.admin_id == admin_id


def _accountant_for(db: Session, current: CurrentUser) -> int:
    if current.accountant_id is not None:
        return current.accountant_id
    if current.role == UserRole.SUPER_ADMIN and current.admin_id is not None:
        accountant = db.query(Accountant).filter(Accountant.admin_id == current.admin_id).first()
        if accountant is not None:
            return accountant.accountant_id
    raise ForbiddenError("Only an accountant can create fees")


def create_bill(db: Session, current: CurrentUser, payload: BillCreate) -> BillResponse:
    accountant_id = _accountant_for(db, current)
    if payload.student_id is not None:
        student = require_record(db.get(Student, payload.student_id), "Player not found")
        if current.admin_id is not None and student.admin_id != current.admin_id:
            raise ForbiddenError("This player is outside your academy")
    else:
        if payload.coach_id is None:
            raise AppError(422, "Choose either a player or a coach")
        coach = require_record(db.get(Coach, payload.coach_id), "Coach not found")
        if current.admin_id is not None and coach.admin_id != current.admin_id:
            raise ForbiddenError("This coach is outside your academy")
    bill = Bill(
        student_id=payload.student_id,
        coach_id=payload.coach_id,
        accountant_id=accountant_id,
        amount=payload.amount,
        due_date=payload.due_date,
        status=payload.status,
    )
    db.add(bill)
    db.flush()
    if payload.student_id is not None:
        _sync_student_fee_status(db, payload.student_id)
    db.commit()
    db.refresh(bill)
    return _bill_response(bill)


def list_bills(
    db: Session,
    current: CurrentUser,
    student_id: int | None = None,
    coach_id: int | None = None,
) -> list[BillResponse]:
    query = db.query(Bill).options(joinedload(Bill.student), joinedload(Bill.coach))
    if student_id is not None:
        query = query.filter(Bill.student_id == student_id)
    if coach_id is not None:
        query = query.filter(Bill.coach_id == coach_id)
    bills = [bill for bill in query.order_by(Bill.due_date.desc()).all() if _in_academy(bill, current.admin_id)]
    return [_bill_response(bill) for bill in bills]


def update_bill(db: Session, current: CurrentUser, bill_id: int, payload: BillUpdate) -> BillResponse:
    if current.role not in (UserRole.ACCOUNTANT, UserRole.SUPER_ADMIN):
        raise ForbiddenError("Only an accountant can update fees")
    bill = require_record(
        db.query(Bill).options(joinedload(Bill.student), joinedload(Bill.coach)).filter(Bill.bill_id == bill_id).first(),
        "Fee not found",
    )
    if not _in_academy(bill, current.admin_id):
        raise ForbiddenError("This fee is outside your academy")
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise AppError(422, "No fee changes were sent")
    for field, value in changes.items():
        setattr(bill, field, value)
    if bill.student_id is not None:
        _sync_student_fee_status(db, bill.student_id)
    db.commit()
    db.refresh(bill)
    return _bill_response(bill)
