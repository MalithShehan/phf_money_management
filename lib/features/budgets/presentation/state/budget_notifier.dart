import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/watch_budgets.dart';
import 'budget_state.dart';

class BudgetNotifier extends Notifier<BudgetState> {
  late final CreateBudget _createBudget;
  late final WatchBudgets _watchBudgets;
  StreamSubscription<List<Budget>>? _subscription;

  @override
  BudgetState build() {
    _createBudget = ref.watch(createBudgetProvider);
    _watchBudgets = ref.watch(watchBudgetsProvider);

    _startWatching();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const BudgetState(isLoading: true);
  }

  void _startWatching() {
    _subscription?.cancel();
    _subscription = _watchBudgets().listen(
      (budgets) {
        state = state.copyWith(
          budgets: budgets,
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

  Future<void> addBudget(Budget budget) async {
    try {
      await _createBudget(budget);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
