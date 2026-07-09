import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../repositories/account_repository.dart';

class DeleteAccount {
  final AccountRepository _repository;

  DeleteAccount(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteAccount(id);
  }
}

final deleteAccountProvider = Provider<DeleteAccount>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return DeleteAccount(repository);
});
