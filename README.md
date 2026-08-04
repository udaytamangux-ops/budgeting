# Budgeting

Budgeting is a mobile-first NPR transaction tracker for young salaried professionals in Nepal. This repository establishes the Flutter foundation and a connected product journey: reviewing recorded income and expenses, adding a transaction, seeing the recorded balance update immediately, and opening the saved record.

The application is ready for product and engineering review, but it is not production-complete. Authentication, persistent storage, synchronization, and backend services are intentionally deferred.

## Current scope

- Tracking-first Home with recorded balance, monthly income and expenses, compact add actions, a neutral monthly summary, and recent transactions
- Full-screen expense and income form with recent categories, session-only payment-method memory, Today/Yesterday shortcuts, progressive optional fields, validation, asynchronous save states, and failure recovery
- Searchable, filterable transaction history grouped by meaningful calendar dates
- Neutral monthly Summary with month navigation, income, expenses, net change, transaction count, and an accessible category-spending donut with a ranked text breakdown
- Mock profile and preference structure with debug-only development information
- In-memory create, read, update, and delete transaction repository
- Lightweight saved-transaction confirmation with a time-limited, recoverable Undo action
- Transaction details with reusable Edit and Repeat flows plus explicit delete confirmation
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
    ├── budgets/         # Isolated prototype budget logic outside the current UI
    ├── home/            # Recorded position, quick actions, and recent activity
    ├── profile/         # Mock profile, preferences, privacy, and debug state
    ├── summary/         # Neutral monthly aggregation and presentation
    └── transactions/    # Domain, in-memory data, controllers, and screens
```

### State management

`flutter_riverpod` provides repository dependency injection, the transaction stream, transaction lookup, recent-category derivation, session payment-method memory, calculated financial and neutral monthly summaries, asynchronous form submission, race-safe Undo confirmation, and deletion state. Ephemeral field focus, text editing, expansion, and form selection remain local to the owning widgets.

### Navigation

`go_router` defines public authentication-ready routes, a state-preserving authenticated shell, transaction details, and a root-navigator full-screen transaction form reused for create, edit, and repeat intents. The center Add control is an action rather than a fifth navigation destination.

### Financial values

Money is stored as integer minor units in the `Money` value object. No financial amount uses `double`; for example, NPR 1,250.50 is stored as `125050`. Formatting is delegated to the centralized `CurrencyFormatter`.

### Data access

Presentation code depends on the `TransactionRepository` interface. `InMemoryTransactionRepository` supplies realistic Nepal-focused seed data, broadcasts changes, supports CRUD operations, simulates save latency, and exposes controlled failures for tests. It can be replaced with local and cloud implementations without changing screens.

The default mock source includes current- and previous-month records so month-scoped Summary behavior can be reviewed without persistence. Payment-method data remains available to transaction filters and details but is not shown in the default Summary view.

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
- Notifications, goals, an analytics SDK, and AI-assisted insights. Stable privacy-safe event names exist internally, but no analytics data is transmitted.
- Production application icons, signing, store metadata, privacy policy, and release automation

## Known limitations

- Data resets whenever the process restarts because the repository is in memory.
- Remembered payment methods last only for the current application session.
- Undo is available for eight seconds after a create; it is not a permanent transaction-recovery system.
- The temporary development session opens the authenticated shell directly.
- The current product does not set limits, score spending, or provide financial guidance; the retained prototype budget code is isolated from user-facing routes.
- Edit reuses the transaction form and repository update path, but the broader editing product policy still needs review.
- iOS compilation requires a macOS/Xcode environment and was not verified from this Windows workspace.
- The project has not yet completed production security, privacy, localization, or device-matrix review.

## Immediate next task

Review the tracking-first vertical slice for UX, accessibility, visual hierarchy, motion quality, code architecture, and performance before adding persistence or expanding product scope.
