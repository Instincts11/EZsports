from fastapi import APIRouter

from app.api.v1.endpoints import academy, accountants, auth, batches, bills, coach_app, coaches, sessions, students

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(academy.router)
api_router.include_router(accountants.router)
api_router.include_router(coaches.router)
api_router.include_router(students.router)
api_router.include_router(batches.router)
api_router.include_router(sessions.router)
api_router.include_router(bills.router)
api_router.include_router(coach_app.router)
