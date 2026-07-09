import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class WatchAccounts {
  final AccountRepository _repository;

  WatchAccounts(this._repository);

  Stream<List<Account>> call() {
    return _repository.watchAccounts();
  }
}

final watchAccountsProvider = Provider<WatchAccounts>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return WatchAccounts(repository);
});
