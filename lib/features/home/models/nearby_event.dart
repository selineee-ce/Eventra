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

  factory NearbyEvent.fromJson(Map<String, dynamic> json){
    return NearbyEvent(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      place: (json['venue'] ?? json['place']) as String? ?? '',
      city: json['city'] as String? ?? '',
      artistName: (json['lineup'] ?? json['artist_name']) as String? ?? '',
      dateLabel: (json['date_label'] ?? json['date']) as String? ?? '',
      price: json['price'] as String? ?? '',
      image: json['image'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
    );
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
