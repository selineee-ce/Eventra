import 'dart:convert';
import 'package:http/http.dart' as http;

class PromotorApi {
  PromotorApi._();
  static final PromotorApi instance = PromotorApi._();

  static const String _baseUrl = String.fromEnvironment(
    'EVENTRA_API_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  Future<String> checkApplicationStatus(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/promotor/application-status'),
      headers: {'x-user-id': userId.toString()},
    );
    final decoded = _decode(response);
    return decoded['status'] as String? ?? 'none';
  }

  Future<Map<String, dynamic>> register({
    required String organizationName,
    required String contactEmail,
    required String portfolioLink,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/promotor/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'organization_name': organizationName,
        'contact_email': contactEmail,
        'portfolio_link': portfolioLink,
      }),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> fetchDashboard(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/promotor/dashboard'),
      headers: {'x-user-id': userId.toString()},
    );
    return _decode(response);
  }

  Future<List<Map<String, dynamic>>> fetchEvents(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/promotor/events'),
      headers: {'x-user-id': userId.toString()},
    );
    final decoded = _decode(response);
    final data = decoded['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> createEvent({
    required int userId,
    required String title,
    String? artistName,
    String? venue,
    required String description,
    required String location,
    required String eventDate,
    required String eventTime,
    String? image,
    String status = 'draft',
    required List<Map<String, dynamic>> tickets,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/promotor/events'),
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': userId.toString(),
      },
      body: jsonEncode({
        'title': title,
        'artist_name': artistName,
        'venue': venue,
        'description': description,
        'location': location,
        'event_date': eventDate,
        'event_time': eventTime,
        'image': image,
        'status': status,
        'tickets': tickets,
      }),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> updateEvent({
  required int userId,
  required int eventId,
  required String title,
  String? artistName,
  String? venue,
  required String description,
  required String location,
  required String eventDate,
  required String eventTime,
  String? image,
  String? status,
  required List<Map<String, dynamic>> tickets,
}) async {
  final response = await http.put(
    Uri.parse('$_baseUrl/promotor/events/$eventId'),
    headers: {
      'Content-Type': 'application/json',
      'x-user-id': userId.toString(),
    },
    body: jsonEncode({
      'title': title,
      'artist_name': artistName,
      'venue': venue,
      'description': description,
      'location': location,
      'event_date': eventDate,
      'event_time': eventTime,
      'image': image,
      'status': status,
      'tickets': tickets,
    }),
  );
  return _decode(response);
}

  Future<void> deleteEvent({required int userId, required int eventId}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/promotor/events/$eventId'),
      headers: {'x-user-id': userId.toString()},
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
      } catch (_) {}
      throw Exception(message ?? 'Request failed: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'data': decoded};
  }
}
