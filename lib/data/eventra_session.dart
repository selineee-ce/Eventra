import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EventraSession {
  EventraSession._();

  static final EventraSession instance = EventraSession._();
  static const String _sessionKey = 'eventra.session.user';

  Map<String, dynamic>? currentUser;

  bool get isLoggedIn => currentUser != null;
  int? get userId {
    final rawId = currentUser?['id'];
    if (rawId is num) return rawId.toInt();
    return int.tryParse(rawId?.toString() ?? '');
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);

    if (raw == null || raw.isEmpty) {
      currentUser = null;
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        currentUser = decoded;
        return;
      }

      if (decoded is Map) {
        currentUser = Map<String, dynamic>.from(decoded);
        return;
      }
    } catch (_) {
      // Ignore invalid persisted payloads and reset session.
    }

    currentUser = null;
    await prefs.remove(_sessionKey);
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user));
  }

  Future<void> clear() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
