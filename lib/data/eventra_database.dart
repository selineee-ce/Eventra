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

  Future<List<Map<String, dynamic>>> fetchNearbyEvents() async =>
      _getList('/home/nearby-events');

  Future<List<Map<String, dynamic>>> fetchTickets() async =>
      _getList('/tickets');

  Future<List<Map<String, dynamic>>> fetchNotifications() async =>
      _getList('/notifications');

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.get(Uri.parse('$_baseUrl/profile'));
    return _decodeMap(response, 'profile');
  }

  Future<List<Map<String, dynamic>>> fetchTrendingArtists() async {
    return _getList('/artists');
  }

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
    await _postJson('/nearby-events/$eventId/favorite', {'isFavorite': isFavorite});
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
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      _decode(response);
    } catch (_) {
      return;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: ${response.statusCode} ${response.body}');
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