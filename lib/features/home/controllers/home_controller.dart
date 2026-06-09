import 'package:eventra/data/favorites_notifier.dart';
import 'package:eventra/features/home/controllers/home_state.dart';
import 'package:eventra/features/home/models/featured_event.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/pass_package.dart';
import 'package:eventra/features/home/repositories/home_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:eventra/features/home/models/exclusive_drop.dart';

class HomeController extends ChangeNotifier {
  HomeController({HomeRepository? repository})
    : _repository = repository ?? const HomeRepository();

  final HomeRepository _repository;

  HomeState _state = const HomeState();
  HomeState get state => _state;

  /// Memfilter data lokal events berdasarkan kota yang sama dengan profile user
  List<NearbyEvent> getEventsByCity(String? userLocation) {
    if (userLocation == null || userLocation.isEmpty) {
      return _state.nearbyEvents; 
    }
    return _state.nearbyEvents.where((event) {
      return event.city.trim().toLowerCase() == userLocation.trim().toLowerCase();
    }).toList();
  }

  Future<void> loadAll() async {
    _emit(_state.copyWith(status: HomeStatus.loading));
    try {
      final results = await Future.wait([
        _repository.fetchFeaturedEvents(),
        _repository.fetchPasses(),
        _repository.fetchNearbyEvents(),
        _repository.fetchExclusiveDrops(),
      ]);

      final featured = results[0] as List<FeaturedEvent>;
      final passes = results[1] as List<PassPackage>;
      final nearby = results[2] as List<NearbyEvent>;
      final exclusiveDrops = results[3] as List<ExclusiveDrop>;
      _emit(
        _state.copyWith(
          status: HomeStatus.success,
          featuredEvents: featured,
          passes: passes,
          nearbyEvents: nearby,
          exclusiveDrops: exclusiveDrops,
          visibleNearbyCount: nearby.length < 4 ? nearby.length : 4,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _emit(
        _state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Toggle favorit pass → UPDATE pass_packages SET is_favorite = ?
  // Setelah berhasil, kirim sinyal ke FavoritesPage untuk reload
  Future<void> togglePassFavorite(PassPackage pass) async {
    final newVal = !pass.isFavorite;
    _updatePass(pass.copyWith(isFavorite: newVal));
    try {
      await _repository.setPassFavorite(passId: pass.id, isFavorite: newVal);
      FavoritesNotifier.instance.notify(); // ← sinyal ke FavoritesPage
    } catch (_) {
      _updatePass(pass.copyWith(isFavorite: pass.isFavorite)); // rollback
    }
  }

  // Toggle favorit nearby event → UPDATE nearby_events SET is_favorite = ?
  // Setelah berhasil, kirim sinyal ke FavoritesPage untuk reload
  Future<void> toggleNearbyFavorite(NearbyEvent event) async {
    final newVal = !event.isFavorite;
    _updateNearby(event.copyWith(isFavorite: newVal));
    try {
      await _repository.setNearbyEventFavorite(
        eventId: event.id,
        isFavorite: newVal,
      );
      FavoritesNotifier.instance.notify(); // ← sinyal ke FavoritesPage
    } catch (_) {
      _updateNearby(event.copyWith(isFavorite: event.isFavorite)); // rollback
    }
  }

  Future<void> setFavoriteByType({
    required String type,
    required int id,
    required bool isFavorite,
  }) async {
    if (type == 'pass') {
      final pass = _findPass(id);
      if (pass != null) {
        _updatePass(pass.copyWith(isFavorite: isFavorite));
      }

      try {
        await _repository.setPassFavorite(passId: id, isFavorite: isFavorite);
        FavoritesNotifier.instance.notify();
      } catch (_) {
        if (pass != null) {
          _updatePass(pass);
        }
      }
      return;
    }

    final event = _findNearbyEvent(id);
    if (event != null) {
      _updateNearby(event.copyWith(isFavorite: isFavorite));
    }

    try {
      await _repository.setNearbyEventFavorite(
        eventId: id,
        isFavorite: isFavorite,
      );
      FavoritesNotifier.instance.notify();
    } catch (_) {
      if (event != null) {
        _updateNearby(event);
      }
    }
  }

  void showAllNearbyEvents() =>
      _emit(_state.copyWith(visibleNearbyCount: _state.nearbyEvents.length));

  void resetNearbyEvents() => _emit(_state.copyWith(visibleNearbyCount: 4));

  void _updatePass(PassPackage updated) => _emit(
    _state.copyWith(
      passes: _state.passes
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    ),
  );

  void _updateNearby(NearbyEvent updated) => _emit(
    _state.copyWith(
      nearbyEvents: _state.nearbyEvents
          .map((e) => e.id == updated.id ? updated : e)
          .toList(),
    ),
  );

  PassPackage? _findPass(int id) {
    for (final pass in _state.passes) {
      if (pass.id == id) {
        return pass;
      }
    }
    return null;
  }

  NearbyEvent? _findNearbyEvent(int id) {
    for (final event in _state.nearbyEvents) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  void _emit(HomeState s) {
    _state = s;
    notifyListeners();
  }
}
