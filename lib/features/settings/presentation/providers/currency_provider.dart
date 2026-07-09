import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyNotifier extends Notifier<String> {
  static const _key = 'currency_symbol';
  late final SharedPreferences _prefs;

  @override
  String build() {
    _init();
    return 'Rs.';
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_key);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setCurrency(String symbol) async {
    state = symbol;
    await _prefs.setString(_key, symbol);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(() {
  return CurrencyNotifier();
});
