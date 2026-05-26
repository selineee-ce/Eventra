class ExclusiveDrop {
  final int id;
  final String title;
  final String badge;
  final String description;
  final String type;
  final String? image;           // ← tambah ini (nullable, bisa kosong)
  final int countdownSeconds;
  final int sortOrder;

  const ExclusiveDrop({
    required this.id,
    required this.title,
    required this.badge,
    required this.description,
    required this.type,
    this.image,                  // ← tambah ini
    required this.countdownSeconds,
    required this.sortOrder,
  });

  factory ExclusiveDrop.fromJson(Map<String, dynamic> json) => ExclusiveDrop(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        badge: json['badge'] as String? ?? '',
        description: json['description'] as String? ?? '',
        type: json['type'] as String? ?? 'ticket',
        image: json['image'] as String?,    // ← tambah ini
        countdownSeconds: json['countdown_seconds'] as int? ?? 9912,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}