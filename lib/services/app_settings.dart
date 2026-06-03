import 'package:flutter/material.dart';
import 'storage_service.dart';
import '../theme/colors.dart';

class AppSettings extends ChangeNotifier {
  double _fontSize = 16.0;
  String _studyDirection = '앞→뒤';
  int _selectedTheme = 0;

  double get fontSize => _fontSize;
  String get studyDirection => _studyDirection;
  int get selectedTheme => _selectedTheme;

  // 테마 색상 목록
  static const List<Map<String, dynamic>> themes = [
    {
      'name': '제주 밭',
      'main': Color(0xFF386641),
      'accent': Color(0xFFE8833A),
      'bg': Color(0xFFF2F7EC),
      'point': Color(0xFFDCEDC8),
    },
    {
      'name': '제주 바다',
      'main': Color(0xFF1A5F7A),
      'accent': Color(0xFFE8833A),
      'bg': Color(0xFFEFF6FA),
      'point': Color(0xFFB8E4F2),
    },
    {
      'name': '한라 노을',
      'main': Color(0xFF8B3A3A),
      'accent': Color(0xFFD4A017),
      'bg': Color(0xFFFAF0EC),
      'point': Color(0xFFF5CBA7),
    },
  ];

  Color get mainColor => themes[_selectedTheme]['main'] as Color;
  Color get accentColor => themes[_selectedTheme]['accent'] as Color;
  Color get bgColor => themes[_selectedTheme]['bg'] as Color;
  Color get pointColor => themes[_selectedTheme]['point'] as Color;

  Future<void> loadSettings() async {
    final settings = await StorageService.loadSettings();
    _fontSize = settings['fontSize'];
    _studyDirection = settings['studyDirection'];
    _selectedTheme = settings['selectedTheme'];
    JejuColors.updateTheme(_selectedTheme);
    notifyListeners();
  }

  Future<void> updateFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    await StorageService.saveSettings(
      fontSize: _fontSize,
      studyDirection: _studyDirection,
      selectedTheme: _selectedTheme,
    );
  }

  Future<void> updateStudyDirection(String direction) async {
    _studyDirection = direction;
    notifyListeners();
    await StorageService.saveSettings(
      fontSize: _fontSize,
      studyDirection: _studyDirection,
      selectedTheme: _selectedTheme,
    );
  }

  Future<void> updateTheme(int index) async {
    _selectedTheme = index;
    JejuColors.updateTheme(index);
    notifyListeners();
    await StorageService.saveSettings(
      fontSize: _fontSize,
      studyDirection: _studyDirection,
      selectedTheme: _selectedTheme,
    );
  }
}