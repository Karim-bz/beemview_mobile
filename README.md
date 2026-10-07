# BeemView Mobile

A small Flutter mobile app for browsing projects, viewing project tasks, and updating task.

---

## Table of Contents

1. [Overview](#overview)
2. [Setup & Run](#setup--run)
3. [Environment & Versions](#environment--versions)
4. [Packages](#packages)
5. [Configuration](#configuration)
6. [API Layer](#api-layer)

---

## 1 - Overview

BeemView Mobile is a small standalone Flutter app that lets an authenticated user browse the projects they have access to, view project's tasks, view task details, and update a task's status (with an optional comment).

The app focuses on a single, tight core flow:
Login > Projects > Project Tasks > Task Details > Update Status

---

## 2 - Setup & Run

### Prerequisites

- Flutter SDK (see [Environment & Versions](#environment--versions))
- Dart SDK (bundled with Flutter)
- An Android emulator/device (primary target) or iOS simulator
- Network access to access and use API's

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Karim-bz/beemview_mobile
cd beemview_mobile

# 2. Install dependencies
flutter pub get

# 3. Create your local config from the committed template
cp lib/core/config.local.example.dart lib/core/config.local.dart

# 4. Edit lib/core/config.local.dart and fill in the API URL and the supplied subdomain.
#    (this file is gitignored — do not commit it)

# 5. Run the app
flutter run
```
---

## 3 - Environment & Versions

```markdown
- Flutter:  3.47.6 (stable)
- Dart: 3.13.5

Target platforms:

- **Android** — primary target, tested on emulator and/or physical device.
- **iOS** — supported by the code but not verified for this submission.
```

## 4 - Packages

### Runtime dependencies

| Package | Purpose |
|---|---|
| `provider` | State management. Chosen for its simplicity, testability, and clean fit with per-screen `ChangeNotifier` state. |
| `dio` | HTTP client for API requests with interceptors for authentication and error handling. |
| `flutter_secure_storage` | Securely stores session tokens on the device. |
| `intl` | For Date formatting. |
| `connectivity_plus` | Detects when the device has no network interface, so we can show an offline banner and fail requests fast. |

### Dev dependencies

| Package | Purpose |
|---|---|
| `flutter_lints` | Standard Dart/Flutter lint rules. |
| `mocktail` | Mocking utilities for unit and widget tests. |

---

## 5 - Configuration

The API origin and tenant subdomain are preconfigured. Configuration is split across
two files:

| File | Committed? | Purpose |
|---|---|---|
| `lib/core/config.local.example.dart` | ✅ Yes | Template with placeholder values. |
| `lib/core/config.local.dart` | ❌ No (gitignored) | Real values for your environment. |

### Setup

```bash
cp lib/core/config.local.example.dart lib/core/config.local.dart
```

---
## 6 - API Layer

All requests go through `ApiClient` (`lib/core/api_client.dart`), a thin wrapper around `dio`.

- Base URL: `AppConfig.apiBaseUrl`.
- Every request gets `Content-Type: application/json` and the auth header `Authorization: Bearer <token>` when a token is stored.
- Every failure becomes an `ApiException` (see below).
- A 401 response triggers `onUnauthorized`, which sends the user back to login.

Tokens are kept in secure storage. Nothing sensitive is committed.

### Error Handling

Every API failure is an `ApiException` with a `message` and an optional `statusCode`.

- Network/timeout errors have `isNetworkError = true`.
- `isUnauthorized` (401) → session expired, return to login.
- `isForbidden` (403) → access denied, session still valid.

Screens show `message` and a retry button when the error is recoverable.
