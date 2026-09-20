from datetime import date, time, timedelta

from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models import (
    Academy,
    Accountant,
    Batch,
    Bill,
    Coach,
    Enrollment,
    Session as TrainingSession,
    SessionAssignment,
    Student,
    SuperAdmin,
    User,
    UserRole,
)
from app.models.enums import BillStatus


def seed_if_empty(db: Session) -> None:
    if db.query(User).first():
        return

    academy = Academy(name="ID Sports Academy", sport="Multi-sport")
    db.add(academy)
    db.flush()

    admin_user = User(
        email="admin@idsports.com",
        password_hash=hash_password("admin123"),
        role=UserRole.SUPER_ADMIN,
    )
    accountant_user = User(
        email="accountant@idsports.com",
        password_hash=hash_password("accountant123"),
        role=UserRole.ACCOUNTANT,
    )
    coach_user = User(
        email="coach@idsports.com",
        password_hash=hash_password("coach123"),
        role=UserRole.COACH,
    )
    db.add_all([admin_user, accountant_user, coach_user])
    db.flush()

    admin = SuperAdmin(user_id=admin_user.user_id, academy_id=academy.academy_id, name="Super Admin")
    db.add(admin)
    db.flush()

    accountant = Accountant(user_id=accountant_user.user_id, admin_id=admin.admin_id, name="Academy Accountant")
    coach = Coach(
        user_id=coach_user.user_id,
        admin_id=admin.admin_id,
        name="Amal Coach",
        mobile="9876543210",
        gender="Male",
        experience="5 years",
        certifications="AFC C Licence",
        address="Kochi",
    )
    db.add_all([accountant, coach])
    db.flush()

    batches = [
        Batch(academy_id=academy.academy_id, name="Summer Camp", days="Mon Tue Wed Thu Fri", sport="Football"),
        Batch(academy_id=academy.academy_id, name="Weekday Eve", days="Mon Wed Fri", sport="Football"),
        Batch(academy_id=academy.academy_id, name="Weekend Eve", days="Sat Sun", sport="Football"),
        Batch(academy_id=academy.academy_id, name="Weekend Morning", days="Sat Sun", sport="Football"),
    ]
    db.add_all(batches)
    db.flush()

    students = [
        Student(admin_id=admin.admin_id, name="Arjun Menon", parent_mobile="9000000001", fee_status=BillStatus.DUE),
        Student(admin_id=admin.admin_id, name="Diya Nair", parent_mobile="9000000002", fee_status=BillStatus.PAID),
        Student(admin_id=admin.admin_id, name="Rahul Krishnan", parent_mobile="9000000003", fee_status=BillStatus.PAID),
        Student(admin_id=admin.admin_id, name="Sneha Thomas", parent_mobile="9000000004", fee_status=BillStatus.PAID),
    ]
    db.add_all(students)
    db.flush()

    db.add_all(
        [
            Enrollment(batch_id=batches[2].batch_id, student_id=students[0].student_id),
            Enrollment(batch_id=batches[2].batch_id, student_id=students[1].student_id),
            Enrollment(batch_id=batches[3].batch_id, student_id=students[2].student_id),
            Enrollment(batch_id=batches[3].batch_id, student_id=students[3].student_id),
        ]
    )

    today = date.today()
    session = TrainingSession(
        batch_id=batches[2].batch_id,
        date=today,
        start=time(15, 30),
        end=time(17, 0),
    )
    later = TrainingSession(
        batch_id=batches[3].batch_id,
        date=today + timedelta(days=1),
        start=time(7, 0),
        end=time(8, 30),
    )
    db.add_all([session, later])
    db.flush()

    db.add_all(
        [
            SessionAssignment(session_id=session.session_id, coach_id=coach.coach_id, assigned_by=admin.admin_id),
            SessionAssignment(session_id=later.session_id, coach_id=coach.coach_id, assigned_by=admin.admin_id),
        ]
    )
    db.add(
        Bill(
            student_id=students[0].student_id,
            accountant_id=accountant.accountant_id,
            amount=2500,
            due_date=today,
            status=BillStatus.DUE,
        )
    )
    db.commit()
