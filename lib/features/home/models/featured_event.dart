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
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        image: json['image'] as String? ?? '',
        tag1: json['tag1'] as String? ?? '',
        tag2: json['tag2'] as String?,
        button: json['button'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
        isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
      );

  FeaturedEvent copyWith({bool? isFavorite}) => FeaturedEvent(
        id: id, title: title, subtitle: subtitle, image: image,
        tag1: tag1, tag2: tag2, button: button, sortOrder: sortOrder,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
