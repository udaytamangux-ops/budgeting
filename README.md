# Budgeting

Budgeting is a mobile-first NPR budgeting application for young salaried professionals in Nepal. This repository currently establishes the Flutter foundation and the first connected product journey: reviewing the monthly position, adding an expense, seeing the updated budget immediately, and opening the saved transaction.

The application is ready for product and engineering review, but it is not production-complete. Authentication, persistent storage, synchronization, and backend services are intentionally deferred.

## Current scope

- Home summary with monthly income, expenses, available balance, budget progress, category attention, and recent transactions
- Full-screen expense and income form with validation, asynchronous save states, and failure recovery
- In-memory create, read, update, and delete transaction repository
- Lightweight saved-transaction confirmation with a direct details link
- Transaction details, reusable edit form foundation, and explicit delete confirmation
- Four-destination authenticated application shell using a temporary development session
- Loading, empty, populated, error, saving, success, not-found, deleting, and delete-failure states
- Centralized Material 3 design tokens, Inter typography, NPR/date formatting, and reduced-motion behavior
- Unit, widget, responsive-accessibility, and Android integration tests

## Prerequisites

- Flutter 3.44.8 stable or a compatible newer stable release
- Dart 3.12.2 or a compatible version supported by Flutter
- Android SDK with accepted licenses for Android builds
- Xcode on macOS for iOS builds
- An Android emulator or physical device for integration tests

Verify the local setup:

```powershell
flutter --version
dart --version
flutter doctor -v
```

## Setup and run

```powershell
flutter pub get
flutter run
```

Run on a specific device when more than one is available:

```powershell
flutter devices
flutter run -d <device-id>
```

## Quality checks

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test/expense_flow_test.dart -d <android-device-id>
flutter build apk --debug
```

The integration test covers Home → Add Expense → updated Home → Transaction Details using an NPR 1,250 Food expense.

## Architecture

The code uses a pragmatic feature-first structure. Domain rules and repository contracts are independent of Flutter UI, while presentation code is grouped by product feature.

```text
lib/
├── app/
│   ├── bootstrap/       # Provider container and temporary session setup
│   ├── routing/         # go_router routes and authenticated shell
│   └── theme/           # Semantic color, spacing, radius, motion, and type tokens
├── core/
│   ├── errors/          # Application-facing error types
│   ├── formatting/      # Centralized NPR and local-date formatters
│   ├── utilities/       # Replaceable clock dependency
│   └── widgets/         # Small cross-feature UI primitives
└── features/
    ├── auth/            # Development-session route placeholders
    ├── budgets/         # Budget policy, summaries, and presentation
    ├── home/            # Financial overview and focused summary sections
    ├── profile/         # Profile placeholder state
    └── transactions/    # Domain, in-memory data, controllers, and screens
```

### State management

`flutter_riverpod` provides repository dependency injection, the transaction stream, transaction lookup, calculated financial and budget summaries, asynchronous form submission, saved-transaction confirmation, and deletion state. Ephemeral field focus, text editing, expansion, and form selection remain local to the owning widgets.

### Navigation

`go_router` defines public authentication-ready routes, a state-preserving authenticated shell, transaction details, and a root-navigator full-screen transaction form. The center Add control is an action rather than a fifth navigation destination.

### Financial values

Money is stored as integer minor units in the `Money` value object. No financial amount uses `double`; for example, NPR 1,250.50 is stored as `125050`. Formatting is delegated to the centralized `CurrencyFormatter`.

### Data access

Presentation code depends on the `TransactionRepository` interface. `InMemoryTransactionRepository` supplies realistic Nepal-focused seed data, broadcasts changes, supports CRUD operations, simulates save latency, and exposes controlled failures for tests. It can be replaced with local and cloud implementations without changing screens.

## Packages

- `flutter_riverpod`: shared application state, async controllers, derived summaries, and dependency injection
- `go_router`: declarative routing, nested stateful navigation, and modal form presentation
- `intl`: centralized NPR currency and locale-aware date formatting
- `mocktail` (development): behavior-focused controller and repository tests
- `integration_test` (Flutter SDK): Android end-to-end journey verification
- `flutter_lints` (development): baseline static-analysis rules extended by this project

Inter is bundled as local font assets so the interface is deterministic offline and the typography implementation can be replaced centrally.

## Platform identifiers

The following temporary identifiers must be replaced with an organization-owned reverse-domain identifier before release:

- Android application ID: `np.com.budgeting.prototype.budgeting_app`
- iOS bundle identifier: `np.com.budgeting.prototype.budgetingApp`

Changing identifiers requires updating platform configuration and any future signing, deep-linking, notification, and backend registrations together.

## Deferred integrations

- Real authentication and route redirects
- Drift or another persistent local data store
- Supabase or another cloud synchronization service
- Secure environment configuration and production flavors
- Notifications, goals, analytics, and AI-assisted insights
- Production application icons, signing, store metadata, privacy policy, and release automation

## Known limitations

- Data resets whenever the process restarts because the repository is in memory.
- The temporary development session opens the authenticated shell directly.
- Monthly and category budgets are fixed prototype policies rather than user-configurable records.
- Edit reuses the transaction form and repository update path, but the broader editing product policy still needs review.
- iOS compilation requires a macOS/Xcode environment and was not verified from this Windows workspace.
- The project has not yet completed production security, privacy, localization, or device-matrix review.

## Immediate next task

Review the first high-fidelity vertical slice for UX, accessibility, visual hierarchy, motion quality, code architecture, and performance before building additional screens or connecting a backend.
