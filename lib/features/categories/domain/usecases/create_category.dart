import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository _repository;

  CreateCategory(this._repository);

  Future<void> call(Category category) async {
    await _repository.insertCategory(category);
  }
}

final createCategoryProvider = Provider<CreateCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CreateCategory(repository);
});
