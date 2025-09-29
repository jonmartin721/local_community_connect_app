class Event {
  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String description;
  final String? location;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.description,
    this.location,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Event && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
