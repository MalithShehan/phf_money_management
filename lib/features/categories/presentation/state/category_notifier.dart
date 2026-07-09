import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/watch_categories.dart';
import '../../domain/usecases/seed_default_categories.dart';
import 'category_state.dart';

class CategoryNotifier extends Notifier<CategoryState> {
  late final CreateCategory _createCategory;
  late final DeleteCategory _deleteCategory;
  late final UpdateCategory _updateCategory;
  late final WatchCategories _watchCategories;
  late final SeedDefaultCategories _seedDefaultCategoriesUsecase;
  StreamSubscription<List<Category>>? _subscription;

  @override
  CategoryState build() {
    _createCategory = ref.watch(createCategoryProvider);
    _deleteCategory = ref.watch(deleteCategoryProvider);
    _updateCategory = ref.watch(updateCategoryProvider);
    _watchCategories = ref.watch(watchCategoriesProvider);
    _seedDefaultCategoriesUsecase = ref.watch(seedDefaultCategoriesProvider);

    _startWatching();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const CategoryState(isLoading: true);
  }

  bool _isSeeding = false;

  void _startWatching() {
    _subscription?.cancel();
    _subscription = _watchCategories().listen(
      (categories) {
        if (categories.isEmpty && !_isSeeding) {
          _isSeeding = true;
          _seedDefaultCategories();
        } else {
          state = state.copyWith(
            categories: categories,
            isLoading: false,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    try {
      await _seedDefaultCategoriesUsecase();
    } catch (e) {
      print('ERROR SEEDING CATEGORIES: $e');
    } finally {
      _isSeeding = false;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _createCategory(category);
    } catch (e) {
      print('ERROR ADDING CATEGORY: $e');
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> editCategory(Category category) async {
    try {
      await _updateCategory(category);
    } catch (e) {
      print('ERROR EDITING CATEGORY: $e');
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _deleteCategory(id);
    } catch (e) {
      print('ERROR DELETING CATEGORY: $e');
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
