import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/data/local/app_database.dart' as db;
import 'package:phf_money_management/data/local/database_provider.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final db.AppDatabase _database;

  CategoryRepositoryImpl(this._database);

  Category _toEntity(db.Category data) {
    return Category(
      id: data.id,
      name: data.name,
      type: data.type,
      icon: data.icon,
      color: data.color,
    );
  }

  db.CategoriesCompanion _toCompanion(Category entity) {
    return db.CategoriesCompanion(
      id: entity.id > 0 ? Value(entity.id) : const Value.absent(),
      name: Value(entity.name),
      type: Value(entity.type),
      icon: entity.icon != null ? Value(entity.icon) : const Value.absent(),
      color: entity.color != null ? Value(entity.color) : const Value.absent(),
    );
  }

  @override
  Future<List<Category>> getCategories() async {
    final list = await _database.select(_database.categories).get();
    return list.map(_toEntity).toList();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final query = _database.select(_database.categories)..where((t) => t.id.equals(id));
    final data = await query.getSingleOrNull();
    return data != null ? _toEntity(data) : null;
  }

  @override
  Future<void> insertCategory(Category category) async {
    await _database.into(_database.categories).insert(_toCompanion(category));
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _database.update(_database.categories).replace(_toCompanion(category));
  }

  @override
  Future<void> deleteCategory(int id) async {
    final query = _database.delete(_database.categories)..where((t) => t.id.equals(id));
    await query.go();
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _database
        .select(_database.categories)
        .watch()
        .map((list) => list.map(_toEntity).toList());
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(database);
});

