import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/account_notifier.dart';
import '../state/account_state.dart';

final accountProvider = NotifierProvider<AccountNotifier, AccountState>(() {
  return AccountNotifier();
});
