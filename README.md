# BeemView Mobile

A small Flutter app to browse projects, view their tasks, and update a task's status.

**Flow:** Login → Projects → Project Tasks → Task Details → Update Status

---

## Download

[⬇ Download the Android APK](https://github.com/Karim-bz/beemview_mobile/raw/main/apk/beemview_mobile.apk)

---

## What the app does

- **Login** with email, password and tenant subdomain. The session is saved securely and restored when the app restarts.
- **Projects**: list of your projects with a "Load more" button.
- **Project tasks**: list of a project's tasks, with a name search and a status filter. Both work on the tasks already loaded.
- **Task details**: description, project, assignees, dates, status, priority and the latest comment.
- **Update status**: pick a new status and add an optional note. The note is sent as a separate comment.

---

## Quick start

**You need:** Flutter 3.47.6 and Dart 3.13.5, plus an Android emulator or phone (iOS is not tested).

```bash
# 1. Get the code
git clone https://github.com/Karim-bz/beemview_mobile
cd beemview_mobile

# 2. Install packages
flutter pub get

# 3. Create your local config
cp lib/core/config.local.example.dart lib/core/config.local.dart

# 4. Open lib/core/config.local.dart and fill in the API URL and your tenant subdomain

# 5. Run
flutter run
```

`config.local.dart` is ignored by Git, so your values are never committed.

---

## Project structure

```
lib/
  core/       API client, config, secure storage, theme, helpers
  data/
    models/         typed data classes
    repositories/   API calls (auth, projects, tasks)
  features/   one folder per feature: provider + screens
  shared/     reusable widgets (pills, sheets, loading/empty/error views)
test/         unit tests
```

The flow of data is always:

**Screen → Provider → Repository → API client**

Screens never call the API directly.

---

## How it works

### State management: Provider

Each feature has a small `ChangeNotifier` provider (auth, projects, project tasks, task details).
It keeps the state of the screen: loading, empty, error or loaded.
I chose Provider because the app is small and Provider is simple and easy to test.

### Cleaning up the API data

The API is not consistent between the task list and task details, so the models fix it:

- Dates: `dueDate` / `startedDate` in the list, `due_date` / `start_date` in details.
- Priority: `High` in the list, `high` in details. The app always uses lowercase.
- Missing or `null` values are handled safely.

Progress is tracked only through the task status. The app never shows or sends a progress percentage.

### Updating a status

1. Open a task and tap its status.
2. Pick a new status, add an optional note, and save.
3. The app sends the status first, then the note as a comment (if there is one).
4. The task is reloaded to show the new data.

If the status is saved but the note fails, the app keeps the note on screen and offers **Retry note** or **Discard note**.
Retry only sends the comment, never the status again.
There is no automatic retry, so a comment is never sent twice by accident.
While a save is running, the buttons are disabled to stop double submits.

### Errors

- **401**: the session is cleared and you go back to the login screen.
- **403, 404, 429, 500, timeout, no network**: a clear message is shown, with a retry button when it makes sense.
- Empty lists show an empty state.

---

## Packages

| Package | Used for |
|---|---|
| `provider` | State management |
| `dio` | API requests |
| `flutter_secure_storage` | Saving the login token safely |
| `connectivity_plus` | Offline banner |
| `intl` | Date formatting |
| `google_fonts` | App fonts (downloaded on first use) |
| `mocktail` (dev) | Mocks in tests |

---

## Tests

```bash
flutter test
```

| File | What it checks |
|---|---|
| `status_and_format_test.dart` | Status labels and due-date helpers |
| `task_mapping_test.dart` | Task list and details responses are mapped correctly |

---

## Assumptions

- The tenant subdomain comes from the config file, not from the login screen.
- Projects load 10 at a time. Project tasks load all at once because that API has no pagination.
- Return up to 10 recent comments from the API, present a small comments history list.
- Status values are saved exactly as the API defines them (`to_do`, `in_progress`, `on_hold`, `review`, `changes_requested`, `blocked`, `done`, `canceled`).

---

## Known limitations

- Tested on Android only.
- The app also has screens outside the assignment (create project, create task, profile, notifications). The notifications screen is only a placeholder, and some buttons say "coming soon".
- Validation messages from the server (the `details` list) are not shown, only the main error text.
- No offline cache. Without a network the app shows a banner and retry buttons.
- Priority filtering is not implemented (it was optional).
- Tests cover data mapping and logic, not widgets.
- Logging out only clears the token on the phone, because the API has no logout route.