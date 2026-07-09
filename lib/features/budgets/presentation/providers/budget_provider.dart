import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/budget_notifier.dart';
import '../state/budget_state.dart';

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(() {
  return BudgetNotifier();
});
