import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  final CategoryRepository _repository;

  UpdateCategory(this._repository);

  Future<void> call(Category category) async {
    await _repository.updateCategory(category);
  }
}

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategory(repository);
});
