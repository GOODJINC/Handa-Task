import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _key = 'locale';
  static const String defaultLocale = 'ko';

  static const Map<String, String> supportedLocales = {
    'ko': '한국어',
    'en': 'English',
    // 나중에 다른 언어 추가 가능
    // 'ja': '日本語',
    // 'zh': '中文',
  };

  String _currentLocale = defaultLocale;

  String get currentLocale => _currentLocale;
  String get currentLanguageName => supportedLocales[_currentLocale] ?? '한국어';
  Locale get locale => Locale(_currentLocale);

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString(_key) ?? defaultLocale;
    notifyListeners();
  }

  Future<void> setLocale(String localeCode) async {
    if (_currentLocale != localeCode &&
        supportedLocales.containsKey(localeCode)) {
      _currentLocale = localeCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, localeCode);
      notifyListeners();
    }
  }
}
