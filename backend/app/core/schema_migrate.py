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
