import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      backgroundColor: settings.bgColor,
      appBar: AppBar(
        backgroundColor: settings.accentColor,
        foregroundColor: Colors.white,
        title: const Text('⚙️ 설정',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () =>
                  Navigator.popUntil(context, (r) => r.isFirst),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        leadingWidth: 96,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 테마 색상
          const Text('테마 색상',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(AppSettings.themes.length, (index) {
              final theme = AppSettings.themes[index];
              final isSelected = settings.selectedTheme == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => settings.updateTheme(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? settings.mainColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                backgroundColor: theme['main'] as Color,
                                radius: 10),
                            const SizedBox(width: 4),
                            CircleAvatar(
                                backgroundColor: theme['accent'] as Color,
                                radius: 10),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          theme['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? settings.mainColor
                                : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: settings.mainColor, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // 폰트 크기
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: settings.pointColor, width: 1.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('폰트 크기',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${settings.fontSize.toInt()}px',
                        style: TextStyle(
                            color: settings.mainColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 6,
                  activeColor: settings.mainColor,
                  onChanged: (val) => settings.updateFontSize(val),
                ),
                Center(
                  child: Text(
                    '미리보기: 안녕하세요',
                    style: TextStyle(fontSize: settings.fontSize),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 학습 방향
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: settings.pointColor, width: 1.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('학습 방향',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...['앞→뒤', '뒤→앞', '랜덤'].map((direction) {
                  return RadioListTile<String>(
                    title: Text(direction),
                    value: direction,
                    groupValue: settings.studyDirection,
                    activeColor: settings.mainColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        settings.updateStudyDirection(val!),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정이 저장됐어요! ✅')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('설정 저장'),
            style: ElevatedButton.styleFrom(
              backgroundColor: settings.mainColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}