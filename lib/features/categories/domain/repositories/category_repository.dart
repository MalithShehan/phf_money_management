import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category?> getCategoryById(int id);
  Future<void> insertCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Stream<List<Category>> watchCategories();
}
