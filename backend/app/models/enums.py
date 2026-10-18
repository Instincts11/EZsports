import enum


class UserRole(str, enum.Enum):
    SUPER_ADMIN = "super_admin"
    ACCOUNTANT = "accountant"
    COACH = "coach"
    PLAYER = "player"


class BillStatus(str, enum.Enum):
    DUE = "due"
    PAID = "paid"
    OVERDUE = "overdue"


class AttendanceStatus(str, enum.Enum):
    PRESENT = "present"
    ABSENT = "absent"


class MatchStatus(str, enum.Enum):
    UPCOMING = "upcoming"
    ONGOING = "ongoing"
    PREVIOUS = "previous"


class LeaveStatus(str, enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
