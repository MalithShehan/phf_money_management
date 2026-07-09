import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/data/local/app_database.dart' as db;
import 'package:phf_money_management/data/local/database_provider.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final db.AppDatabase _database;

  AccountRepositoryImpl(this._database);

  Account _toEntity(db.Account data) {
    return Account(
      id: data.id,
      name: data.name,
      balance: data.balance,
      type: data.type,
    );
  }

  db.AccountsCompanion _toCompanion(Account entity) {
    return db.AccountsCompanion(
      id: entity.id > 0 ? Value(entity.id) : const Value.absent(),
      name: Value(entity.name),
      balance: Value(entity.balance),
      type: Value(entity.type),
    );
  }

  @override
  Future<List<Account>> getAccounts() async {
    final list = await _database.select(_database.accounts).get();
    return list.map(_toEntity).toList();
  }

  @override
  Future<Account?> getAccountById(int id) async {
    final query = _database.select(_database.accounts)..where((t) => t.id.equals(id));
    final data = await query.getSingleOrNull();
    return data != null ? _toEntity(data) : null;
  }

  @override
  Future<void> insertAccount(Account account) async {
    await _database.into(_database.accounts).insert(_toCompanion(account));
  }

  @override
  Future<void> updateAccount(Account account) async {
    await _database.update(_database.accounts).replace(_toCompanion(account));
  }

  @override
  Future<void> deleteAccount(int id) async {
    final query = _database.delete(_database.accounts)..where((t) => t.id.equals(id));
    await query.go();
  }

  @override
  Stream<List<Account>> watchAccounts() {
    return _database
        .select(_database.accounts)
        .watch()
        .map((list) => list.map(_toEntity).toList());
  }
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return AccountRepositoryImpl(database);
});

