from pathlib import Path

from sqlalchemy import Boolean, create_engine, inspect, text

from app.core.config import settings
from app.core.database import Base, engine


def copy_sqlite_if_postgres_empty() -> None:
    """Bring the existing SQLite academy into an empty PostgreSQL database."""
    if not settings.database_url.startswith("postgresql"):
        return
    sqlite_path = Path(__file__).resolve().parents[2] / "id_sports.db"
    if not sqlite_path.exists():
        return
    with engine.connect() as connection:
        populated = connection.execute(text("SELECT COUNT(*) FROM users")).scalar() or 0
    if populated:
        return

    source = create_engine(f"sqlite:///{sqlite_path}")
    source_inspector = inspect(source)
    with source.connect() as src, engine.begin() as dest:
        for table in Base.metadata.sorted_tables:
            if table.name not in source_inspector.get_table_names():
                continue
            source_columns = {column["name"] for column in source_inspector.get_columns(table.name)}
            columns = [column for column in table.columns if column.name in source_columns]
            if not columns:
                continue
            rows = src.execute(text(f"SELECT * FROM {table.name}")).mappings().all()
            payload = []
            for row in rows:
                item = {}
                for column in columns:
                    value = row[column.name]
                    if isinstance(column.type, Boolean) and isinstance(value, int):
                        value = bool(value)
                    item[column.name] = value
                payload.append(item)
            if payload:
                dest.execute(table.insert(), payload)
            pk = list(table.primary_key.columns)
            if len(pk) != 1:
                continue
            pk_name = pk[0].name
            dest.execute(
                text(
                    f"SELECT setval(pg_get_serial_sequence('{table.name}', '{pk_name}'), "
                    f"COALESCE((SELECT MAX({pk_name}) FROM {table.name}), 1), true)"
                )
            )
