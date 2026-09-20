from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.database import Base, SessionLocal, engine
from app.db.seed import seed_if_empty
from app import models  # noqa: F401

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    description=(
        "ID Sports academy API for Super Admin, Accountant, and Coach workflows. "
        "All routes are under `/api/v1`. Login with POST `/api/v1/auth/login`, then "
        "click Authorize and paste the `access_token` for GET `/api/v1/auth/me`."
    ),
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_if_empty(db)
    finally:
        db.close()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
