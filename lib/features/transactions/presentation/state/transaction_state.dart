import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

class TransactionState extends Equatable {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [transactions, isLoading, errorMessage];
}
