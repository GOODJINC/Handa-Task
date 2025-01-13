import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateFormatProvider with ChangeNotifier {
  static const String _key = 'date_format';
  static const String defaultFormat = 'MM월 DD일';

  String _dateFormat = defaultFormat;

  String get dateFormat => _dateFormat;

  DateFormatProvider() {
    _loadFormat();
  }

  Future<void> _loadFormat() async {
    final prefs = await SharedPreferences.getInstance();
    _dateFormat = prefs.getString(_key) ?? defaultFormat;
    notifyListeners();
  }

  Future<void> setDateFormat(String format) async {
    if (_dateFormat != format) {
      _dateFormat = format;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, format);
      notifyListeners();
    }
  }

  String formatDate(DateTime date) {
    switch (_dateFormat) {
      case 'MM-DD':
        return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'MM/DD':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      case 'MM월 DD일':
        return '${date.month}월 ${date.day}일';
      default:
        return '${date.month}월 ${date.day}일';
    }
  }
}
