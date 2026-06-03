import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import '../services/storage_service.dart';
import 'result_screen.dart';

class StudyScreen extends StatefulWidget {
  final Deck deck;
  final Function(int, int, Deck) onComplete;

  const StudyScreen({
    super.key,
    required this.deck,
    required this.onComplete,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late List<CardItem> shuffledCards;
  int currentIndex = 0;
  bool isFlipped = false;
  int correctCount = 0;
  int wrongCount = 0;
  bool isLoading = true;

  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
    ]).animate(_animController);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await StorageService.loadProgress(widget.deck.name);

    if (progress != null && progress['shuffledFronts'].isNotEmpty) {
      final savedFronts = progress['shuffledFronts'] as List<String>;
      final reordered = savedFronts
          .map((front) => widget.deck.cards.firstWhere(
                (c) => c.front == front,
                orElse: () => widget.deck.cards.first,
              ))
          .toList();

      if (mounted) {
        final resume = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('이어서 학습할까요?'),
            content: Text(
              '${progress['currentIndex'] + 1}번째 카드부터 이어서 할 수 있어요.\n(맞춤 ${progress['correctCount']}개 / 틀림 ${progress['wrongCount']}개)',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('처음부터',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JejuColors.main,
                  foregroundColor: Colors.white,
                ),
                child: const Text('이어서'),
              ),
            ],
          ),
        );

        if (resume == true) {
          setState(() {
            shuffledCards = reordered;
            currentIndex = progress['currentIndex'];
            correctCount = progress['correctCount'];
            wrongCount = progress['wrongCount'];
            isLoading = false;
          });
          return;
        }
      }
    }

    setState(() {
      shuffledCards = List.from(widget.deck.cards)..shuffle(Random());
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_animController.isAnimating) return;
    _animController.forward(from: 0).then((_) {
      setState(() => isFlipped = !isFlipped);
    });
    setState(() {});
  }

  void _onCorrect() {
    setState(() {
      correctCount++;
      _nextCard();
    });
  }

  void _onWrong() {
    setState(() {
      wrongCount++;
      shuffledCards[currentIndex].wrongCount++;
      _nextCard();
    });
  }

  void _nextCard() async {
    if (currentIndex + 1 >= shuffledCards.length) {
      await StorageService.clearProgress();
      widget.onComplete(correctCount, wrongCount, widget.deck);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            deck: widget.deck,
            shuffledCards: shuffledCards,
            correctCount: correctCount,
            wrongCount: wrongCount,
            onComplete: widget.onComplete,
          ),
        ),
      );
    } else {
      currentIndex++;
      isFlipped = false;
      _animController.reset();
      await StorageService.saveProgress(
        deckName: widget.deck.name,
        currentIndex: currentIndex,
        correctCount: correctCount,
        wrongCount: wrongCount,
        shuffledFronts: shuffledCards.map((c) => c.front).toList(),
      );
    }
  }

  Future<void> _onHomePressed() async {
    await StorageService.saveProgress(
      deckName: widget.deck.name,
      currentIndex: currentIndex,
      correctCount: correctCount,
      wrongCount: wrongCount,
      shuffledFronts: shuffledCards.map((c) => c.front).toList(),
    );
    if (mounted) {
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  String get displayText {
    final card = shuffledCards[currentIndex];
    if (isFlipped) {
      return card.back.isEmpty ? '(뒷면이 없는 카드예요)' : card.back;
    }
    return card.front;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    context.watch<AppSettings>();
    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: Text('🎴 ${widget.deck.name}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: _onHomePressed,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await StorageService.saveProgress(
                  deckName: widget.deck.name,
                  currentIndex: currentIndex,
                  correctCount: correctCount,
                  wrongCount: wrongCount,
                  shuffledFronts:
                      shuffledCards.map((c) => c.front).toList(),
                );
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        leadingWidth: 96,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentIndex + 1} / ${shuffledCards.length}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: JejuColors.main, size: 18),
                    const SizedBox(width: 4),
                    Text('$correctCount',
                        style: TextStyle(
                            color: JejuColors.main,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.cancel,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 4),
                    Text('$wrongCount',
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / shuffledCards.length,
                backgroundColor: Colors.grey[300],
                color: JejuColors.main,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 320,
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_animation.value),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFlipped
                              ? JejuColors.point
                              : JejuColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isFlipped
                                ? JejuColors.main
                                : JejuColors.accent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isFlipped
                                    ? JejuColors.main
                                    : JejuColors.accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isFlipped ? '뒷면' : '앞면',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32),
                              child: Text(
                                displayText,
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.touch_app,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '탭해서 뒤집기',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isFlipped)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onWrong,
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('틀림',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onCorrect,
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('맞춤',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JejuColors.main,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: JejuColors.point,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: JejuColors.sub, size: 18),
                    const SizedBox(width: 8),
                    Text('카드를 탭해서 답을 확인하세요',
                        style: TextStyle(color: JejuColors.main)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}