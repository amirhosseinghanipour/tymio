# Tymio

**Tymio** is an attendance tracking app for teams. Employees check in and out; employers see who worked and for how long, with simple analytics by day, week, or month.

---

## Features

### For employees
- **Register / log in** and link to your employer using their **employer code**
- **Check in** and **check out** with one tap
- **View your attendance history** (dates, check-in/out times, status)

### For employers
- **Register / log in** and get a unique **employer code** to share with your team
- **See all linked employees** and tap any employee to view their full attendance history
- **Analytics**: who worked how much — **today**, **this week**, or **this month** (total hours and days worked per employee)

Data is scoped by employer: each employer only sees their own employees and attendance.

---

## Tech stack

| Layer        | Choice              |
|-------------|---------------------|
| Framework   | Flutter             |
| State       | Riverpod            |
| Backend     | Firebase (Auth + Firestore) |
| Icons       | Solar Icons         |
| Fonts       | Google Fonts (Poppins) |

The app follows a **feature-based** structure with **data / domain / presentation** layers per feature.

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

### 2. Firebase (local config — not committed)

Secrets and Firebase config are **not** in the repo. Set them up locally:

1. **Copy the Firebase options template**  
   From the project root:
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   ```
2. **Generate your config**  
   Log in to Firebase and link the app:
   ```bash
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart` with your project’s config. **Do not commit this file** (it’s in `.gitignore`).

### 3. Firebase Console setup

In [Firebase Console](https://console.firebase.google.com) for your project:

1. **Authentication** → Sign-in method → enable **Email/Password**.
2. **Firestore Database** → Create database (e.g. start in test mode, then tighten rules).
3. **Firestore → Rules** — use rules that:
   - Let users read/write their own `users` doc and let employers read `users` docs where `employerId == request.auth.uid`.
   - Let authenticated users read/write `attendance` (restrict further if needed).

   Example:

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
     }
   }
   ```

4. **Indexes**  
   If Firestore prompts for composite indexes (e.g. for `attendance` queries by `userId` and `date`), create them via the link in the error message or in Firestore → Indexes.

### 4. Run the app

```bash
flutter run
```

---

## Project structure

```
lib/
├── main.dart                 # App entry, Firebase init, auth routing
├── firebase_options.example.dart   # Template (copy → firebase_options.dart)
├── core/                     # Shared UI, theme, utils
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
└── features/
    ├── auth/                 # Login, register, user roles
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── attendance/           # Check-in/out, history, employer analytics
        ├── data/
        ├── domain/
        └── presentation/
```

- **data**: repositories, models (Firebase).
- **domain**: entities, repository interfaces.
- **presentation**: Riverpod providers, screens, widgets.

---

## Building for release

- **Android**  
  `flutter build apk` or `flutter build appbundle`
- **iOS**  
  `flutter build ios` then open `ios/Runner.xcworkspace` in Xcode for signing and archive.

---

## Ignored files (secrets / local config)

These are listed in `.gitignore` and should not be committed:

- `lib/firebase_options.dart` — your Firebase config (use the example template and `flutterfire configure`).
- `.env`, `.env.*` — any environment or API keys.
- `google-services.json`, `GoogleService-Info.plist` — use your own Firebase project files locally.

---

## License

This project is open source. See the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions are welcome. Please open an issue or a pull request. Ensure the app runs after `flutter pub get`, copying `firebase_options.example.dart` to `firebase_options.dart`, and configuring your own Firebase project.
