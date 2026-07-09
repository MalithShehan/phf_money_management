import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final int accountId;
  final int categoryId;
  final double amount;
  final String type; // Income, Expense, Transfer
  final DateTime date;
  final String? description;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
  });

  @override
  List<Object?> get props => [id, accountId, categoryId, amount, type, date, description];
}
