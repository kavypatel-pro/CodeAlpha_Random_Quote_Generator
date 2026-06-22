class Quote {
  final String text;
  final String author;
  final String category;

  const Quote({
    required this.text,
    required this.author,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] as String? ?? '',
      author: json['author'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'motivation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author &&
          category == other.category;

  @override
  int get hashCode => text.hashCode ^ author.hashCode ^ category.hashCode;
}
