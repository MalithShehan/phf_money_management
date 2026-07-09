import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

class BudgetState extends Equatable {
  final List<Budget> budgets;
  final bool isLoading;
  final String? errorMessage;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BudgetState copyWith({
    List<Budget>? budgets,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [budgets, isLoading, errorMessage];
}
