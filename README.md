# ID Sports (ezsports)

Academy product for Super Admin, Accountant, and Coach. Flutter client in `lib/`. Python API in `backend/`. Domain model follows `ID_Sports_Entity_Diagrams.pdf`.

## Run the API

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
python run.py
```

Open docs at `http://127.0.0.1:8000/docs`.

Seeded logins:

- Super Admin: `admin@idsports.com` / `admin123`
- Accountant: `accountant@idsports.com` / `accountant123`
- Coach: `coach@idsports.com` / `coach123`

## Folder structure

```
ezsports/
├── architecture.md
├── ID_Sports_Entity_Diagrams.pdf
├── pubspec.yaml
├── analysis_options.yaml
├── assets/
│   ├── icons/
│   └── images/
├── lib/                                      # Flutter UI
│   ├── main.dart
│   ├── core/
│   │   ├── auth/auth_session.dart
│   │   ├── config/app_env.dart
│   │   ├── config/app_router.dart
│   │   ├── constants/app_colors.dart
│   │   ├── constants/app_icons.dart
│   │   ├── constants/app_images.dart
│   │   ├── constants/app_text_styles.dart
│   │   ├── network/api_constants.dart
│   │   ├── network/api_endpoints.dart
│   │   ├── network/dio_client.dart
│   │   ├── theme/app_theme.dart
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── app_toast.dart
│   │       ├── date_range_filter.dart
│   │       └── session_card.dart
│   └── features/
│       ├── auth/
│       │   ├── data/auth_repository.dart
│       │   ├── data/models/user_model.dart
│       │   ├── presentation/screens/login_screen.dart
│       │   ├── presentation/widgets/login_form.dart
│       │   └── providers/auth_providers.dart
│       ├── home/
│       │   ├── data/home_repository.dart
│       │   ├── data/models/home_dashboard_model.dart
│       │   ├── presentation/screens/home_screen.dart
│       │   ├── presentation/widgets/attendance_rings.dart
│       │   ├── presentation/widgets/check_in_button.dart
│       │   ├── presentation/widgets/matches_strip.dart
│       │   ├── presentation/widgets/upcoming_class_card.dart
│       │   └── providers/home_providers.dart
│       ├── classes/
│       │   ├── data/classes_repository.dart
│       │   ├── data/models/session_model.dart
│       │   ├── presentation/screens/classes_screen.dart
│       │   ├── presentation/screens/classes_report_screen.dart
│       │   ├── presentation/widgets/class_session_card.dart
│       │   └── providers/classes_providers.dart
│       ├── students/
│       │   ├── data/students_repository.dart
│       │   ├── data/models/batch_model.dart
│       │   ├── data/models/student_model.dart
│       │   ├── presentation/screens/students_screen.dart
│       │   ├── presentation/screens/batch_roster_screen.dart
│       │   ├── presentation/widgets/batch_directory_card.dart
│       │   ├── presentation/widgets/student_list_tile.dart
│       │   └── providers/students_providers.dart
│       ├── attendance/
│       │   ├── data/attendance_repository.dart
│       │   ├── data/models/attendance_model.dart
│       │   ├── presentation/screens/student_attendance_screen.dart
│       │   ├── presentation/screens/coach_attendance_screen.dart
│       │   ├── presentation/widgets/attendance_toggle.dart
│       │   └── providers/attendance_providers.dart
│       ├── matches/
│       │   ├── data/matches_repository.dart
│       │   ├── data/models/match_model.dart
│       │   ├── presentation/screens/matches_screen.dart
│       │   ├── presentation/screens/create_match_screen.dart
│       │   ├── presentation/widgets/empty_matches.dart
│       │   └── providers/matches_providers.dart
│       ├── profile/
│       │   ├── data/profile_repository.dart
│       │   ├── data/models/coach_profile_model.dart
│       │   ├── presentation/screens/profile_screen.dart
│       │   ├── presentation/screens/edit_profile_screen.dart
│       │   ├── presentation/screens/coach_attendance_history_screen.dart
│       │   ├── presentation/screens/my_leaves_screen.dart
│       │   ├── presentation/widgets/profile_header.dart
│       │   └── providers/profile_providers.dart
│       ├── admin/                            # Super Admin web/setup
│       │   ├── data/admin_repository.dart
│       │   ├── data/models/coach_staff_model.dart
│       │   ├── presentation/screens/admin_home_screen.dart
│       │   ├── presentation/screens/manage_people_screen.dart
│       │   ├── presentation/screens/manage_batches_screen.dart
│       │   ├── presentation/screens/assign_accountant_screen.dart
│       │   ├── presentation/screens/assign_coaches_screen.dart
│       │   ├── presentation/widgets/admin_menu_tile.dart
│       │   └── providers/admin_providers.dart
│       └── bills/                            # Accountant finance lane
│           ├── data/bills_repository.dart
│           ├── data/models/bill_model.dart
│           ├── presentation/screens/bills_screen.dart
│           ├── presentation/screens/create_bill_screen.dart
│           ├── presentation/widgets/bill_status_chip.dart
│           └── providers/bills_providers.dart
└── backend/                                  # Python FastAPI
    ├── requirements.txt
    ├── .env.example
    ├── run.py
    └── app/
        ├── main.py
        ├── core/
        │   ├── config.py
        │   ├── database.py
        │   ├── security.py
        │   ├── dependencies.py
        │   └── exceptions.py
        ├── models/                           # ERD tables
        │   ├── enums.py
        │   ├── user.py
        │   ├── academy.py
        │   ├── super_admin.py
        │   ├── accountant.py
        │   ├── coach.py
        │   ├── student.py
        │   ├── batch.py
        │   ├── session.py
        │   ├── enrollment.py
        │   ├── session_assignment.py
        │   ├── bill.py
        │   ├── coach_attendance.py
        │   ├── student_attendance.py
        │   ├── match.py
        │   └── leave.py
        ├── schemas/__init__.py
        ├── services/
        │   ├── academy_service.py
        │   ├── people_service.py
        │   ├── operations_service.py
        │   ├── attendance_service.py
        │   ├── finance_service.py
        │   └── home_service.py
        ├── db/seed.py
        └── api/v1/
            ├── router.py
            └── endpoints/
                ├── auth.py
                ├── academy.py
                ├── accountants.py
                ├── coaches.py
                ├── students.py
                ├── batches.py
                ├── sessions.py
                ├── bills.py
                └── coach_app.py
```
