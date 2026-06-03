import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import 'study_screen.dart';

class ResultScreen extends StatelessWidget {
  final Deck deck;
  final List<CardItem> shuffledCards;
  final int correctCount;
  final int wrongCount;
  final Function(int, int, Deck) onComplete;

  const ResultScreen({
    super.key,
    required this.deck,
    required this.shuffledCards,
    required this.correctCount,
    required this.wrongCount,
    required this.onComplete,
  });

  List<CardItem> get wrongCards =>
      shuffledCards.where((c) => c.wrongCount > 0).toList();

  List<CardItem> get top10WrongCards {
    final sorted = List<CardItem>.from(wrongCards)
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
    return sorted.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = correctCount + wrongCount;
    final allCorrect = wrongCount == 0;
    final rate = total == 0 ? 0.0 : correctCount / total;
    
    context.watch<AppSettings>();
    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: const Text('🏆 결과',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: allCorrect ? JejuColors.main : JejuColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: allCorrect ? JejuColors.main : JejuColors.point,
                    width: 1.5),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    allCorrect ? '🎉 완벽해요!' : '📊 학습 결과',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: allCorrect ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ResultStat(
                          label: '맞춤',
                          value: correctCount,
                          color: allCorrect ? Colors.white : JejuColors.main),
                      _ResultStat(
                          label: '틀림',
                          value: wrongCount,
                          color: allCorrect
                              ? Colors.white70
                              : Colors.redAccent),
                      _ResultStat(
                          label: '전체',
                          value: total,
                          color: allCorrect ? Colors.white60 : Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor:
                          allCorrect ? Colors.white24 : Colors.grey[200],
                      color: allCorrect ? Colors.white : JejuColors.main,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '정답률 ${(rate * 100).toInt()}%',
                    style: TextStyle(
                        color:
                            allCorrect ? Colors.white70 : Colors.grey[600],
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (wrongCards.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudyScreen(
                      deck: Deck(
                        name: '오답 복습',
                        cards: wrongCards
                            .map((c) =>
                                CardItem(front: c.front, back: c.back))
                            .toList(),
                      ),
                      onComplete: onComplete,
                    ),
                  ),
                ),
                icon: const Icon(Icons.replay),
                label: Text('틀린 카드 다시 보기 (${wrongCards.length}장)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset('assets/images/topscorer.png', height: 28),
                    const SizedBox(width: 8),
                    const Text('틀린 횟수 Top 10',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: top10WrongCards.length,
                  itemBuilder: (context, index) {
                    final card = top10WrongCards[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: JejuColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: JejuColors.point, width: 1.5),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: JejuColors.accent,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(card.front,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(card.back.isEmpty
                            ? '(뒷면 없음)'
                            : card.back),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${card.wrongCount}회',
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/check.png', height: 180),
                      const SizedBox(height: 16),
                      const Text('모두 맞췄어요!',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.popUntil(context, (r) => r.isFirst),
              icon: const Icon(Icons.home),
              label: const Text('홈으로'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JejuColors.main,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ResultStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style:
                TextStyle(color: color.withOpacity(0.8), fontSize: 13)),
      ],
    );
  }
}