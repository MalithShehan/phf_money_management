import 'package:drift/drift.dart';
import 'tables.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // 1. Seed Categories
          await batch((batch) {
            batch.insertAll(categories, [
              CategoriesCompanion.insert(id: const Value(1), name: 'Salary', type: 'Income', icon: const Value('salary'), color: const Value('#2E7D32')),
              CategoriesCompanion.insert(id: const Value(2), name: 'Freelance', type: 'Income', icon: const Value('salary'), color: const Value('#1565C0')),
              CategoriesCompanion.insert(id: const Value(3), name: 'Food & Dining', type: 'Expense', icon: const Value('restaurant'), color: const Value('#EF6C00')),
              CategoriesCompanion.insert(id: const Value(4), name: 'Transportation', type: 'Expense', icon: const Value('car'), color: const Value('#1565C0')),
              CategoriesCompanion.insert(id: const Value(5), name: 'Rent & Bills', type: 'Expense', icon: const Value('home'), color: const Value('#C62828')),
              CategoriesCompanion.insert(id: const Value(6), name: 'Shopping', type: 'Expense', icon: const Value('shopping'), color: const Value('#6A1B9A')),
            ]);
          });

          // 2. Seed Accounts
          await batch((batch) {
            batch.insertAll(accounts, [
              AccountsCompanion.insert(id: const Value(1), name: 'Commercial Bank', balance: const Value(145000.0), type: 'Bank'),
              AccountsCompanion.insert(id: const Value(2), name: 'Cash Account', balance: const Value(25000.0), type: 'Cash'),
              AccountsCompanion.insert(id: const Value(3), name: 'Amex Credit Card', balance: const Value(-12000.0), type: 'Card'),
            ]);
          });

          // 3. Seed Transactions
          final now = DateTime.now();
          await batch((batch) {
            batch.insertAll(transactions, [
              TransactionsCompanion.insert(
                id: const Value(1),
                accountId: 1,
                categoryId: 1,
                amount: 125000.0,
                type: 'Income',
                date: now.subtract(const Duration(days: 5)),
                description: const Value('Monthly Salary Credit'),
              ),
              TransactionsCompanion.insert(
                id: const Value(2),
                accountId: 1,
                categoryId: 5,
                amount: 35000.0,
                type: 'Expense',
                date: now.subtract(const Duration(days: 4)),
                description: const Value('Apartment Monthly Rent'),
              ),
              TransactionsCompanion.insert(
                id: const Value(3),
                accountId: 2,
                categoryId: 3,
                amount: 2500.0,
                type: 'Expense',
                date: now.subtract(const Duration(days: 3)),
                description: const Value('Dinner at restaurant'),
              ),
              TransactionsCompanion.insert(
                id: const Value(4),
                accountId: 2,
                categoryId: 4,
                amount: 450.0,
                type: 'Expense',
                date: now.subtract(const Duration(days: 2)),
                description: const Value('Tuk tuk transport'),
              ),
              TransactionsCompanion.insert(
                id: const Value(5),
                accountId: 3,
                categoryId: 6,
                amount: 8500.0,
                type: 'Expense',
                date: now.subtract(const Duration(days: 1)),
                description: const Value('Buying clothes'),
              ),
              TransactionsCompanion.insert(
                id: const Value(6),
                accountId: 2,
                categoryId: 1,
                amount: 25000.0,
                type: 'Income',
                date: now,
                description: const Value('Salary'),
              ),
            ]);
          });
        },
      );

  Future<void> resetDatabase() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(budgets).go();
      await delete(accounts).go();
      await delete(categories).go();
    });
  }
}
