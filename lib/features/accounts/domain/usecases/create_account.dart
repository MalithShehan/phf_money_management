import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class CreateAccount {
  final AccountRepository _repository;

  CreateAccount(this._repository);

  Future<void> call(Account account) async {
    await _repository.insertAccount(account);
  }
}

final createAccountProvider = Provider<CreateAccount>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return CreateAccount(repository);
});
