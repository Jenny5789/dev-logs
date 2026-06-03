import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import '../models/today_stats.dart';
import '../services/storage_service.dart';
import 'deck_list_screen.dart';
import 'card_list_screen.dart';
import 'study_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Deck> decks = [];
  TodayStats todayStats = TodayStats();
  Deck? recentDeck;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedDecks = await StorageService.loadDecks();
    final loadedStats = await StorageService.loadStats();
    final recentDeckName = await StorageService.loadRecentDeck();

    setState(() {
      decks = loadedDecks.isNotEmpty
          ? loadedDecks
          : [
              Deck(name: '자료구조', cards: [
                CardItem(front: '스택 구조?', back: 'LIFO 구조'),
                CardItem(front: '큐 구조?', back: 'FIFO 구조'),
                CardItem(front: '트리 구조?', back: '계층적 자료구조'),
              ]),
              Deck(name: '영어단어', cards: [
                CardItem(front: 'apple', back: '사과'),
                CardItem(front: 'banana', back: '바나나'),              
              ]),
            ];
      todayStats = loadedStats;
      recentDeck = recentDeckName != null
          ? decks.firstWhere((d) => d.name == recentDeckName,
              orElse: () => decks.first)
          : decks.isNotEmpty
              ? decks.first
              : null;
      isLoading = false;
    });

    if (loadedDecks.isEmpty) await StorageService.saveDecks(decks);
  }

  void _onStudyComplete(int correct, int wrong, Deck deck) async {
    setState(() {
      todayStats.correct += correct;
      todayStats.wrong += wrong;
      recentDeck = deck;
    });
    await StorageService.saveStats(todayStats.correct, todayStats.wrong);
    await StorageService.saveRecentDeck(deck.name);
  }

  void _onDecksChanged() async {
    await StorageService.saveDecks(decks);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = todayStats.correct + todayStats.wrong;
    final rate = total == 0 ? 0.0 : todayStats.correct / total;

    context.watch<AppSettings>();
    
    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: const Text('🍊 카드퀴즈 🍊',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: JejuColors.main,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/aaa.png', height: 32),
                      const SizedBox(width: 8),
                      const Text('오늘의 학습 통계',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBox(
                          label: '맞춤',
                          value: todayStats.correct,
                          color: Colors.white),
                      _StatBox(
                          label: '틀림',
                          value: todayStats.wrong,
                          color: Colors.orange[200]!),
                      _StatBox(
                          label: '전체',
                          value: total,
                          color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? '아직 학습 기록이 없어요'
                        : '정답률 ${(rate * 100).toInt()}%',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('최근 학습한 단어장',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            recentDeck == null
                ? Container(
                    decoration: BoxDecoration(
                      color: JejuColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: JejuColors.point, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: JejuColors.sub),
                        const SizedBox(width: 8),
                        const Text('단어장이 없어요. 먼저 단어장을 만들어보세요!'),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: JejuColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: JejuColors.point, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: JejuColors.point,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.book,
                              color: JejuColors.main, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recentDeck!.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('${recentDeck!.cards.length}장',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudyScreen(
                                deck: recentDeck!,
                                onComplete: _onStudyComplete,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('시작'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JejuColors.main,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 20),
            const Text('바로가기',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: [
                _ShortcutButton(
                  icon: Icons.library_books,
                  label: '단어장 목록',
                  subtitle: '${decks.length}개',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeckListScreen(
                          decks: decks,
                          onStudyComplete: _onStudyComplete,
                          onDecksChanged: _onDecksChanged,
                        ),
                      ),
                    );
                    _onDecksChanged();
                  },
                ),
                const SizedBox(width: 8),
                _ShortcutButton(
                  icon: Icons.style,
                  label: '카드 목록',
                  subtitle: decks.isEmpty ? '0장' : '${decks.length}개 단어장',
                  onTap: decks.isEmpty
                      ? null
                      : () async {
                          final selected = await showDialog<Deck>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('단어장 선택'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: decks.length,
                                  itemBuilder: (context, index) {
                                    final deck = decks[index];
                                    return ListTile(
                                      leading: Icon(Icons.book,
                                          color: JejuColors.main),
                                      title: Text(deck.name),
                                      subtitle:
                                          Text('${deck.cards.length}장'),
                                      onTap: () =>
                                          Navigator.pop(context, deck),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('취소',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                              ],
                            ),
                          );
                          if (selected != null && mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CardListScreen(
                                  deck: selected,
                                  onStudyComplete: _onStudyComplete,
                                  onCardsChanged: _onDecksChanged,
                                ),
                              ),
                            );
                          }
                        },
                ),
                const SizedBox(width: 8),
                _ShortcutButton(
                  icon: Icons.play_circle,
                  label: '학습 시작',
                  subtitle: '바로 시작',
                  onTap: decks.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudyScreen(
                                deck: decks.first,
                                onComplete: _onStudyComplete,
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
      ],
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: onTap == null ? Colors.grey[200] : JejuColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onTap == null ? Colors.grey[300]! : JejuColors.point,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon,
                  size: 28,
                  color: onTap == null ? Colors.grey : JejuColors.main),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: onTap == null ? Colors.grey : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: onTap == null ? Colors.grey[400] : JejuColors.sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}