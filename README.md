# PHF Money Management App

## Overview
Offline-first Flutter money management app built using Clean Architecture.

---

## Features Completed
- **Accounts**: CRUD operations for Cash, Bank, Card, and Wallet.
- **Categories**: Seeded defaults and custom category CRUD support.
- **Transactions**: Add, edit, delete, and filter ledger records.
- **Dashboard**: Monthly cash flow metrics, aggregate balance, recent transactions, and budget alerts.
- **Reports/Budgets**: Category expense breakdowns, budget limit alerts, and linear progress indicators.

---

## Tech Stack
- **Framework**: Flutter (Material 3 styling)
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Database**: `drift` & `sqlite3_flutter_libs`
- **Data Formats**: Manual CSV/JSON portability tools
- **Utility**: `intl`, `uuid`, `shared_preferences`, `fl_chart`, `equatable`, `mocktail`

---

## Architecture Layout
The project conforms to **Clean Architecture** directory layouts:
```
lib/
 ├── main.dart
 ├── app.dart
 ├── core/
 │    ├── constants/
 │    ├── errors/
 │    ├── routing/
 │    ├── theme/
 │    ├── utils/
 │    └── widgets/
 ├── data/
 │    └── local/
 │         ├── app_database.dart
 │         ├── tables.dart
 │         └── database_provider.dart
 └── features/
      ├── accounts/
      ├── categories/
      ├── transactions/
      ├── budgets/
      ├── dashboard/
      ├── reports/
      └── settings/
```

---

## How to Run
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## How to Build APK
```bash
flutter build apk --release
```

---

## Known Issues
- **Form Field Warnings**: Minor deprecation warnings (e.g. using `value` inside choice chips/dropdowns instead of form initialValue under newer Flutter versions). These warnings do not affect build execution or app compilation.
