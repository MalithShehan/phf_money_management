import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/watch_categories.dart';
import 'category_state.dart';

class CategoryNotifier extends Notifier<CategoryState> {
  late final CreateCategory _createCategory;
  late final WatchCategories _watchCategories;
  StreamSubscription<List<Category>>? _subscription;

  @override
  CategoryState build() {
    _createCategory = ref.watch(createCategoryProvider);
    _watchCategories = ref.watch(watchCategoriesProvider);

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
      final defaults = [
        Category(id: 0, name: 'Salary', type: 'Income', icon: 'salary', color: '#2E7D32'),
        Category(id: 0, name: 'Food', type: 'Expense', icon: 'restaurant', color: '#EF6C00'),
        Category(id: 0, name: 'Transport', type: 'Expense', icon: 'car', color: '#1976D2'),
        Category(id: 0, name: 'Shopping', type: 'Expense', icon: 'shopping', color: '#6A1B9A'),
        Category(id: 0, name: 'Entertainment', type: 'Expense', icon: 'entertainment', color: '#C62828'),
        Category(id: 0, name: 'Home/Rent', type: 'Expense', icon: 'home', color: '#00796B'),
      ];

      for (final cat in defaults) {
        await _createCategory(cat);
      }
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
}
