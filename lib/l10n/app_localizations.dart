import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'darkMode': 'Dark Mode',
      'dateFormat': 'Date Format',
      'weekStart': 'Week Start',
      'language': 'Language',
      'monday': 'Monday',
      'sunday': 'Sunday',
      'backup': 'Backup/Restore',
      'help': 'Help',
      'selectDateFormat': 'Select Date Format',
      'selectWeekStart': 'Select Week Start',
      'selectLanguage': 'Select Language',
      'year': 'Year',
      'addTodo': 'Add Todo',
      'deviceBackup': 'Device Backup/Restore',
      'dataReset': 'Reset Data',
      'cloudBackup': 'Cloud Backup',
      'appSettings': 'App Settings',
      'backupRestore': 'Backup/Restore',
      'support': 'Support',
      'appVersion': 'App Version',
      'loginForSync': 'Login to use sync service',
      'sync': 'Sync',
      'lastSync': 'Last sync: ',
    },
    'ko': {
      'settings': '설정',
      'darkMode': '다크 모드',
      'dateFormat': '날짜 형식',
      'weekStart': '주 시작일',
      'language': '언어',
      'monday': '월요일',
      'sunday': '일요일',
      'backup': '백업/복원',
      'help': '도움말',
      'selectDateFormat': '날짜 형식 선택',
      'selectWeekStart': '주 시작일 선택',
      'selectLanguage': '언어 선택',
      'year': '년',
      'addTodo': '할 일 추가하기',
      'deviceBackup': '장치에 백업/복원',
      'dataReset': '데이터 초기화',
      'cloudBackup': '클라우드에 백업',
      'appSettings': '앱 설정',
      'backupRestore': '백업/복원',
      'support': '지원',
      'appVersion': '앱 버전',
      'loginForSync': '로그인 시 동기화 서비스 이용이 가능합니다.',
      'sync': '동기화',
      'lastSync': '마지막 동기화: ',
    },
  };

  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get darkMode =>
      _localizedValues[locale.languageCode]?['darkMode'] ?? 'Dark Mode';
  // ... 다른 getter 메서드들 추가

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
