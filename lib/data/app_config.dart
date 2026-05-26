import 'package:eventra/data/eventra_database.dart';

class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  Map<String, String> _values = {};

  String text(String key, String fallback) => _values[key] ?? fallback;

  Future<void> load() async {
    try {
      _values = await EventraDatabase.instance.fetchAppConfig();
    } catch (_) {
      _values = {};
    }
  }
}
