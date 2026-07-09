import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class SeedDefaultCategories {
  final CategoryRepository _repository;

  SeedDefaultCategories(this._repository);

  Future<void> call() async {
    final list = await _repository.getCategories();
    if (list.isEmpty) {
      final defaults = [
        const Category(id: 0, name: 'Salary', type: 'Income', icon: 'salary', color: '#2E7D32'),
        const Category(id: 0, name: 'Food', type: 'Expense', icon: 'restaurant', color: '#EF6C00'),
        const Category(id: 0, name: 'Transport', type: 'Expense', icon: 'car', color: '#1976D2'),
        const Category(id: 0, name: 'Shopping', type: 'Expense', icon: 'shopping', color: '#6A1B9A'),
        const Category(id: 0, name: 'Entertainment', type: 'Expense', icon: 'entertainment', color: '#C62828'),
        const Category(id: 0, name: 'Home/Rent', type: 'Expense', icon: 'home', color: '#00796B'),
      ];

      for (final cat in defaults) {
        await _repository.insertCategory(cat);
      }
    }
  }
}

final seedDefaultCategoriesProvider = Provider<SeedDefaultCategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return SeedDefaultCategories(repository);
});
