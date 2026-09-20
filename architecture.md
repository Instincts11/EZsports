> **This document is the definitive architecture prompt for this project.**
> All future development MUST follow these rules without exception.

---

## 1. Project Architecture

This project follows a **Feature-Based Clean Architecture** inspired by the **TMM project**.

```
lib/
├── main.dart
├── core/                          # Shared, cross-cutting concerns
│   ├── auth/                      # AuthSession (token management)
│   ├── config/                    # App-wide config (router, env, keys)
│   ├── constants/                 # AppColors, AppIcons, AppImages, AppTextStyles
│   ├── network/                   # ApiConstants, ApiEndpoints, DioClient
│   ├── theme/                     # AppTheme (ThemeData)
│   └── widgets/                   # Shared reusable widgets (buttons, fields, toasts, etc.)
│
└── features/                      # Feature modules (one per business domain)
    └── <feature_name>/
        ├── data/                  # Repository + models (API communication layer)
        │   ├── <feature>_repository.dart
        │   └── models/
        │       └── <model>.dart
        ├── presentation/          # UI layer
        │   ├── screens/           # Full page screens
        │   │   └── <screen>.dart
        │   └── widgets/           # Feature-specific reusable widgets
        │       └── <widget>.dart
        └── providers/             # Riverpod providers (state management)
            └── <feature>_providers.dart
```

---

## 2. Rules — NEVER Break These

### 2.1 Folder & File Structure
- **One feature = one folder** inside `features/`.
- Every feature MUST have `data/`, `presentation/`, and `providers/` sub-folders.
- Screens go in `presentation/screens/`. Feature-specific widgets go in `presentation/widgets/`.
- Shared widgets that are used across 2+ features MUST go in `core/widgets/`.
- Models go in `data/models/`. Repository goes directly in `data/`.

### 2.2 Constants & Theming
- **ALL colors** must be defined in `core/constants/app_colors.dart` — NEVER use raw `Color(0xFF...)` or `Colors.xxx` in UI code.
- **ALL icon paths** must be defined in `core/constants/app_icons.dart` — NEVER use raw string paths in UI code.
- **ALL image paths** must be defined in `core/constants/app_images.dart` — NEVER use raw string paths in UI code.
- **ALL text styles** must be defined in `core/constants/app_text_styles.dart` — NEVER create ad-hoc TextStyle objects in UI code.
- Every constant class uses `final class AppX { const AppX._(); ... }` pattern.

### 2.3 State Management
- Use **Riverpod** exclusively. No `setState()` unless absolutely necessary for local widget state (e.g., animations, text controllers).
- Providers go in the feature's `providers/` folder.
- Global/shared providers go in `core/providers/` if needed.

### 2.4 Networking
- Use **DioClient.instance** for ALL API calls.
- API base URL is in `core/network/api_constants.dart`.
- ALL endpoint paths are in `core/network/api_endpoints.dart`.
- Auth token is managed by `core/auth/auth_session.dart` — auto-injected via Dio interceptor.
- Repositories handle raw Dio calls and return typed models.

### 2.5 Code Quality
- **ZERO duplication**: If any UI pattern repeats 2+ times, extract it into a widget in `core/widgets/` or `feature/presentation/widgets/`.
- **ZERO magic values**: No hardcoded strings, colors, sizes, or paths anywhere in UI code.
- Use `const` constructors wherever possible.
- Use `final` for all local variables and fields.
- Always declare return types explicitly.
- Always use package imports (`import 'package:ezsports/...'`), never relative imports.

### 2.6 Naming Conventions
- **Files**: `snake_case.dart` (e.g., `billing_screen.dart`, `product_model.dart`)
- **Classes**: `PascalCase` (e.g., `BillingScreen`, `ProductModel`)
- **Constants**: `camelCase` (e.g., `AppColors.primary`, `AppIcons.add`)
- **Providers**: `camelCase` with descriptive names (e.g., `billingDataProvider`, `heldBillsProvider`)
- **Screens**: Suffix with `Screen` (e.g., `BillingScreen`, `LoginScreen`)
- **Widgets**: Descriptive name, no suffix needed (e.g., `ProductCard`, `BillSummary`)
- **Repositories**: Suffix with `Repository` (e.g., `BillingRepository`, `AuthRepository`)
- **Models**: Suffix with `Model` (e.g., `ProductModel`, `CustomerModel`)

### 2.7 Widget Extraction Rules
- If a widget tree exceeds **80 lines**, consider extracting sub-sections.
- If a widget is used in **2+ places**, it MUST be extracted.
- Feature-specific widgets → `feature/presentation/widgets/`
- Cross-feature widgets → `core/widgets/`
- Every extracted widget should be a `StatelessWidget` with `const` constructor unless it needs local mutable state.

---

## 3. API Architecture

- **Base URL**: `http://127.0.0.1:8000`
- **Auth**: JWT Bearer token (`Authorization: Bearer <token>`)
- **All academy routes** are prefixed with `/api/v1/`
- **Roles**: `super_admin`, `accountant`, `coach`
- **Response handling**: Repositories parse JSON and return typed Dart models
- **Error handling**: DioClient interceptor handles 401 globally; feature-level errors handled in repositories

Python backend lives in `backend/` (FastAPI + SQLAlchemy). Flutter talks to it only through `DioClient.instance` and `ApiEndpoints`.

| Area | Method | Path | Actor |
|---|---|---|---|
| Auth | POST | `/api/v1/auth/login` | All |
| Auth | GET | `/api/v1/auth/me` | All |
| Academy | GET | `/api/v1/academy` | All |
| Accountant | POST/GET | `/api/v1/accountants` | Super Admin |
| Coaches | POST/GET/PATCH | `/api/v1/coaches` | Super Admin, Coach |
| Students | POST/GET/PATCH | `/api/v1/students` | Super Admin, Coach, Accountant |
| Batches | POST/GET | `/api/v1/batches` | Super Admin, Coach |
| Enrollment | POST/DELETE | `/api/v1/batches/enrollments` | Super Admin |
| Sessions | POST/GET | `/api/v1/sessions` | Super Admin, Coach |
| Assignments | POST/PATCH | `/api/v1/sessions/assignments` | Super Admin |
| Coach attendance | POST/GET | `/api/v1/sessions/{id}/coach-attendance` | Coach (self), Super Admin |
| Student attendance | POST/GET | `/api/v1/sessions/{id}/student-attendance` | Coach |
| Roster | GET | `/api/v1/sessions/{id}/students` | Coach |
| Bills | POST/GET/PATCH | `/api/v1/bills` | Accountant write; Coach read-only fee status |
| Home | GET | `/api/v1/home` | Coach |
| Matches | POST/GET | `/api/v1/matches` | Super Admin, Coach |
| Profile | GET/PATCH | `/api/v1/profile` | Coach |
| Leaves | POST/GET | `/api/v1/leaves` | Coach |

Demo logins after backend seed:

- Super Admin: `admin@idsports.com` / `admin123`
- Accountant: `accountant@idsports.com` / `accountant123`
- Coach: `coach@idsports.com` / `coach123`

---

## 4. Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `flutter_secure_storage` | Secure token persistence |
| `flutter_svg` | SVG icon rendering |

---

## 5. Checklist Before Every PR / Feature

- [ ] No raw colors, strings, or text styles in UI code
- [ ] All reusable widgets extracted
- [ ] Feature folder has `data/`, `presentation/`, `providers/`
- [ ] Models have `fromJson()` factory constructors
- [ ] `flutter analyze` passes with zero issues
- [ ] No `print()` statements (use proper logging)
- [ ] All imports are package imports


Preserve the existing Feature-Based Clean Architecture.

When implementing new features or matching the Figma:

• Modify only the Presentation layer if the change is purely visual.
• Modify Providers when UI state or interactions require new state management.
• Modify Repositories only when new API endpoints or data-fetching logic are required.
• Modify Models only when the API response or required data structure changes.
• Modify Services/Core only when shared functionality is introduced or updated.

Never bypass the architecture by placing business logic inside widgets.

Always keep responsibilities within their respective layers.


## Design System

The UI must follow the Figma exactly.

Use the existing design system.

• Colors → AppColors
• Text Styles → AppTextStyles
• Icons → AppIcons
• Images → AppImages
• Theme → AppTheme

Do not introduce new colors, fonts, shadows, spacing values, or border radii unless they are first added to the shared constants.

If Figma introduces a new design token, add it to the appropriate constants file before using it.


Before creating a new widget, search the project for an existing reusable widget.

If a similar widget exists:

• Reuse it.
• Extend it if necessary.
• Do not create duplicate implementations.

Only create a new widget when no suitable reusable component exists.

## API Integration

When integrating an API:

1. Create or update the Model.
2. Update the Repository.
3. Update the Riverpod Provider.
4. Connect the UI.
5. Preserve existing error handling.
6. Preserve loading and empty states.
7. Never perform Dio calls directly from the UI.


## Figma Implementation Workflow

For every screen:

1. Analyze the Figma.
2. Analyze the existing Flutter implementation.
3. List all visual differences.
4. Reuse existing widgets where possible.
5. Update only the required layers.
6. Preserve all existing functionality.
7. Ensure pixel-perfect implementation.
8. Keep responsive behavior.
9. Follow the existing design system.
10. Do not redesign unless explicitly instructed.


## Responsive Layout

Every screen must support:

• Phones
• Tablets
• Landscape

Avoid fixed dimensions where possible.

Prefer:

Expanded
Flexible
LayoutBuilder
MediaQuery
Wrap
AspectRatio

Maintain the exact visual appearance from the Figma while adapting gracefully to different screen sizes.
