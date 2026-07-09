import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/category_notifier.dart';
import '../state/category_state.dart';

final categoryProvider = NotifierProvider<CategoryNotifier, CategoryState>(() {
  return CategoryNotifier();
});
