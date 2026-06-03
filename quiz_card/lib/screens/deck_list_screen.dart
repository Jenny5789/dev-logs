import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import 'card_list_screen.dart';

class DeckListScreen extends StatefulWidget {
  final List<Deck> decks;
  final Function(int, int, Deck) onStudyComplete;
  final VoidCallback onDecksChanged;

  const DeckListScreen({
    super.key,
    required this.decks,
    required this.onStudyComplete,
    required this.onDecksChanged,
  });

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Deck> get _filteredDecks => _searchQuery.isEmpty
      ? widget.decks
      : widget.decks
          .where((d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  void _addDeck() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('단어장 추가'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '단어장 이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => widget.decks.add(Deck(name: controller.text)));
                widget.onDecksChanged();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('단어장 이름을 입력해주세요!')),
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

  void _editDeck(int index) {
    final controller = TextEditingController(text: widget.decks[index].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('단어장 수정'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '단어장 이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => widget.decks[index].name = controller.text);
                widget.onDecksChanged();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('단어장 이름을 입력해주세요!')),
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

  void _deleteDeck(Deck deck) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('단어장 삭제'),
        content: Text(
          '"${deck.name}" 단어장을 삭제할까요?\n카드 ${deck.cards.length}장도 함께 삭제돼요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => widget.decks.remove(deck));
              widget.onDecksChanged();
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
                  hintText: '단어장 검색...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('📚 단어장 목록',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: _filteredDecks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_searchQuery.isEmpty)
                    Image.asset('assets/images/subject.png', height: 160)
                  else
                    Image.asset('assets/images/search.png', height: 160),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? '단어장이 없어요!'
                        : '"$_searchQuery" 검색 결과가 없어요',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_searchQuery.isEmpty)
                    const Text('+ 버튼으로 단어장을 만들어보세요',
                        style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              buildDefaultDragHandles: false,
              itemCount: _filteredDecks.length,
              onReorder: _searchQuery.isNotEmpty
                  ? (_, __) {}
                  : (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final deck = widget.decks.removeAt(oldIndex);
                        widget.decks.insert(newIndex, deck);
                      });
                      widget.onDecksChanged();
                    },
              itemBuilder: (context, index) {
                final deck = _filteredDecks[index];
                final realIndex = widget.decks.indexOf(deck);
                return Container(
                  key: ValueKey(deck.name),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: JejuColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: JejuColors.point, width: 1.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: JejuColors.point,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.book,
                          color: JejuColors.main, size: 22),
                    ),
                    title: Text(deck.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('카드 ${deck.cards.length}장',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: JejuColors.main, size: 20),
                          onPressed: () => _editDeck(realIndex),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteDeck(deck),
                        ),
                        if (_searchQuery.isEmpty)
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle,
                                color: Colors.grey, size: 20),
                          ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardListScreen(
                          deck: deck,
                          onStudyComplete: widget.onStudyComplete,
                          onCardsChanged: widget.onDecksChanged,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.decks.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardListScreen(
                                deck: widget.decks.first,
                                onStudyComplete: widget.onStudyComplete,
                                onCardsChanged: widget.onDecksChanged,
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.play_circle),
                  label: Text(widget.decks.isEmpty
                      ? '단어장을 추가해야 학습할 수 있어요'
                      : '학습 시작 (${widget.decks.first.name})'),
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
                onPressed: _addDeck,
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
    );
  }
}