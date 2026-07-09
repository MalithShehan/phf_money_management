import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

class CategoryState extends Equatable {
  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [categories, isLoading, errorMessage];
}
