from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentUser, require_roles
from app.models.enums import UserRole
from app.schemas import (
    AssignmentCreate,
    AssignmentMove,
    AssignmentResponse,
    AttendanceMark,
    CoachAttendanceResponse,
    SessionCreate,
    SessionResponse,
    SessionRosterStudent,
    StudentAttendanceMark,
    StudentAttendanceResponse,
)
from app.services.attendance_service import (
    list_coach_attendance,
    list_student_attendance,
    mark_coach_attendance,
    mark_student_attendance,
    session_roster,
)
from app.services.operations_service import (
    assign_coach,
    create_session,
    get_session,
    list_session_coaches,
    list_sessions,
    move_coach,
)

router = APIRouter(prefix="/sessions", tags=["Sessions"])


@router.post("", response_model=SessionResponse)
def add_session(
    payload: SessionCreate,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> SessionResponse:
    return create_session(db, payload)


@router.get("", response_model=list[SessionResponse])
def read_sessions(
    batch_id: int | None = Query(default=None),
    date_from: date | None = Query(default=None),
    date_to: date | None = Query(default=None),
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[SessionResponse]:
    return list_sessions(db, current, batch_id, date_from, date_to)


@router.get("/{session_id}", response_model=SessionResponse)
def read_session(
    session_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> SessionResponse:
    return get_session(db, session_id)


@router.get("/{session_id}/students", response_model=list[SessionRosterStudent])
def read_session_students(
    session_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[SessionRosterStudent]:
    return session_roster(db, session_id)


@router.get("/{session_id}/coaches", response_model=list[AssignmentResponse])
def read_session_coaches(
    session_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[AssignmentResponse]:
    return list_session_coaches(db, session_id)


@router.post("/assignments", response_model=AssignmentResponse)
def add_assignment(
    payload: AssignmentCreate,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> AssignmentResponse:
    return assign_coach(db, current, payload)


@router.patch("/assignments/{assignment_id}", response_model=AssignmentResponse)
def change_assignment(
    assignment_id: int,
    payload: AssignmentMove,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN)),
) -> AssignmentResponse:
    return move_coach(db, assignment_id, payload)


@router.post("/{session_id}/coach-attendance", response_model=CoachAttendanceResponse)
def check_in_coach(
    session_id: int,
    payload: AttendanceMark,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> CoachAttendanceResponse:
    return mark_coach_attendance(db, current, session_id, payload)


@router.get("/{session_id}/coach-attendance", response_model=list[CoachAttendanceResponse])
def read_coach_attendance(
    session_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[CoachAttendanceResponse]:
    return list_coach_attendance(db, session_id)


@router.post("/{session_id}/student-attendance", response_model=StudentAttendanceResponse)
def mark_student(
    session_id: int,
    payload: StudentAttendanceMark,
    db: Session = Depends(get_db),
    current: CurrentUser = Depends(require_roles(UserRole.COACH)),
) -> StudentAttendanceResponse:
    return mark_student_attendance(db, current, session_id, payload)


@router.get("/{session_id}/student-attendance", response_model=list[StudentAttendanceResponse])
def read_student_attendance(
    session_id: int,
    db: Session = Depends(get_db),
    _: CurrentUser = Depends(require_roles(UserRole.SUPER_ADMIN, UserRole.COACH)),
) -> list[StudentAttendanceResponse]:
    return list_student_attendance(db, session_id)
