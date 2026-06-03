import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import 'study_screen.dart';

class CardListScreen extends StatefulWidget {
  final Deck deck;
  final Function(int, int, Deck) onStudyComplete;
  final VoidCallback onCardsChanged;

  const CardListScreen({
    super.key,
    required this.deck,
    required this.onStudyComplete,
    required this.onCardsChanged,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<CardItem> get _filteredCards => _searchQuery.isEmpty
      ? widget.deck.cards
      : widget.deck.cards
          .where((c) =>
              c.front.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.back.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  void _addCard() {
    final frontController = TextEditingController();
    final backController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카드 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration: const InputDecoration(
                labelText: '앞면 (질문/단어)',
                hintText: '앞면은 필수예요',
              ),
            ),
            TextField(
              controller: backController,
              decoration:
                  const InputDecoration(labelText: '뒷면 (답/뜻) - 선택'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (frontController.text.isNotEmpty) {
                setState(() {
                  widget.deck.cards.add(CardItem(
                    front: frontController.text,
                    back: backController.text,
                  ));
                });
                widget.onCardsChanged();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('앞면은 반드시 입력해야 해요!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: JejuColors.main,
                foregroundColor: Colors.white),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _editCard(CardItem card) {
    final frontController = TextEditingController(text: card.front);
    final backController = TextEditingController(text: card.back);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카드 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration:
                  const InputDecoration(labelText: '앞면 (질문/단어)'),
            ),
            TextField(
              controller: backController,
              decoration:
                  const InputDecoration(labelText: '뒷면 (답/뜻) - 선택'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (frontController.text.isNotEmpty) {
                setState(() {
                  card.front = frontController.text;
                  card.back = backController.text;
                });
                widget.onCardsChanged();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('앞면은 반드시 입력해야 해요!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: JejuColors.main,
                foregroundColor: Colors.white),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _deleteCard(CardItem card) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카드 삭제'),
        content: Text('"${card.front}" 카드를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => widget.deck.cards.remove(card));
              widget.onCardsChanged();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettings>();    
    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '카드 검색...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text('📋 ${widget.deck.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.deck.cards.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudyScreen(
                                deck: widget.deck,
                                onComplete: widget.onStudyComplete,
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.play_circle),
                  label: Text(widget.deck.cards.isEmpty
                      ? '카드를 추가해야 학습할 수 있어요'
                      : '학습 시작 (${widget.deck.cards.length}장)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JejuColors.main,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 56,
              height: 56,
              child: ElevatedButton(
                onPressed: _addCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JejuColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isSearching && _searchQuery.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: JejuColors.point,
              child: Row(
                children: [
                  Icon(Icons.search, color: JejuColors.main, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '"$_searchQuery" 검색 결과 ${_filteredCards.length}개',
                    style: TextStyle(
                        color: JejuColors.main, fontSize: 13),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _filteredCards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_searchQuery.isEmpty)
                          Image.asset('assets/images/idea.png', height: 160)
                        else
                          Image.asset('assets/images/search.png',
                              height: 160),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? '카드가 없어요!'
                              : '"$_searchQuery" 검색 결과가 없어요',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isEmpty)
                          const Text('+ 버튼으로 카드를 추가해보세요',
                              style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    buildDefaultDragHandles: false,
                    itemCount: _filteredCards.length,
                    onReorder: _searchQuery.isNotEmpty
                        ? (_, __) {}
                        : (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final card =
                                  widget.deck.cards.removeAt(oldIndex);
                              widget.deck.cards.insert(newIndex, card);
                            });
                            widget.onCardsChanged();
                          },
                    itemBuilder: (context, index) {
                      final card = _filteredCards[index];
                      return Container(
                        key: ValueKey('${card.front}_$index'),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: JejuColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: JejuColors.point, width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: JejuColors.main,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text('앞면',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11)),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(card.front,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 15)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: JejuColors.accent,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text('뒷면',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11)),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            card.back.isEmpty
                                                ? '(없음)'
                                                : card.back,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: card.back.isEmpty
                                                  ? Colors.grey[400]
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: JejuColors.main, size: 20),
                                    onPressed: () => _editCard(card),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 20),
                                    onPressed: () => _deleteCard(card),
                                  ),
                                  if (_searchQuery.isEmpty)
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(Icons.drag_handle,
                                          color: Colors.grey, size: 20),
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
        ],
      ),
    );
  }
}