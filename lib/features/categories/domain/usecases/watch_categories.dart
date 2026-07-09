import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class WatchCategories {
  final CategoryRepository _repository;

  WatchCategories(this._repository);

  Stream<List<Category>> call() {
    return _repository.watchCategories();
  }
}

final watchCategoriesProvider = Provider<WatchCategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return WatchCategories(repository);
});
