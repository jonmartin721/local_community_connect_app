class LocalResource {
  final String id;
  final String name;
  final String category;
  final String? address;
  final String? phoneNumber;
  final String? websiteUrl;
  final String? description;

  LocalResource({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    this.phoneNumber,
    this.websiteUrl,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalResource && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
