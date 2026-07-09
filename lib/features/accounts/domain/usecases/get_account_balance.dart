import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../repositories/account_repository.dart';

class GetAccountBalance {
  final AccountRepository _repository;

  GetAccountBalance(this._repository);

  Future<double> call(int id) async {
    final acc = await _repository.getAccountById(id);
    return acc?.balance ?? 0.0;
  }
}

final getAccountBalanceProvider = Provider<GetAccountBalance>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return GetAccountBalance(repository);
});
