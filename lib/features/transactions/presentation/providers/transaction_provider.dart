import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/transaction_notifier.dart';
import '../state/transaction_state.dart';

final transactionProvider = NotifierProvider<TransactionNotifier, TransactionState>(() {
  return TransactionNotifier();
});
