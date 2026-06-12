// Model untuk tabel `pass_packages` di MySQL
// Query di server.js:
//   SELECT id, title, description AS desc, price, sort_order, is_favorite
//   FROM pass_packages ORDER BY sort_order ASC
class PassPackage {
  final int id;
  final String title;
  final String description; // dari kolom `description`, alias `desc` di API
  final String price;
  final int sortOrder;
  final bool isFavorite;

  const PassPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sortOrder,
    required this.isFavorite,
  });

  factory PassPackage.fromJson(Map<String, dynamic> json) => PassPackage(
    id: _asInt(json['id']),
    title: json['title'] as String? ?? '',
    // API mengirim field ini sebagai 'desc' (alias dari kolom 'description')
    description: (json['desc'] ?? json['description']) as String? ?? '',
    price: json['price'] as String? ?? '',
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

  PassPackage copyWith({bool? isFavorite}) => PassPackage(
    id: id,
    title: title,
    description: description,
    price: price,
    sortOrder: sortOrder,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
