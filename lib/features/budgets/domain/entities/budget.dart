import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int id;
  final int categoryId;
  final double amountLimit;
  final DateTime startDate;
  final DateTime endDate;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [id, categoryId, amountLimit, startDate, endDate];
}
