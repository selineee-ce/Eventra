// Model untuk tabel `events` di MySQL
// Query di server.js:
//   SELECT id, title, date_label, venue, city, lineup, price, image, sort_order, is_favorite
//   FROM events ORDER BY sort_order ASC
class NearbyEvent {
  final int id;
  final String title;
  final String dateLabel;
  final String place;
  final String city;
  final String artistName;
  final String price;
  final String image;
  final int sortOrder;
  final bool isFavorite;

  const NearbyEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.place,
    required this.city,
    required this.artistName,
    required this.price,
    required this.image,
    required this.sortOrder,
    required this.isFavorite,
  });

  factory NearbyEvent.fromJson(Map<String, dynamic> json) {
    return NearbyEvent(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      place: (json['venue'] ?? json['place'])?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      artistName: (json['lineup'] ?? json['artist_name'])?.toString() ?? '',
      dateLabel: (json['date_label'] ?? json['date'])?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      sortOrder: _asInt(json['sort_order']),
      isFavorite: _asBool(json['is_favorite']),
    );
  }

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

  NearbyEvent copyWith({
    int? id,
    String? title,
    String? dateLabel,
    String? place,
    String? city,
    String? artistName,
    String? price,
    String? image,
    int? sortOrder,
    bool? isFavorite,
  }) {
    return NearbyEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      dateLabel: dateLabel ?? this.dateLabel,
      place: place ?? this.place,
      city: city ?? this.city,
      artistName: artistName ?? this.artistName,
      price: price ?? this.price,
      image: image ?? this.image,
      sortOrder: sortOrder ?? this.sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
