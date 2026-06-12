// Model untuk tabel `featured_events` di MySQL
// Query di server.js:
//   SELECT id, title, subtitle, image, tag1, tag2, button, sort_order, is_favorite
//   FROM featured_events ORDER BY sort_order ASC
class FeaturedEvent {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final String tag1;
  final String? tag2;
  final String button;
  final int sortOrder;
  final bool isFavorite;

  const FeaturedEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.tag1,
    this.tag2,
    required this.button,
    required this.sortOrder,
    required this.isFavorite,
  });

  factory FeaturedEvent.fromJson(Map<String, dynamic> json) => FeaturedEvent(
    id: _asInt(json['id']),
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    image: json['image'] as String? ?? '',
    tag1: json['tag1'] as String? ?? '',
    tag2: json['tag2'] as String?,
    button: json['button'] as String? ?? '',
    sortOrder: _asInt(json['sort_order']),
    isFavorite: _asBool(json['is_favorite']),
  );

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true';
  }

  FeaturedEvent copyWith({bool? isFavorite}) => FeaturedEvent(
    id: id,
    title: title,
    subtitle: subtitle,
    image: image,
    tag1: tag1,
    tag2: tag2,
    button: button,
    sortOrder: sortOrder,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
