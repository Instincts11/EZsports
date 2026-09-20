from sqlalchemy.orm import Session

from app.core.dependencies import CurrentUser
from app.core.exceptions import ForbiddenError
from app.models import Bill, Student
from app.models.enums import BillStatus
from app.schemas import BillCreate, BillResponse, BillUpdate
from app.services import require_record


def _sync_student_fee_status(db: Session, student_id: int) -> None:
    student = require_record(db.get(Student, student_id), "Student not found")
    open_bill = (
        db.query(Bill)
        .filter(Bill.student_id == student_id, Bill.status.in_([BillStatus.DUE, BillStatus.OVERDUE]))
        .first()
    )
    student.fee_status = open_bill.status if open_bill else BillStatus.PAID


def create_bill(db: Session, current: CurrentUser, payload: BillCreate) -> BillResponse:
    if current.accountant_id is None:
        raise ForbiddenError("Only an accountant can create bills")
    require_record(db.get(Student, payload.student_id), "Student not found")
    bill = Bill(
        student_id=payload.student_id,
        accountant_id=current.accountant_id,
        amount=payload.amount,
        due_date=payload.due_date,
        status=payload.status,
    )
    db.add(bill)
    db.flush()
    _sync_student_fee_status(db, payload.student_id)
    db.commit()
    db.refresh(bill)
    return BillResponse.model_validate(bill)


def list_bills(db: Session, student_id: int | None = None) -> list[BillResponse]:
    query = db.query(Bill)
    if student_id:
        query = query.filter(Bill.student_id == student_id)
    return [BillResponse.model_validate(bill) for bill in query.all()]


def update_bill(db: Session, bill_id: int, payload: BillUpdate) -> BillResponse:
    bill = require_record(db.get(Bill, bill_id), "Bill not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(bill, field, value)
    _sync_student_fee_status(db, bill.student_id)
    db.commit()
    db.refresh(bill)
    return BillResponse.model_validate(bill)
