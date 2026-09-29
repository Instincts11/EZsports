# ID Sports (ezsports)

Academy app for a coach and a player. The Flutter UI is in `lib/`. The Python API is in `backend/`.

The player and coach screens use demo academy data. You can open the app without starting the API.

## Requirements

- Windows with PowerShell
- [Flutter](https://docs.flutter.dev/get-started/install/windows) stable, with Dart 3.3 or newer (this project runs on Flutter 3.47.5)
- Google Chrome
- Python 3.11 or newer, only if you also start the API (this project runs on Python 3.13)

Check the tools from the project folder:

```powershell
flutter --version
python --version
```

If `flutter` is not recognized, this checkout includes a local SDK that is not committed. Use that instead of `flutter` in every command below:

```powershell
.\.tooling\flutter\bin\flutter.bat --version
```

## Run the app in Chrome

Open PowerShell in the project root (`ezsports`, the folder that contains `pubspec.yaml`).

```powershell
flutter pub get
flutter run -d chrome
```

With the local SDK:

```powershell
.\.tooling\flutter\bin\flutter.bat pub get
.\.tooling\flutter\bin\flutter.bat run -d chrome
```

Wait until the terminal prints a localhost URL and Chrome opens the login screen.

On that screen:

1. **Continue as player** opens the player app (Home, Batches, Schedule, Profile).
2. **Continue as coach** opens the coach app (Home, Batches, Players, Sessions, Profile).

The email and password fields are filled with `coach@idsports.com` and `coach123`. Those two buttons do not send them to the API.

While `flutter run` is active:

| Key | Action |
| --- | --- |
| `r` | Reload the UI after a code change |
| `R` | Restart the app |
| `q` | Stop the app |

### Check phone sizes in Chrome

The app fills the window when the window is narrower than 600px. A wide desktop window shows a 390px-wide phone frame.

1. Press `F12` to open DevTools.
2. Press `Ctrl+Shift+M` to open the device toolbar.
3. Pick a device (iPhone SE, a 360px-wide Android phone, Pixel 7, iPhone 14 Pro Max) and open each tab for player and coach.

### Run the widget tests

```powershell
flutter test
```

## Run the API

Start this in a second terminal when you want the backend. The Flutter screens above do not call it.

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
python run.py
```

If PowerShell blocks the activate script, allow it for this window only, then activate again:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

You can skip activation and call the venv Python directly:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
Copy-Item .env.example .env
.\.venv\Scripts\python.exe run.py
```

The API listens on port 8000.

- Docs: http://127.0.0.1:8000/docs
- Health: http://127.0.0.1:8000/health

The database file `backend/id_sports.db` is created on first start and filled when it is empty. Seeded logins:

| Role | Email | Password |
| --- | --- | --- |
| Super Admin | `admin@idsports.com` | `admin123` |
| Accountant | `accountant@idsports.com` | `accountant123` |
| Coach | `coach@idsports.com` | `coach123` |

Stop the API with `Ctrl+C` in that terminal.

## Project layout

```
ezsports/
├── pubspec.yaml          # Flutter package
├── lib/                  # Flutter app
│   ├── main.dart
│   ├── core/             # theme, router, shared widgets
│   └── features/         # auth, home, player, classes, students, profile, ...
├── test/                 # widget tests
├── assets/
└── backend/              # FastAPI
    ├── run.py
    ├── requirements.txt
    ├── .env.example
    └── app/
```
