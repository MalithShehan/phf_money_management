import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/update_account.dart';
import '../../domain/usecases/watch_accounts.dart';
import 'account_state.dart';

class AccountNotifier extends Notifier<AccountState> {
  late final CreateAccount _createAccount;
  late final UpdateAccount _updateAccount;
  late final WatchAccounts _watchAccounts;
  StreamSubscription<List<Account>>? _subscription;

  @override
  AccountState build() {
    _createAccount = ref.watch(createAccountProvider);
    _updateAccount = ref.watch(updateAccountProvider);
    _watchAccounts = ref.watch(watchAccountsProvider);

    _startWatching();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const AccountState(isLoading: true);
  }

  void _startWatching() {
    _subscription?.cancel();
    _subscription = _watchAccounts().listen(
      (accounts) {
        state = state.copyWith(
          accounts: accounts,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> addAccount(Account account) async {
    try {
      await _createAccount(account);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _updateAccount(account);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
