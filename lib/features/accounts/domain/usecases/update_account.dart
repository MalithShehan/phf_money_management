import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class UpdateAccount {
  final AccountRepository _repository;

  UpdateAccount(this._repository);

  Future<void> call(Account account) async {
    await _repository.updateAccount(account);
  }
}

final updateAccountProvider = Provider<UpdateAccount>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return UpdateAccount(repository);
});
