import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/transaction.dart';

class FilterTransactions {
  List<Transaction> call({
    required List<Transaction> transactions,
    required String query,
    required String typeFilter,
  }) {
    return transactions.where((tx) {
      final matchesType = typeFilter == 'All' || tx.type.toLowerCase() == typeFilter.toLowerCase();
      final matchesQuery = query.isEmpty ||
          (tx.description ?? '').toLowerCase().contains(query.toLowerCase()) ||
          tx.type.toLowerCase().contains(query.toLowerCase()) ||
          tx.amount.toString().contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }
}

final filterTransactionsProvider = Provider<FilterTransactions>((ref) {
  return FilterTransactions();
});
