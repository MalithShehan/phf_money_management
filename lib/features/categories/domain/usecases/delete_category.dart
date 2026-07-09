import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository _repository;

  DeleteCategory(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteCategory(id);
  }
}

final deleteCategoryProvider = Provider<DeleteCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategory(repository);
});
