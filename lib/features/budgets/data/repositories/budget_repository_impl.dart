import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/features/settings/data/local/app_database.dart' as db;
import 'package:phf_money_management/features/settings/data/local/database_provider.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final db.AppDatabase _database;

  BudgetRepositoryImpl(this._database);

  Budget _toEntity(db.Budget data) {
    return Budget(
      id: data.id,
      categoryId: data.categoryId,
      amountLimit: data.amountLimit,
      startDate: data.startDate,
      endDate: data.endDate,
    );
  }

  db.BudgetsCompanion _toCompanion(Budget entity) {
    return db.BudgetsCompanion(
      id: entity.id > 0 ? Value(entity.id) : const Value.absent(),
      categoryId: Value(entity.categoryId),
      amountLimit: Value(entity.amountLimit),
      startDate: Value(entity.startDate),
      endDate: Value(entity.endDate),
    );
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final list = await _database.select(_database.budgets).get();
    return list.map(_toEntity).toList();
  }

  @override
  Future<Budget?> getBudgetById(int id) async {
    final query = _database.select(_database.budgets)..where((t) => t.id.equals(id));
    final data = await query.getSingleOrNull();
    return data != null ? _toEntity(data) : null;
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    await _database.into(_database.budgets).insert(_toCompanion(budget));
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _database.update(_database.budgets).replace(_toCompanion(budget));
  }

  @override
  Future<void> deleteBudget(int id) async {
    final query = _database.delete(_database.budgets)..where((t) => t.id.equals(id));
    await query.go();
  }

  @override
  Stream<List<Budget>> watchBudgets() {
    return _database
        .select(_database.budgets)
        .watch()
        .map((list) => list.map(_toEntity).toList());
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(database);
});

