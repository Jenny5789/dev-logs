import 'card_item.dart';

class Deck {
  String name;
  List<CardItem> cards;

  Deck({required this.name, List<CardItem>? cards}) : cards = cards ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'cards': cards.map((c) => c.toJson()).toList(),
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    name: json['name'],
    cards: (json['cards'] as List)
        .map((c) => CardItem.fromJson(c))
        .toList(),
  );
}