import 'package:flutter/foundation.dart';

class TicketsNotifier extends ChangeNotifier {
  TicketsNotifier._();

  static final TicketsNotifier instance = TicketsNotifier._();

  void notify() => notifyListeners();
}
