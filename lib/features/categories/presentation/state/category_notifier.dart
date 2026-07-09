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

    return const CategoryState();
  }

  void _startWatching() {
    state = state.copyWith(isLoading: true);
    _subscription?.cancel();
    _subscription = _watchCategories().listen(
      (categories) {
        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> addCategory(Category category) async {
    try {
      await _createCategory(category);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
