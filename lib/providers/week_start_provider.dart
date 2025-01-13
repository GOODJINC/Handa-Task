import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekStartProvider with ChangeNotifier {
  static const String _key = 'week_start_day';
  static const int defaultStartDay = DateTime.monday; // 기본값은 월요일

  int _startDay = defaultStartDay;

  int get startDay => _startDay;
  String get startDayString => _startDay == DateTime.monday ? '월요일' : '일요일';

  WeekStartProvider() {
    _loadStartDay();
  }

  Future<void> _loadStartDay() async {
    final prefs = await SharedPreferences.getInstance();
    _startDay = prefs.getInt(_key) ?? defaultStartDay;
    notifyListeners();
  }

  Future<void> setStartDay(int day) async {
    if (_startDay != day) {
      _startDay = day;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, day);
      notifyListeners();
    }
  }
}
