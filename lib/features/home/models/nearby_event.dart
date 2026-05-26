// Model untuk tabel `nearby_events` di MySQL
// Query di server.js:
//   SELECT id, title, date_label AS date, place, price, image, sort_order, is_favorite
//   FROM nearby_events ORDER BY sort_order ASC
class NearbyEvent {
  final int id;
  final String title;
  final String dateLabel; // dari kolom `date_label`, alias `date` di API
  final String place;
  final String price;
  final String image;
  final int sortOrder;
  final bool isFavorite;

  const NearbyEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.place,
    required this.price,
    required this.image,
    required this.sortOrder,
    required this.isFavorite,
  });

  factory NearbyEvent.fromJson(Map<String, dynamic> json) => NearbyEvent(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        // API mengirim field ini sebagai 'date' (alias dari kolom 'date_label')
        dateLabel: (json['date'] ?? json['date_label']) as String? ?? '',
        place: json['place'] as String? ?? '',
        price: json['price'] as String? ?? '',
        image: json['image'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
        isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
      );

  NearbyEvent copyWith({bool? isFavorite}) => NearbyEvent(
        id: id, title: title, dateLabel: dateLabel, place: place,
        price: price, image: image, sortOrder: sortOrder,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
