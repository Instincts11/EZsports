import asyncio
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.database import Base, SessionLocal, engine
from app.core.schema_migrate import ensure_runtime_schema
from app.core.sessions import day_ends_at
from app.db.postgres_copy import copy_sqlite_if_postgres_empty
from app.db.seed import seed_admin_mobile, seed_if_empty
from app.services.session_service import reset_finished_sessions
from app import models  # noqa: F401

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    description=(
        "ID Sports academy API for Super Admin, Accountant, Coach, and Player workflows. "
        "All routes are under `/api/v1`. Players sign up once with OTP via "
        "`POST /api/v1/auth/signup/request-otp` then `POST /api/v1/auth/signup/verify-otp`. "
        "Coaches and players sign in with `POST /api/v1/auth/login/request-otp` then "
        "`POST /api/v1/auth/login/verify-otp`, which sets `is_logged_in` to true until midnight India time. "
        "`POST /api/v1/auth/logout` sets it back to false."
    ),
)

_cors_origins = settings.cors_origin_list
if settings.app_env.lower() != "production":
    _cors_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins,
    allow_credentials=False if _cors_origins == ["*"] else True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)
    ensure_runtime_schema()
    copy_sqlite_if_postgres_empty()
    db = SessionLocal()
    try:
        seed_if_empty(db)
        seed_admin_mobile(db)
    finally:
        db.close()
    _reset_sessions()


def _reset_sessions() -> None:
    db = SessionLocal()
    try:
        reset_finished_sessions(db)
    finally:
        db.close()


async def _reset_sessions_each_midnight() -> None:
    while True:
        now = datetime.now(timezone.utc)
        await asyncio.sleep(max(1.0, (day_ends_at(now) - now).total_seconds()))
        await asyncio.to_thread(_reset_sessions)


@app.on_event("startup")
async def start_midnight_reset() -> None:
    app.state.midnight_reset = asyncio.create_task(_reset_sessions_each_midnight())


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
