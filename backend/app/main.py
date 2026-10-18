from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.database import Base, SessionLocal, engine
from app.core.schema_migrate import ensure_runtime_schema
from app.db.seed import seed_if_empty
from app import models  # noqa: F401

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    description=(
        "ID Sports academy API for Super Admin, Accountant, Coach, and Player workflows. "
        "All routes are under `/api/v1`. Players sign up once with OTP via "
        "`POST /api/v1/auth/signup/request-otp` then `POST /api/v1/auth/signup/verify-otp`. "
        "Later logins use `POST /api/v1/auth/login`."
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
    db = SessionLocal()
    try:
        seed_if_empty(db)
    finally:
        db.close()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
