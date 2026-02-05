# Tymio

**Tymio** is a mobile attendance app for teams. Employees check in and out (with optional location verification); employers set an office area and see their team’s attendance.

---

## Features

### Employees
- **Register / log in** and link to an employer using their **employer code**
- **Check in / check out** as often as needed per day (multiple sessions)
- **Location** captured for each check-in/out when available; check-in can be restricted to the office area (geofencing)
- **Today’s sessions** listed on the dashboard; **History** screen for full attendance

### Employers
- **Register / log in** and get a unique **employer code** to share with employees
- **Set office location** (dashboard card “Office location for check-in” or **Settings** → use current location, set radius 25–1000 m) so employees can only check in/out when within that area
- **Employee list** — tap an employee to see their full attendance history (dates, times, status)
- **Settings** (gear icon) for office location and radius

Data is scoped per employer: each employer only sees their own employees and attendance.

---

## Tech stack

| Layer     | Choice                          |
|----------|----------------------------------|
| Framework| Flutter                          |
| State    | Riverpod                         |
| Backend  | Firebase (Auth + Firestore)      |
| Location | Geolocator (geofencing)         |
| Icons    | Solar Icons                      |
| Fonts    | Google Fonts (Poppins)           |

Feature-based structure: **data** / **domain** / **presentation** per feature.

---

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK ^3.10.8)
- A [Firebase](https://console.firebase.google.com) project
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup#configure-flutterfire):  
  `dart pub global activate flutterfire_cli`

---

## Getting started

### 1. Clone and install

```bash
git clone https://github.com/amirhosseinghanipour/tymio.git
cd tymio
flutter pub get
```

### 2. Firebase config (local, not committed)

1. Copy the template:  
   `cp lib/firebase_options.example.dart lib/firebase_options.dart`
2. Generate your config:  
   `flutterfire configure`  
   This overwrites `lib/firebase_options.dart`. Do not commit it (it’s in `.gitignore`).

### 3. Firebase Console

In your [Firebase project](https://console.firebase.google.com):

1. **Authentication** → Sign-in method → enable **Email/Password**
2. **Firestore** → Create database (e.g. test mode first, then lock down with rules)
3. **Firestore → Rules** — example (adjust as needed):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null
        && (request.auth.uid == userId || resource.data.employerId == request.auth.uid);
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update, delete: if request.auth != null && request.auth.uid == userId;
    }
    match /attendance/{docId} {
      allow read, write: if request.auth != null;
    }
    match /companies/{employerId} {
      allow read, write: if request.auth != null && request.auth.uid == employerId;
    }
  }
}
```

4. **Indexes** — create any composite indexes Firestore suggests (e.g. `attendance`: `userId` + `date`)

### 4. Run

```bash
flutter run
```

---

## Project structure

```
lib/
├── main.dart
├── firebase_options.example.dart
├── core/
│   ├── constants/     # app_colors
│   ├── theme/         # app_theme (light/dark)
│   ├── utils/         # validators
│   └── widgets/       # custom_button, custom_text_field
└── features/
    ├── auth/          # login, register, user/role, employer code
    │   ├── data/      # auth_repository_impl, user_model
    │   ├── domain/    # app_user, auth_repository_interface
    │   └── presentation/  # auth_provider, login_screen, register_screen
    └── attendance/
        ├── data/      # attendance_repository_impl, attendance_model
        ├── domain/    # attendance, attendance_repository_interface
        └── presentation/
            ├── providers/  # attendance_provider
            └── screens/    # employee_dashboard, employee_history_screen,
                            # employer_dashboard, employer_settings_screen,
                            # employee_detail_screen
```

---

## Firestore data

| Collection   | Purpose |
|-------------|---------|
| `users`    | User profile: name, email, role (`employee` / `employer`), `employerId` (for employees) |
| `attendance` | One doc per check-in: `userId`, `checkIn`, `checkOut`, `date`, optional `checkInLat`/`checkInLng`, `checkOutLat`/`checkOutLng` |
| `companies` | Per employer (`doc id = employerId`): `officeLat`, `officeLng`, `officeRadiusMeters` for geofencing |

---

## Location / geofencing

- **Android**: `AndroidManifest.xml` includes `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`
- **iOS**: `Info.plist` includes location usage descriptions
- Employer sets office in **Settings** (or “Office location for check-in” on dashboard). Employees must be within the set radius to check in when geofencing is configured; if location is unavailable or not set, check-in still works without location.

---

## Building for release

- **Android**: `flutter build apk` or `flutter build appbundle`
- **iOS**: `flutter build ios`, then open `ios/Runner.xcworkspace` in Xcode for signing and archive

---

## Ignored files

In `.gitignore` (do not commit):

- `lib/firebase_options.dart`
- `.env`, `.env.*`
- `google-services.json`, `GoogleService-Info.plist`

---

## License

This project is open source. See the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions are welcome. Open an issue or a pull request. To run locally: `flutter pub get`, copy `firebase_options.example.dart` to `firebase_options.dart`, run `flutterfire configure`, and use your own Firebase project.
