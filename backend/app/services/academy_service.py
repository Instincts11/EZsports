from sqlalchemy.orm import Session

from app.core.dependencies import CurrentUser
from app.core.exceptions import AppError, NotFoundError
from app.models import Academy
from app.schemas import AcademyCreate, AcademyResponse, AcademyUpdate


def get_academy(db: Session, current: CurrentUser) -> AcademyResponse:
    if current.academy_id is None:
        raise NotFoundError("Academy not found")
    academy = db.get(Academy, current.academy_id)
    if academy is None:
        raise NotFoundError("Academy not found")
    return AcademyResponse.model_validate(academy)


def update_academy(db: Session, current: CurrentUser, payload: AcademyUpdate) -> AcademyResponse:
    if current.academy_id is None:
        raise NotFoundError("Academy not found")
    academy = db.get(Academy, current.academy_id)
    if academy is None:
        raise NotFoundError("Academy not found")
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise AppError(422, "No academy changes were sent")
    for field, value in changes.items():
        setattr(academy, field, value)
    db.commit()
    db.refresh(academy)
    return AcademyResponse.model_validate(academy)


def create_academy(db: Session, payload: AcademyCreate) -> Academy:
    academy = Academy(name=payload.name, sport=payload.sport)
    db.add(academy)
    db.flush()
    return academy
