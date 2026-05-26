import 'package:flutter/foundation.dart';

// FavoritesNotifier — shared state sederhana
//
// Dipakai untuk memberi sinyal ke FavoritesPage agar reload
// setiap kali user toggle favorit di homepage.
//
// Alur:
//   HomeController.toggleNearbyFavorite()
//     → UPDATE nearby_events SET is_favorite = ? di MySQL
//     → FavoritesNotifier.notify()
//     → FavoritesPage mendengar → _loadFavorites() dipanggil ulang
class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier._();
  static final FavoritesNotifier instance = FavoritesNotifier._();

  // Dipanggil setiap kali ada perubahan favorit (dari home atau halaman mana pun)
  void notify() => notifyListeners();
}
