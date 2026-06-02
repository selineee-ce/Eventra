class TicketType {
  final int id;
  final String name;
  final String? badge;
  final String? badgeColor;
  final String? description;
  final String? bullet1;
  final String? bullet2;
  final String? bullet3;
  final int price;
  final int stockRemaining;
  final int maxPerOrder;
  int quantity;

  TicketType({
    required this.id,
    required this.name,
    this.badge,
    this.badgeColor,
    this.description,
    this.bullet1,
    this.bullet2,
    this.bullet3,
    required this.price,
    required this.stockRemaining,
    required this.maxPerOrder,
    this.quantity = 0,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) => TicketType(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    badge: json['badge'] as String?,
    badgeColor: json['badge_color'] as String?,
    description: json['description'] as String?,
    bullet1: json['bullet1'] as String?,
    bullet2: json['bullet2'] as String?,
    bullet3: json['bullet3'] as String?,
    price: json['price'] as int? ?? 0,
    stockRemaining: json['stock_remaining'] as int? ?? 0,
    maxPerOrder: json['max_per_order'] as int? ?? 4,
  );
}
