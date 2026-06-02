// HomeRepository — jembatan antara Flutter dan backend Node.js/MySQL
//
// Alur data lengkap:
//   MySQL (featured_events / pass_packages / nearby_events)
//     → server.js (query SQL → JSON response)
//     → EventraDatabase.instance (HTTP client)
//     → HomeRepository (parse JSON → typed model objects)
//     → HomeController → Widget
//

import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/home/models/featured_event.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/pass_package.dart';
import 'package:eventra/features/home/models/exclusive_drop.dart';

class HomeRepository {
  const HomeRepository();

  // Mengambil dari tabel `featured_events`
  // Endpoint: GET /api/home/featured-events
  Future<List<FeaturedEvent>> fetchFeaturedEvents() async {
    final raw = await EventraDatabase.instance.fetchFeaturedEvents();
    return raw.map(FeaturedEvent.fromJson).toList();
  }

  // Mengambil dari tabel `pass_packages`
  // Endpoint: GET /api/home/passes
  Future<List<PassPackage>> fetchPasses() async {
    final raw = await EventraDatabase.instance.fetchPasses();
    return raw.map(PassPackage.fromJson).toList();
  }

  // Mengambil dari tabel `nearby_events`
  // Endpoint: GET /api/home/nearby-events
  Future<List<NearbyEvent>> fetchNearbyEvents() async {
    final raw = await EventraDatabase.instance.fetchNearbyEvents();
    return raw.map(NearbyEvent.fromJson).toList();
  }

  Future<List<ExclusiveDrop>> fetchExclusiveDrops() async {
    final raw = await EventraDatabase.instance.fetchExclusiveDrops();
    return raw.map(ExclusiveDrop.fromJson).toList();
  }

  // UPDATE pass_packages SET is_favorite = ? WHERE id = ?
  // Endpoint: POST /api/passes/:id/favorite
  Future<void> setPassFavorite({required int passId, required bool isFavorite}) async {
    await EventraDatabase.instance.setPassFavorite(
      passId: passId,
      isFavorite: isFavorite,
    );
  }

  // UPDATE nearby_events SET is_favorite = ? WHERE id = ?
  // Endpoint: POST /api/nearby-events/:id/favorite
  Future<void> setNearbyEventFavorite({required int eventId, required bool isFavorite}) async {
    await EventraDatabase.instance.setNearbyFavorite(
      eventId: eventId,
      isFavorite: isFavorite,
    );
  }
}
