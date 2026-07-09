import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int id;
  final String name;
  final double balance;
  final String type;

  const Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, balance, type];
}
