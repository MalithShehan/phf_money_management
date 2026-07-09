import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAccounts();
  Future<Account?> getAccountById(int id);
  Future<void> insertAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(int id);
  Stream<List<Account>> watchAccounts();
}
