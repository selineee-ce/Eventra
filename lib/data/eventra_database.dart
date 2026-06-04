import 'dart:convert';

import 'package:http/http.dart' as http;

class EventraDatabase {
  EventraDatabase._();

  static final EventraDatabase instance = EventraDatabase._();

  static const String _baseUrl = String.fromEnvironment(
    'EVENTRA_API_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  Future<List<Map<String, dynamic>>> fetchFeaturedEvents() async =>
      _getList('/home/featured-events');

  Future<List<Map<String, dynamic>>> fetchPasses() async =>
      _getList('/home/passes');

  Future<List<Map<String, dynamic>>> fetchExclusiveDrops() async =>
      _getList('/home/exclusive-drops');

  Future<List<Map<String, dynamic>>> fetchNearbyEvents({String? location}) {
    final query = (location == null || location.trim().isEmpty)
        ? ''
        : '?location=${Uri.encodeQueryComponent(location.trim())}';
    return _getList('/home/nearby-events$query');
  }

  Future<List<Map<String, dynamic>>> fetchTickets() async =>
      _getList('/tickets');

  Future<List<Map<String, dynamic>>> fetchNotifications() async =>
      _getList('/notifications');

  Future<List<Map<String, dynamic>>> fetchFavorites() async =>
      _getList('/favorites');

  Future<List<Map<String, dynamic>>> fetchTicketTypes(int eventId) async =>
      _getList('/nearby-events/$eventId/ticket-types');

  Future<Map<String, dynamic>> fetchNearbyEventDetail(int eventId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/nearby-events/$eventId/detail'),
    );
    return _decodeMap(response, 'data');
  }

  Future<Map<String, String>> fetchAppConfig() async {
    final response = await http.get(Uri.parse('$_baseUrl/app-config'));
    final decoded = _decode(response);
    final config = decoded['config'];

    if (config is! Map) {
      return <String, String>{};
    }

    return config.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.get(Uri.parse('$_baseUrl/profile'));
    return _decodeMap(response, 'profile');
  }

  Future<List<Map<String, dynamic>>> fetchTrendingArtists() async =>
      _getList('/artists');

  Future<void> setPassFavorite({
    required int passId,
    required bool isFavorite,
  }) async {
    await _postJson('/passes/$passId/favorite', {'isFavorite': isFavorite});
  }

  Future<void> setNearbyFavorite({
    required int eventId,
    required bool isFavorite,
  }) async {
    await _postJson('/nearby-events/$eventId/favorite', {
      'isFavorite': isFavorite,
    });
  }

  Future<Map<String, dynamic>> checkoutPayment({
    required int eventId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? card,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/checkout'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventId': eventId,
        'paymentMethod': paymentMethod,
        'items': items,
        if (card != null) 'card': card,
      }),
    );

    return _decodeMap(response, 'payment');
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    return _decodeMap(response, 'user');
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    return _decodeMap(response, 'user');
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$path'));
      final decoded = _decode(response);
      final data = decoded['data'];

      if (data is! List) {
        return <Map<String, dynamic>>[];
      }

      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>> _decodeMap(
    http.Response response,
    String key,
  ) async {
    try {
      final decoded = _decode(response);
      final data = decoded[key];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Future<void> _postJson(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? message;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {
        message = null;
      }

      throw Exception(message ?? 'Request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return <String, dynamic>{'data': decoded};
  }
}
