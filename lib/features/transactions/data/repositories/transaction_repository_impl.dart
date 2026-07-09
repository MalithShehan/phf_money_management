import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/data/local/app_database.dart' as db;
import 'package:phf_money_management/data/local/database_provider.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final db.AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  Transaction _toEntity(db.Transaction data) {
    return Transaction(
      id: data.id,
      accountId: data.accountId,
      categoryId: data.categoryId,
      amount: data.amount,
      type: data.type,
      date: data.date,
      description: data.description,
    );
  }

  db.TransactionsCompanion _toCompanion(Transaction entity) {
    return db.TransactionsCompanion(
      id: entity.id > 0 ? Value(entity.id) : const Value.absent(),
      accountId: Value(entity.accountId),
      categoryId: Value(entity.categoryId),
      amount: Value(entity.amount),
      type: Value(entity.type),
      date: Value(entity.date),
      description: entity.description != null ? Value(entity.description) : const Value.absent(),
    );
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final list = await _database.select(_database.transactions).get();
    return list.map(_toEntity).toList();
  }

  @override
  Future<Transaction?> getTransactionById(int id) async {
    final query = _database.select(_database.transactions)..where((t) => t.id.equals(id));
    final data = await query.getSingleOrNull();
    return data != null ? _toEntity(data) : null;
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    await _database.into(_database.transactions).insert(_toCompanion(transaction));
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _database.update(_database.transactions).replace(_toCompanion(transaction));
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final query = _database.delete(_database.transactions)..where((t) => t.id.equals(id));
    await query.go();
  }

  @override
  Stream<List<Transaction>> watchTransactions() {
    return _database
        .select(_database.transactions)
        .watch()
        .map((list) => list.map(_toEntity).toList());
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(database);
});

