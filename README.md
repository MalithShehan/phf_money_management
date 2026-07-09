# PHF Money Management

PHF Money Management is a premium, clean-architecture personal finance tracking mobile application built with Flutter. It helps users monitor account balances, classify expenses, set custom budgets, view monthly financial reports, and maintain database diagnostics.

---

## Project Overview

This application is designed to be a reliable and robust budget tracker. Key features include:
- **Multi-Account Balance Tracking**: Support for different account types (Cash, Bank, Credit Card) with real-time balance calculations.
- **Categorization**: Custom income/expense category creation with color markers and distinct badges.
- **Transaction Ledger**: Dynamic transaction records including validation checks and automatic balance adjustments.
- **Budget Limits & Warnings**: Exceeded budget alerts displayed immediately on the dashboard when monthly category spendings exceed thresholds.
- **Interactive Reports**: Category-wise expense breakdown pie charts and monthly cash flow metrics.
- **Mock Data Generation**: Diagnostics utility in Settings allowing reviewers to populate dummy records with a single click.

---

## Architecture

The project conforms to **Clean Architecture** principles, maintaining strict separation of concerns between business logic, data models, state management, and user interfaces:

```
lib/
 ├── core/                    # Cross-cutting concerns
 │    ├── routing/            # Router configurations (GoRouter)
 │    ├── theme/              # Styles and Theme constants
 │    ├── widgets/            # Shared components (Side Navigation Drawer)
 │    └── utils/              # Formatter utilities
 └── features/                # Domain-centric feature folders
      ├── accounts/           # Accounts management module
      ├── categories/         # Classification categories module
      ├── transactions/       # Transaction register ledger
      ├── budgets/            # Budget thresholds module
      ├── dashboard/          # Home visual metrics & Splash screen
      ├── reports/            # Financial charts and analytics
      └── settings/           # Diagnostic configuration and local SQLite Drift setups
```

### Clean Architecture Layers:
1. **Domain Layer (Core Business Logic)**:
   - *Entities*: Pure Dart model representations (e.g. `Account`, `Category`, `Transaction`) extending `Equatable` to ensure value comparison.
   - *Repository Interfaces*: Abstract interfaces defining database operations.
   - *Use Cases*: Independent, single-responsibility units (e.g., `CreateTransaction`, `WatchAccounts`) matching business flows.
2. **Data Layer (Storage & Serialization)**:
   - *Drift SQLite Database*: Schema tables, file-backed connection setup, and Riverpod registration.
   - *Repository Implementations*: Implementations of repository interfaces retrieving and mapping raw Drift rows to pure business entities.
3. **Presentation Layer (State & UI)**:
   - *Riverpod State Notifiers*: Modern Riverpod 3.x `Notifier` and `NotifierProvider` classes managing UI states without calling SQLite databases directly.
   - *UI Screens & Widgets*: Clean Material 3 screens consuming providers to render responsive widgets.

---

## Packages

The app relies on the following core libraries configured in `pubspec.yaml`:
- **State Management**: `flutter_riverpod` (v3.x architecture)
- **Routing**: `go_router`
- **Database Engine**: `drift` & `sqlite3_flutter_libs`
- **Path Utilities**: `path_provider` & `path`
- **Data Comparison**: `equatable`
- **Charts & Graphs**: `fl_chart`
- **Helper Utilities**: `intl` (date/currency formatting), `uuid` (unique keys), `shared_preferences` (settings cache)

---

## Run Commands

Execute the following commands in the workspace root directory:

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run Code Generation (Drift database mappings)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run Application
```bash
flutter run
```

### 4. Execute Static Analysis (Linter & Type checks)
```bash
flutter analyze
```

### 5. Run Tests
```bash
flutter test
```

---

## APK Build

To package a release Android APK containing compiled production binaries:

```bash
flutter build apk --release
```
The compiled output is created at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Known Issues

- **Hot Restart Requirement on Drift Schema Changes**: During active development, updating table schemas inside `tables.dart` requires deleting the existing local app data/cache or performing a clean database rebuild before re-running code generators.
- **Form Field Warnings**: Certain input fields emit minor deprecation hints under recent Flutter versions regarding deprecated properties (e.g., using `value` instead of `initialValue` inside Form fields). These do not block build execution or compilation and can be safely ignored.
