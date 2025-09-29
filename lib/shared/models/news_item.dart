class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String? content;
  final DateTime publishedDate;
  final String? imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    required this.publishedDate,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewsItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
