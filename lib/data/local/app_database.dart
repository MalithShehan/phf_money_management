import 'package:drift/drift.dart';
import 'tables.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 1;

  Future<void> resetDatabase() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(budgets).go();
      await delete(accounts).go();
      await delete(categories).go();
    });
  }
}
