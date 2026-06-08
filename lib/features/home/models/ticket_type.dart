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
    id: _asInt(json['id']),
    name: json['name']?.toString() ?? '',
    badge: json['badge']?.toString(),
    badgeColor: json['badge_color']?.toString(),
    description: json['description']?.toString(),
    bullet1: json['bullet1']?.toString(),
    bullet2: json['bullet2']?.toString(),
    bullet3: json['bullet3']?.toString(),
    price: _asInt(json['price']),
    stockRemaining: _asInt(json['stock_remaining']),
    maxPerOrder: _asInt(json['max_per_order'], fallback: 4),
  );

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
