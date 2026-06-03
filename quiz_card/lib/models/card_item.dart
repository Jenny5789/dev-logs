class CardItem {
  String front;
  String back;
  int wrongCount;

  CardItem({required this.front, this.back = '', this.wrongCount = 0});

  Map<String, dynamic> toJson() => {
    'front': front,
    'back': back,
    'wrongCount': wrongCount,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    front: json['front'],
    back: json['back'] ?? '',
    wrongCount: json['wrongCount'] ?? 0,
  );
}