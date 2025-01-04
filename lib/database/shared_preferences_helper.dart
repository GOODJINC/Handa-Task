import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _recentSearchesKey = 'recentSearches';

  // 최근 검색어 가져오기
  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  // 최근 검색어 저장
  static Future<void> saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentSearches = await getRecentSearches();

    // 중복 제거 및 최신 검색어를 맨 앞에 추가
    recentSearches.remove(query);
    recentSearches.insert(0, query);

    // 최대 10개 제한
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }

    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  // 특정 검색어 삭제
  static Future<void> deleteRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentSearches = await getRecentSearches();

    recentSearches.remove(query);
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  // 모든 최근 검색어 삭제
  static Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }
}
