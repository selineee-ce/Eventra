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
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        // API mengirim field ini sebagai 'desc' (alias dari kolom 'description')
        description: (json['desc'] ?? json['description']) as String? ?? '',
        price: json['price'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
        isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
      );

  PassPackage copyWith({bool? isFavorite}) => PassPackage(
        id: id, title: title, description: description,
        price: price, sortOrder: sortOrder,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
