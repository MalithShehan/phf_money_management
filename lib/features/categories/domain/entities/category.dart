import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String type; // Income or Expense
  final String? icon;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  @override
  List<Object?> get props => [id, name, type, icon, color];
}
