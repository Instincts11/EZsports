from datetime import date, time, timedelta

from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models import (
    Academy,
    Accountant,
    Batch,
    Bill,
    Coach,
    CoachAttendance,
    Enrollment,
    Leave,
    Match,
    Session as TrainingSession,
    SessionAssignment,
    Student,
    StudentAttendance,
    SuperAdmin,
    User,
    UserRole,
)
from app.models.enums import AttendanceStatus, BillStatus, LeaveStatus, MatchStatus


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

    admin = SuperAdmin(
        user_id=admin_user.user_id,
        academy_id=academy.academy_id,
        name="Super Admin",
        mobile="9847002211",
    )
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


def seed_player_account(db: Session) -> None:
    """Give the player account a batch, sessions, and attendance rows from the database."""
    coach = db.query(Coach).order_by(Coach.coach_id).first()
    admin = db.query(SuperAdmin).order_by(SuperAdmin.admin_id).first()
    if coach is None or admin is None:
        return

    player = db.query(User).filter(User.role == UserRole.PLAYER).order_by(User.user_id).first()
    student = db.query(Student).filter(Student.user_id == player.user_id).first() if player else None
    if student is None:
        student = db.query(Student).join(Enrollment).order_by(Student.student_id).first()
        if student is None:
            return
        if player is None:
            user = User(
                email="player@idsports.com",
                password_hash=hash_password("player123"),
                role=UserRole.PLAYER,
            )
            db.add(user)
            db.flush()
            student.user_id = user.user_id
        if not student.first_name:
            parts = student.name.split(" ", 1)
            student.first_name = parts[0]
            student.last_name = parts[1] if len(parts) > 1 else None
        if not student.mobile:
            student.mobile = student.parent_mobile

    batch = (
        db.query(Batch)
        .join(Enrollment)
        .filter(Enrollment.student_id == student.student_id)
        .order_by(Batch.batch_id)
        .first()
    )
    if batch is None:
        batch = db.query(Batch).filter(Batch.name == "Weekend Eve").first() or db.query(Batch).order_by(Batch.batch_id).first()
        if batch is None:
            return
        db.add(Enrollment(batch_id=batch.batch_id, student_id=student.student_id))
        db.flush()

    batch_id = batch.batch_id
    today = date.today()

    def ensure_session(day: date, start: time, end: time) -> TrainingSession:
        existing = (
            db.query(TrainingSession)
            .filter(
                TrainingSession.batch_id == batch_id,
                TrainingSession.date == day,
                TrainingSession.start == start,
            )
            .first()
        )
        if existing:
            return existing
        created = TrainingSession(batch_id=batch_id, date=day, start=start, end=end)
        db.add(created)
        db.flush()
        db.add(
            SessionAssignment(
                session_id=created.session_id,
                coach_id=coach.coach_id,
                assigned_by=admin.admin_id,
            )
        )
        return created

    ensure_session(today, time(15, 30), time(17, 0))
    ensure_session(today + timedelta(days=3), time(7, 0), time(8, 30))
    if db.query(StudentAttendance).filter(StudentAttendance.student_id == student.student_id).count() == 0:
        marks = (
            (7, AttendanceStatus.PRESENT),
            (14, AttendanceStatus.ABSENT),
            (21, AttendanceStatus.PRESENT),
        )
        for offset, status in marks:
            past = ensure_session(today - timedelta(days=offset), time(15, 30), time(17, 0))
            db.add(
                StudentAttendance(
                    session_id=past.session_id,
                    student_id=student.student_id,
                    marked_by_coach_id=coach.coach_id,
                    status=status,
                )
            )
    db.commit()


def seed_more_players(db: Session) -> None:
    """Add academy players when their parent mobile is not already stored."""
    admin = db.query(SuperAdmin).order_by(SuperAdmin.admin_id).first()
    accountant = db.query(Accountant).order_by(Accountant.accountant_id).first()
    if admin is None or accountant is None:
        return
    batches = {batch.name: batch for batch in db.query(Batch).all()}
    if not batches:
        return
    today = date.today()
    extras = [
        ("Ananya Pillai", "9000000011", "Female", "Midfielder", "Lakshmi Pillai", "Weekday Eve", BillStatus.PAID, 2000),
        ("Dev Sharma", "9000000012", "Male", "Forward", "Ravi Sharma", "Summer Camp", BillStatus.DUE, 3000),
        ("Meera Joseph", "9000000013", "Female", "Goalkeeper", "Ann Joseph", "Weekend Morning", BillStatus.PAID, 2500),
        ("Kabir Das", "9000000014", "Male", "Defender", "Sunil Das", "Weekday Eve", BillStatus.DUE, 2000),
        ("Nila George", "9000000015", "Female", "Winger", "Mary George", "Weekend Eve", BillStatus.PAID, 2500),
        ("Vikram Iyer", "9000000016", "Male", "Midfielder", "Hari Iyer", "Summer Camp", BillStatus.PAID, 3000),
        ("Sara Mathew", "9000000017", "Female", "Forward", "Tess Mathew", "Weekend Morning", BillStatus.DUE, 2500),
        ("Rohan Varma", "9000000018", "Male", "Defender", "Anil Varma", "Weekday Eve", BillStatus.PAID, 2000),
        ("Aisha Khan", "9000000019", "Female", "Midfielder", "Farah Khan", "Summer Camp", BillStatus.OVERDUE, 3000),
        ("Ishaan Nair", "9000000020", "Male", "Winger", "Priya Nair", "Weekend Eve", BillStatus.PAID, 2500),
        ("Pooja Menon", "9000000021", "Female", "Defender", "Rekha Menon", "Weekend Morning", BillStatus.PAID, 2500),
        ("Aravind Kumar", "9000000022", "Male", "Forward", "Suresh Kumar", "Weekday Eve", BillStatus.DUE, 2000),
    ]
    added = False
    fallback = next(iter(batches.values()))
    for name, mobile, gender, position, guardian, batch_name, status, amount in extras:
        if db.query(Student).filter(Student.parent_mobile == mobile).first():
            continue
        first, _, last = name.partition(" ")
        student = Student(
            admin_id=admin.admin_id,
            name=name,
            first_name=first,
            last_name=last or None,
            gender=gender,
            position=position,
            guardian_name=guardian,
            parent_mobile=mobile,
            mobile=mobile,
            fee_status=status,
        )
        db.add(student)
        db.flush()
        batch = batches.get(batch_name, fallback)
        db.add(Enrollment(batch_id=batch.batch_id, student_id=student.student_id))
        db.add(
            Bill(
                student_id=student.student_id,
                accountant_id=accountant.accountant_id,
                amount=amount,
                due_date=today,
                status=status,
            )
        )
        added = True
    if added:
        db.commit()


def seed_academy_activity(db: Session) -> None:
    """Add coaches, past sessions, attendance, and leave so every table has rows."""
    admin = db.query(SuperAdmin).order_by(SuperAdmin.admin_id).first()
    if admin is None:
        return
    batches = db.query(Batch).order_by(Batch.batch_id).all()
    if not batches:
        return

    staff = [
        ("coach2@idsports.com", "Nisha Coach", "9876543211", "Female", "3 years", "AIFF D Licence", "Ernakulam"),
        ("coach3@idsports.com", "Joseph Coach", "9876543212", "Male", "8 years", "AFC B Licence", "Aluva"),
    ]
    for email, name, mobile, gender, experience, certifications, address in staff:
        if db.query(User).filter(User.email == email).first():
            continue
        user = User(email=email, password_hash=hash_password("coach123"), role=UserRole.COACH)
        db.add(user)
        db.flush()
        db.add(
            Coach(
                user_id=user.user_id,
                admin_id=admin.admin_id,
                name=name,
                mobile=mobile,
                gender=gender,
                experience=experience,
                certifications=certifications,
                address=address,
            )
        )
    db.flush()

    coaches = db.query(Coach).order_by(Coach.coach_id).all()
    batch_coach = {batch.batch_id: coaches[index % len(coaches)] for index, batch in enumerate(batches)}
    today = date.today()

    for batch in batches:
        latest = (
            db.query(TrainingSession)
            .filter(TrainingSession.batch_id == batch.batch_id)
            .order_by(TrainingSession.date.desc())
            .first()
        )
        start = latest.start if latest else time(16, 0)
        end = latest.end if latest else time(17, 30)
        for weeks in (1, 2):
            day = today - timedelta(weeks=weeks)
            exists = (
                db.query(TrainingSession)
                .filter(TrainingSession.batch_id == batch.batch_id, TrainingSession.date == day)
                .first()
            )
            if exists is None:
                db.add(TrainingSession(batch_id=batch.batch_id, date=day, start=start, end=end, ground="Main ground"))
    db.flush()

    for session in db.query(TrainingSession).all():
        if not db.query(SessionAssignment).filter(SessionAssignment.session_id == session.session_id).first():
            db.add(
                SessionAssignment(
                    session_id=session.session_id,
                    coach_id=batch_coach[session.batch_id].coach_id,
                    assigned_by=admin.admin_id,
                )
            )
    db.flush()

    past = db.query(TrainingSession).filter(TrainingSession.date < today).all()
    for session in past:
        assignments = db.query(SessionAssignment).filter(SessionAssignment.session_id == session.session_id).all()
        for assignment in assignments:
            marked = (
                db.query(CoachAttendance)
                .filter(CoachAttendance.session_id == session.session_id, CoachAttendance.coach_id == assignment.coach_id)
                .first()
            )
            if marked is None:
                status = AttendanceStatus.ABSENT if (session.session_id + assignment.coach_id) % 6 == 0 else AttendanceStatus.PRESENT
                db.add(CoachAttendance(session_id=session.session_id, coach_id=assignment.coach_id, status=status))
        marker = assignments[0].coach_id if assignments else batch_coach[session.batch_id].coach_id
        enrolled = db.query(Enrollment).filter(Enrollment.batch_id == session.batch_id).all()
        for enrollment in enrolled:
            marked = (
                db.query(StudentAttendance)
                .filter(
                    StudentAttendance.session_id == session.session_id,
                    StudentAttendance.student_id == enrollment.student_id,
                )
                .first()
            )
            if marked is None:
                status = AttendanceStatus.ABSENT if (session.session_id + enrollment.student_id) % 5 == 0 else AttendanceStatus.PRESENT
                db.add(
                    StudentAttendance(
                        session_id=session.session_id,
                        student_id=enrollment.student_id,
                        marked_by_coach_id=marker,
                        status=status,
                    )
                )

    opponents = ["Fort Kochi FC", "Marine Drive United", "Kakkanad Rangers", "Edappally Strikers"]
    for index, batch in enumerate(batches):
        if db.query(Match).filter(Match.batch_id == batch.batch_id).first():
            continue
        opponent = opponents[index % len(opponents)]
        db.add_all(
            [
                Match(
                    batch_id=batch.batch_id,
                    title=f"{batch.name} vs {opponent}",
                    opponent=opponent,
                    venue="Jawaharlal Nehru Stadium, Kochi",
                    date=today + timedelta(days=5 + index),
                    start=time(17, 0),
                    end=time(18, 30),
                    status=MatchStatus.UPCOMING,
                ),
                Match(
                    batch_id=batch.batch_id,
                    title=f"{batch.name} vs {opponents[(index + 1) % len(opponents)]}",
                    opponent=opponents[(index + 1) % len(opponents)],
                    venue="Regional Sports Centre, Kadavanthra",
                    date=today - timedelta(days=10 + index),
                    start=time(16, 0),
                    end=time(17, 30),
                    status=MatchStatus.PREVIOUS,
                    result=f"Won {2 + index % 2}-1",
                ),
            ]
        )

    if not db.query(Leave).first():
        leaves = [
            (0, -20, -18, "Family function", LeaveStatus.APPROVED),
            (1, 5, 6, "Coaching licence course", LeaveStatus.PENDING),
            (2, -9, -9, "Medical appointment", LeaveStatus.APPROVED),
            (0, 12, 14, "Travel to hometown", LeaveStatus.PENDING),
            (1, -3, -2, "Personal work", LeaveStatus.REJECTED),
        ]
        for index, start_offset, end_offset, reason, status in leaves:
            coach = coaches[index % len(coaches)]
            db.add(
                Leave(
                    coach_id=coach.coach_id,
                    from_date=today + timedelta(days=start_offset),
                    to_date=today + timedelta(days=end_offset),
                    reason=reason,
                    status=status,
                )
            )
    db.commit()


def seed_profile_details(db: Session) -> None:
    """Fill empty profile, batch, session, and match details without overwriting saved values."""
    women = {"Diya", "Sneha", "Ananya", "Meera", "Nila", "Sara", "Aisha", "Pooja"}
    positions = ["Forward", "Midfielder", "Defender", "Goalkeeper", "Winger"]
    schools = ["St. Teresa's School", "Bhavans Vidya Mandir", "Chinmaya Vidyalaya", "Rajagiri Public School", "Kendriya Vidyalaya"]
    blood_groups = ["O+", "A+", "B+", "AB+", "O-", "B-"]
    allergies = ["None", "Dust", "None", "Peanuts", "None", "Pollen"]
    notes = [
        "Strong first touch, work on weaker foot.",
        "Good positioning, needs more vocal leadership.",
        "Quick off the mark, improve finishing.",
        "Reads the game well, build stamina.",
        "Confident on the ball, track back more.",
    ]

    for index, student in enumerate(db.query(Student).order_by(Student.student_id).all()):
        first, _, last = student.name.partition(" ")
        student.first_name = student.first_name or first
        student.last_name = student.last_name or last or first
        student.gender = student.gender or ("Female" if first in women else "Male")
        student.mobile = student.mobile or student.parent_mobile
        student.dob = student.dob or date(2010 + index % 5, index % 12 + 1, index % 27 + 1).isoformat()
        student.emergency_contact = student.emergency_contact or f"98470{student.student_id:05d}"
        student.guardian_name = student.guardian_name or f"Parent of {first}"
        student.position = student.position or positions[index % len(positions)]
        student.preferred_foot = student.preferred_foot or ("Left" if index % 4 == 0 else "Right")
        student.school = student.school or schools[index % len(schools)]
        student.school_class = student.school_class or str(5 + index % 6)
        student.jersey = student.jersey or str(student.student_id + 1)
        student.blood_group = student.blood_group or blood_groups[index % len(blood_groups)]
        student.allergies = student.allergies or allergies[index % len(allergies)]
        student.coach_note = student.coach_note or notes[index % len(notes)]

    headlines = ["Head coach, youth football", "Goalkeeping and fitness coach", "Technical skills coach"]
    for index, coach in enumerate(db.query(Coach).order_by(Coach.coach_id).all()):
        coach.dob = coach.dob or date(1985 + index * 3, index * 4 + 2, index * 7 + 5)
        coach.emergency_contact = coach.emergency_contact or f"94470{coach.coach_id:05d}"
        coach.headline = coach.headline or headlines[index % len(headlines)]

    batch_details = [
        ("Main gate, Pitch A", "Ball control and passing", "Training bib, shin guards, water bottle"),
        ("Pavilion, Pitch A", "Small-sided games", "Academy jersey, boots, water bottle"),
        ("Car park, Pitch B", "Fitness and finishing", "Training bib, boots, cap"),
        ("Clubhouse, Pitch B", "Defending shape", "Academy jersey, shin guards, towel"),
    ]
    for index, batch in enumerate(db.query(Batch).order_by(Batch.batch_id).all()):
        meeting_point, focus, kit = batch_details[index % len(batch_details)]
        batch.meeting_point = batch.meeting_point or meeting_point
        batch.focus = batch.focus or focus
        batch.kit = batch.kit or kit

    grounds = ["Pitch A", "Pitch B", "Main ground"]
    session_notes = ["Warm-up at the cones", "Bring both kits", "Match practice in the second half", "Fitness test today"]
    for index, session in enumerate(db.query(TrainingSession).order_by(TrainingSession.session_id).all()):
        session.ground = session.ground or grounds[index % len(grounds)]
        session.note = session.note or session_notes[index % len(session_notes)]

    for match in db.query(Match).all():
        match.venue = match.venue or "Jawaharlal Nehru Stadium, Kochi"
    db.commit()


def seed_admin_mobile(db: Session) -> None:
    admin = db.query(SuperAdmin).order_by(SuperAdmin.admin_id).first()
    if admin is None or admin.mobile == "9847002211":
        return
    admin.mobile = "9847002211"
    db.commit()


def seed_matches_if_empty(db: Session) -> None:
    if db.query(Match).first():
        return
    batch = db.query(Batch).order_by(Batch.batch_id).first()
    if batch is None:
        return
    today = date.today()
    db.add_all(
        [
            Match(
                batch_id=batch.batch_id,
                title="Kochi United",
                opponent="Kochi United",
                date=today + timedelta(days=6),
                start=time(17, 30),
                end=time(19, 0),
                status=MatchStatus.UPCOMING,
            ),
            Match(
                batch_id=batch.batch_id,
                title="Academy Cup",
                opponent="Academy Cup",
                date=today + timedelta(days=13),
                start=time(7, 30),
                end=time(9, 0),
                status=MatchStatus.UPCOMING,
            ),
            Match(
                batch_id=batch.batch_id,
                title="Harbour FC",
                opponent="Harbour FC",
                date=today - timedelta(days=20),
                start=time(16, 0),
                end=time(17, 30),
                status=MatchStatus.PREVIOUS,
            ),
        ]
    )
    db.commit()
