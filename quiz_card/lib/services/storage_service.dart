import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/deck.dart';
import '../models/today_stats.dart';

class StorageService {
  static const _decksKey = 'decks';
  static const _recentDeckKey = 'recentDeck';
  static const _statsKey = 'todayStats';
  static const _fontSizeKey = 'fontSize';
  static const _studyDirectionKey = 'studyDirection';
  static const _themeKey = 'selectedTheme';

  static Future<void> saveDecks(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_decksKey,
        jsonEncode(decks.map((d) => d.toJson()).toList()));
  }

  static Future<List<Deck>> loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_decksKey);
    if (json == null) return [];
    return (jsonDecode(json) as List).map((d) => Deck.fromJson(d)).toList();
  }

  static Future<void> saveRecentDeck(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentDeckKey, deckName);
  }

  static Future<String?> loadRecentDeck() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recentDeckKey);
  }

  static Future<void> saveStats(int correct, int wrong) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_statsKey}_correct', correct);
    await prefs.setInt('${_statsKey}_wrong', wrong);
  }

  static Future<TodayStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return TodayStats(
      correct: prefs.getInt('${_statsKey}_correct') ?? 0,
      wrong: prefs.getInt('${_statsKey}_wrong') ?? 0,
    );
  }

  static Future<void> saveSettings({
    required double fontSize,
    required String studyDirection,
    required int selectedTheme,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
    await prefs.setString(_studyDirectionKey, studyDirection);
    await prefs.setInt(_themeKey, selectedTheme);
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fontSize': prefs.getDouble(_fontSizeKey) ?? 16.0,
      'studyDirection': prefs.getString(_studyDirectionKey) ?? '앞→뒤',
      'selectedTheme': prefs.getInt(_themeKey) ?? 0,
    };
  }
// 학습 진행상태 저장
  static Future<void> saveProgress({
    required String deckName,
    required int currentIndex,
    required int correctCount,
    required int wrongCount,
    required List<String> shuffledFronts,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progress_deck', deckName);
    await prefs.setInt('progress_index', currentIndex);
    await prefs.setInt('progress_correct', correctCount);
    await prefs.setInt('progress_wrong', wrongCount);
    await prefs.setStringList('progress_order', shuffledFronts);
  }

  // 학습 진행상태 불러오기
  static Future<Map<String, dynamic>?> loadProgress(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeck = prefs.getString('progress_deck');
    if (savedDeck != deckName) return null;
    return {
      'currentIndex': prefs.getInt('progress_index') ?? 0,
      'correctCount': prefs.getInt('progress_correct') ?? 0,
      'wrongCount': prefs.getInt('progress_wrong') ?? 0,
      'shuffledFronts': prefs.getStringList('progress_order') ?? [],
    };
  }

  // 학습 진행상태 삭제
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('progress_deck');
    await prefs.remove('progress_index');
    await prefs.remove('progress_correct');
    await prefs.remove('progress_wrong');
    await prefs.remove('progress_order');
  }
}