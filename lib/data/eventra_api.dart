import 'dart:convert';
import 'package:http/http.dart' as http;

class EventraApi {
  static const String baseUrl =
      'http://10.0.2.2:3000/api';

  static Future<List<Map<String, dynamic>>>
      fetchFeaturedEvents() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/home/featured-events',
      ),
    );

    final body =
        jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      body['data'],
    );
  }

  static Future<List<Map<String, dynamic>>>
      fetchPasses() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/home/passes',
      ),
    );

    final body =
        jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      body['data'],
    );
  }

  static Future<List<Map<String, dynamic>>>
      fetchNearbyEvents() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/home/nearby-events',
      ),
    );

    final body =
        jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      body['data'],
    );
  }
}