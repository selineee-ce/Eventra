import 'package:eventra/features/home/models/featured_event.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/pass_package.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.featuredEvents = const [],
    this.passes = const [],
    this.nearbyEvents = const [],
    this.visibleNearbyCount = 4,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<FeaturedEvent> featuredEvents; // dari tabel featured_events
  final List<PassPackage> passes;           // dari tabel pass_packages
  final List<NearbyEvent> nearbyEvents;     // dari tabel nearby_events
  final int visibleNearbyCount;
  final String? errorMessage;

  bool get isLoading => status == HomeStatus.loading;
  bool get hasError   => status == HomeStatus.error;
  bool get hasData    => status == HomeStatus.success;

  List<NearbyEvent> get visibleNearbyEvents =>
      nearbyEvents.take(visibleNearbyCount).toList();

  HomeState copyWith({
    HomeStatus? status,
    List<FeaturedEvent>? featuredEvents,
    List<PassPackage>? passes,
    List<NearbyEvent>? nearbyEvents,
    int? visibleNearbyCount,
    String? errorMessage,
  }) =>
      HomeState(
        status: status ?? this.status,
        featuredEvents: featuredEvents ?? this.featuredEvents,
        passes: passes ?? this.passes,
        nearbyEvents: nearbyEvents ?? this.nearbyEvents,
        visibleNearbyCount: visibleNearbyCount ?? this.visibleNearbyCount,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
