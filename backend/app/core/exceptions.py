from fastapi import HTTPException, status


class AppError(HTTPException):
    def __init__(self, status_code: int, detail: str, headers: dict[str, str] | None = None) -> None:
        super().__init__(status_code=status_code, detail=detail, headers=headers)


class NotFoundError(AppError):
    def __init__(self, detail: str = "Resource not found") -> None:
        super().__init__(status.HTTP_404_NOT_FOUND, detail)


class ForbiddenError(AppError):
    def __init__(self, detail: str = "You do not have permission to perform this action") -> None:
        super().__init__(status.HTTP_403_FORBIDDEN, detail)


class UnauthorizedError(AppError):
    def __init__(self, detail: str = "Missing or invalid Bearer token. POST /api/v1/auth/login first.") -> None:
        super().__init__(
            status.HTTP_401_UNAUTHORIZED,
            detail,
            headers={"WWW-Authenticate": "Bearer"},
        )


class ConflictError(AppError):
    def __init__(self, detail: str = "Resource already exists") -> None:
        super().__init__(status.HTTP_409_CONFLICT, detail)
