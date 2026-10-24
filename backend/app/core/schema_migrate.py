from sqlalchemy import inspect, text

from app.core.database import engine


def _add_column_if_missing(table: str, column: str, ddl: str) -> None:
    inspector = inspect(engine)
    if table not in inspector.get_table_names():
        return
    existing = {col["name"] for col in inspector.get_columns(table)}
    if column in existing:
        return
    with engine.begin() as connection:
        connection.execute(text(f"ALTER TABLE {table} ADD COLUMN {ddl}"))


def ensure_runtime_schema() -> None:
    """SQLite create_all does not alter existing tables; add new columns safely."""
    student_columns = (
        ("user_id", "user_id INTEGER"),
        ("first_name", "first_name VARCHAR(120)"),
        ("last_name", "last_name VARCHAR(120)"),
        ("dob", "dob VARCHAR(40)"),
        ("gender", "gender VARCHAR(40)"),
        ("mobile", "mobile VARCHAR(20)"),
        ("emergency_contact", "emergency_contact VARCHAR(20)"),
        ("guardian_name", "guardian_name VARCHAR(255)"),
        ("position", "position VARCHAR(120)"),
        ("preferred_foot", "preferred_foot VARCHAR(40)"),
        ("school", "school VARCHAR(255)"),
        ("school_class", "school_class VARCHAR(40)"),
        ("jersey", "jersey VARCHAR(20)"),
        ("blood_group", "blood_group VARCHAR(20)"),
        ("allergies", "allergies TEXT"),
        ("otp_verified_at", "otp_verified_at DATETIME"),
        ("created_at", "created_at DATETIME"),
    )
    for column, ddl in student_columns:
        _add_column_if_missing("students", column, ddl)
    _add_column_if_missing("super_admins", "mobile", "mobile VARCHAR(20)")
    _add_column_if_missing("sessions", "ground", "ground VARCHAR(255)")
    _add_column_if_missing("sessions", "note", "note VARCHAR(500)")
    _add_column_if_missing("matches", "venue", "venue VARCHAR(255)")
    _add_column_if_missing("matches", "result", "result VARCHAR(255)")
    _add_column_if_missing("academies", "notice", "notice VARCHAR(500)")
    _add_column_if_missing("academies", "phone", "phone VARCHAR(20)")
    _add_column_if_missing("academies", "address", "address VARCHAR(255)")
    _add_column_if_missing("academies", "range_start", "range_start DATE")
    _add_column_if_missing("academies", "range_end", "range_end DATE")
    _add_column_if_missing("batches", "kit", "kit VARCHAR(255)")
    _add_column_if_missing("batches", "meeting_point", "meeting_point VARCHAR(255)")
    _add_column_if_missing("batches", "focus", "focus VARCHAR(255)")
    _add_column_if_missing("coaches", "headline", "headline VARCHAR(255)")
    _add_column_if_missing("students", "coach_note", "coach_note VARCHAR(500)")
    _ensure_bill_parties()


def _ensure_bill_parties() -> None:
    inspector = inspect(engine)
    if "bills" not in inspector.get_table_names():
        return
    columns = inspector.get_columns("bills")
    names = {column["name"] for column in columns}
    student = next(column for column in columns if column["name"] == "student_id")
    if "coach_id" in names and student.get("nullable"):
        return
    with engine.begin() as connection:
        if engine.dialect.name == "sqlite":
            connection.execute(text("PRAGMA foreign_keys=OFF"))
            connection.execute(
                text(
                    """
                    CREATE TABLE bills_next (
                        bill_id INTEGER PRIMARY KEY,
                        student_id INTEGER,
                        coach_id INTEGER,
                        accountant_id INTEGER NOT NULL,
                        amount NUMERIC(10, 2) NOT NULL,
                        due_date DATE NOT NULL,
                        status VARCHAR(32) NOT NULL,
                        FOREIGN KEY(student_id) REFERENCES students (student_id),
                        FOREIGN KEY(coach_id) REFERENCES coaches (coach_id),
                        FOREIGN KEY(accountant_id) REFERENCES accountants (accountant_id)
                    )
                    """
                )
            )
            connection.execute(
                text(
                    """
                    INSERT INTO bills_next (bill_id, student_id, accountant_id, amount, due_date, status)
                    SELECT bill_id, student_id, accountant_id, amount, due_date, status FROM bills
                    """
                )
            )
            connection.execute(text("DROP TABLE bills"))
            connection.execute(text("ALTER TABLE bills_next RENAME TO bills"))
            return
        if "coach_id" not in names:
            connection.execute(text("ALTER TABLE bills ADD COLUMN coach_id INTEGER REFERENCES coaches (coach_id)"))
        if not student.get("nullable"):
            connection.execute(text("ALTER TABLE bills ALTER COLUMN student_id DROP NOT NULL"))

