import 'dart:async';
import 'dart:convert';
import 'package:eventra/core/utils/search_match.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/data/tickets_notifier.dart';
import 'package:eventra/features/explore/artists/artists_profile.dart';
import 'package:eventra/features/explore/artists/trending_artists.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/ticket/buy_ticket_page.dart';
import 'package:eventra/features/ticket/my_tickets.dart';
import 'package:eventra/features/ticket/payment_page.dart';
import 'package:eventra/features/ticket/payment_status_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ── Venue model ──────────────────────────────────────────────────────────────

class _ExploreVenue {
  const _ExploreVenue({
    required this.name,
    required this.city,
    required this.image,
    required this.startingPrice,
    required this.events,
    required this.description,
    required this.upcomingEvents,
    this.lat,
    this.lng,
  });

  final String name;
  final String city;
  final String image;
  final String startingPrice;
  final String events;
  final String description;
  final List<NearbyEvent> upcomingEvents;
  final double? lat;
  final double? lng;
}

// ── Venue lat/lng lookup (hardcoded for known Indonesian venues) ──────────────
final _venueCoordinates = <String, LatLng>{
  'tennis indoor senayan': const LatLng(-6.2183, 106.8017),
  'jiexpo kemayoran': const LatLng(-6.1568, 106.8481),
  'balai sarbini jakarta': const LatLng(-6.2148, 106.8227),
  'gedung kesenian jakarta': const LatLng(-6.1349, 106.8132),
  'rossi musik jakarta': const LatLng(-6.2634, 106.7935),
  'ciputra artpreneur jakarta': const LatLng(-6.1764, 106.7892),
  'dyandra convention center': const LatLng(-7.2671, 112.7401),
  'sabuga bandung': const LatLng(-6.8934, 107.6098),
  'jis': const LatLng(-6.1259, 106.8642),
  'gbk': const LatLng(-6.2183, 106.8017),
};

final _venueImages = <String, String>{
  'tennis indoor senayan': 'assets/events/hindia_tennis_indoor.jpeg',
  'jiexpo kemayoran': 'assets/events/laufey_jiexpo.webp',
  'jis': 'assets/stadiums/jis_layout.jpg',
  'gbk': 'assets/stadiums/gbk_layout.jpg',
};

LatLng? _lookupVenueCoords(String venueName) {
  final key = venueName.trim().toLowerCase();
  for (final entry in _venueCoordinates.entries) {
    if (key.contains(entry.key) || entry.key.contains(key)) return entry.value;
  }
  return null;
}

String _lookupVenueImage(String venueName, String fallback) {
  final key = venueName.trim().toLowerCase();
  for (final entry in _venueImages.entries) {
    if (key.contains(entry.key) || entry.key.contains(key)) return entry.value;
  }
  return fallback;
}

// ── Dark map style JSON ───────────────────────────────────────────────────────
const _darkMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#1d1d2e"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a7dbf"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d2e"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2547"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3d3261"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f1f3a"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#d0bcff"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d0d1a"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]}
]''';

// ── Page ─────────────────────────────────────────────────────────────────────

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _artists = [];
  List<NearbyEvent> _events = [];
  bool _loadingArtists = true;
  bool _loadingEvents = true;
  String _localSearchQuery = '';

  // Location state
  LatLng _mapCenter = const LatLng(-6.2088, 106.8456); // Jakarta default
  bool _locationReady = false;

  String get _effectiveSearchQuery =>
      normalizeSearchText(_localSearchQuery).isNotEmpty
      ? _localSearchQuery
      : widget.searchQuery;

  List<NearbyEvent> get _visibleEvents => _events
      .where(
        (event) => matchesSearchQuery(_effectiveSearchQuery, [
          event.title,
          event.artistName,
          event.place,
          event.city,
          event.dateLabel,
          event.price,
        ]),
      )
      .toList();

  List<Map<String, dynamic>> get _visibleArtists => _artists
      .where(
        (artist) =>
            matchesSearchQuery(_effectiveSearchQuery, _artistSearchValues(artist)),
      )
      .toList()
    ..sort((a, b) {
      if (normalizeSearchText(_effectiveSearchQuery).isEmpty) return 0;
      final aScore = searchMatchScore(_effectiveSearchQuery, [
        a['name'],
        a['genre'],
        a['description'],
        ...flattenSearchValues(a['upcomingEvents']),
      ]);
      final bScore = searchMatchScore(_effectiveSearchQuery, [
        b['name'],
        b['genre'],
        b['description'],
        ...flattenSearchValues(b['upcomingEvents']),
      ]);
      return bScore.compareTo(aScore);
    });

  List<Object?> _artistSearchValues(Map<String, dynamic> artist) {
    return [
      ...flattenSearchValues(artist),
      ...flattenSearchValues(artist['upcomingEvents']),
    ];
  }

  List<_ExploreVenue> get _venues {
    final grouped = <String, List<NearbyEvent>>{};
    for (final event in _visibleEvents) {
      final key =
          '${event.place.trim().toLowerCase()}|${event.city.trim().toLowerCase()}';
      grouped.putIfAbsent(key, () => []).add(event);
    }

    return grouped.values
        .map((events) {
          final first = events.first;
          final coords = _lookupVenueCoords(first.place);
          return _ExploreVenue(
            name: first.place.isEmpty ? first.title : first.place,
            city: first.city,
            image: _lookupVenueImage(first.place, first.image),
            startingPrice: first.price.isEmpty ? '-' : first.price,
            events: events.length.toString(),
            description: _venueDescription(first, events.length),
            upcomingEvents: events,
            lat: coords?.latitude,
            lng: coords?.longitude,
          );
        })
        .take(6)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadArtists();
    _loadEvents();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;
      setState(() {
        _mapCenter = LatLng(pos.latitude, pos.longitude);
        _locationReady = true;
      });
    } catch (_) {
      // silently keep Jakarta default
    }
  }

  Future<void> _loadArtists() async {
    try {
      final artists = await EventraDatabase.instance.fetchTrendingArtists();
      if (!mounted) return;
      setState(() {
        _artists = artists;
        _loadingArtists = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingArtists = false);
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventraDatabase.instance.fetchNearbyEvents(
        location: '',
      );
      if (!mounted) return;
      setState(() {
        _events = events.map(NearbyEvent.fromJson).toList();
        _loadingEvents = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingEvents = false);
    }
  }

  String _venueDescription(NearbyEvent event, int eventCount) {
    final artist = event.artistName.isEmpty ? event.title : event.artistName;
    return '${event.place} hosts $eventCount upcoming Eventra '
        '${eventCount == 1 ? 'event' : 'events'}, including $artist. '
        'Ticket categories and venue details follow the same event data used on the home page.';
  }

  @override
  Widget build(BuildContext context) {
    final visibleEvents = _visibleEvents;
    final visibleArtists = _visibleArtists;
    final venues = _venues;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _localSearchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _localSearchQuery = '');
            },
          ),
          const SizedBox(height: 16),
          if (_loadingEvents)
            const SizedBox(
              height: 238,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
              ),
            )
          else
            _GoogleMapPreview(
              totalEvents: visibleEvents.length,
              venues: venues,
              userLocation: _locationReady ? _mapCenter : null,
              center: _mapCenter,
              onVenueTap: _openVenue,
            ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Trending Artists',
            action: 'VIEW ALL',
            onActionTap: _openTrendingArtists,
          ),
          const SizedBox(height: 12),
          _TrendingArtistStrip(
            artists: visibleArtists,
            isLoading: _loadingArtists,
            onArtistTap: _openArtistProfile,
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Browse by Location',
            action: '',
            onActionTap: () {},
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 5
                  : constraints.maxWidth >= 760
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 3
                  : 2;
              if (_loadingEvents) {
                return const SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
                  ),
                );
              }
              if (venues.isEmpty) {
                return Text(
                  normalizeSearchText(_effectiveSearchQuery).isEmpty
                      ? 'No venues found yet'
                      : 'No venues match your search',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: venues.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: constraints.maxWidth >= 760 ? 190 : 170,
                ),
                itemBuilder: (context, index) {
                  final venue = venues[index];
                  return _VenueTile(
                    venue: venue,
                    featured: index == 0,
                    onTap: () => _openVenue(venue),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEventCard(NearbyEvent event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(event.image, 72, 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.artistName.isEmpty ? 'Event' : event.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white24,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path, double w, double h) {
    if (path.isEmpty) {
      return Container(
        width: w,
        height: h,
        color: const Color(0xFF1E142A),
        child: const Icon(Icons.music_note, color: Colors.white24),
      );
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImage('', w, h),
      );
    }
    if (path.startsWith('data:image')) {
      try {
        final base64Str = path.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, width: w, height: h, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildImage('', w, h));
      } catch (_) {
        return _buildImage('', w, h);
      }
    }
    return Image.asset(
      path,
      width: w,
      height: h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImage('', w, h),
    );
  }

  void _openTrendingArtists() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventraSubpageShell(
          currentIndex: 1,
          child: const Scaffold(
            backgroundColor: Color(0xFF0E0717),
            body: SafeArea(child: TrendingArtistsPage()),
          ),
        ),
      ),
    );
  }

  void _openArtistProfile(Map<String, dynamic> artist) {
    final rawImageUrl = (artist['imageUrl'] ?? artist['avatar_url'] ?? '')
        .toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventraSubpageShell(
          currentIndex: 1,
          child: ArtistProfilePage(
            artistData: {
              ...artist,
              'imageUrl': rawImageUrl,
              'followers': artist['followers'],
              'upcomingEvents': artist['upcomingEvents'] ?? [],
            },
          ),
        ),
      ),
    );
  }

  void _openVenue(_ExploreVenue venue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventraSubpageShell(
          currentIndex: 1,
          child: _VenueProfilePage(venue: venue),
        ),
      ),
    );
  }
}

// ── Google Map Preview ────────────────────────────────────────────────────────

class _GoogleMapPreview extends StatefulWidget {
  const _GoogleMapPreview({
    required this.totalEvents,
    required this.venues,
    required this.center,
    required this.onVenueTap,
    this.userLocation,
  });

  final int totalEvents;
  final List<_ExploreVenue> venues;
  final LatLng center;
  final LatLng? userLocation;
  final void Function(_ExploreVenue venue) onVenueTap;

  @override
  State<_GoogleMapPreview> createState() => _GoogleMapPreviewState();
}

class _GoogleMapPreviewState extends State<_GoogleMapPreview> {
  final Completer<GoogleMapController> _controller = Completer();
  _ExploreVenue? _selectedVenue;

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // User location marker
    if (widget.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: widget.userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Venue markers
    for (final venue in widget.venues) {
      if (venue.lat == null || venue.lng == null) continue;
      markers.add(
        Marker(
          markerId: MarkerId(venue.name),
          position: LatLng(venue.lat!, venue.lng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(200),
          infoWindow: InfoWindow(
            title: venue.name,
            snippet:
                '${venue.events} upcoming events · from ${venue.startingPrice}',
          ),
          onTap: () => setState(() => _selectedVenue = venue),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebMapPreview(
        totalEvents: widget.totalEvents,
        venues: widget.venues,
        userLocation: widget.userLocation,
        center: widget.center,
        onVenueTap: widget.onVenueTap,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth >= 900
            ? 340.0
            : constraints.maxWidth >= 620
            ? 300.0
            : 260.0;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
            // ── Google Map ──────────────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.center,
                zoom: 12.5,
              ),
              markers: _markers,
              myLocationEnabled: widget.userLocation != null,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              style: _darkMapStyle,
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
              onTap: (_) => setState(() => _selectedVenue = null),
            ),

            // ── Map controls (custom) ───────────────────────────────────────
            Positioned(
              top: 14,
              right: 12,
              child: Column(
                children: [
                  _MapControl(
                    icon: Icons.my_location,
                    onTap: _goToUserLocation,
                  ),
                  const SizedBox(height: 8),
                  _MapControl(icon: Icons.add, onTap: _zoomIn),
                  const SizedBox(height: 8),
                  _MapControl(icon: Icons.remove, onTap: _zoomOut),
                ],
              ),
            ),

            // ── Bottom info card ────────────────────────────────────────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _selectedVenue != null
                  ? _VenueInfoCard(
                      venue: _selectedVenue!,
                      onTap: () => widget.onVenueTap(_selectedVenue!),
                    )
                  : _EventsCountCard(
                      totalEvents: widget.totalEvents,
                      city: widget.venues.isNotEmpty
                          ? widget.venues.first.city
                          : 'Jakarta',
                    ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _goToUserLocation() async {
    final ctrl = await _controller.future;
    final target = widget.userLocation ?? widget.center;
    await ctrl.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 13)),
    );
  }

  Future<void> _zoomIn() async {
    final ctrl = await _controller.future;
    await ctrl.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final ctrl = await _controller.future;
    await ctrl.animateCamera(CameraUpdate.zoomOut());
  }
}

class _WebMapPreview extends StatefulWidget {
  const _WebMapPreview({
    required this.totalEvents,
    required this.venues,
    required this.center,
    required this.onVenueTap,
    this.userLocation,
  });

  final int totalEvents;
  final List<_ExploreVenue> venues;
  final LatLng center;
  final LatLng? userLocation;
  final void Function(_ExploreVenue venue) onVenueTap;

  @override
  State<_WebMapPreview> createState() => _WebMapPreviewState();
}

class _WebMapPreviewState extends State<_WebMapPreview> {
  _ExploreVenue? _selectedVenue;
  int _zoomLevel = 0;
  LatLng? _focus;

  void _selectVenue(_ExploreVenue venue) {
    setState(() {
      _selectedVenue = venue;
      if (venue.lat != null && venue.lng != null) {
        _focus = LatLng(venue.lat!, venue.lng!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth >= 900
            ? 340.0
            : constraints.maxWidth >= 620
            ? 300.0
            : 260.0;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _WebMapCanvas(
                  venues: widget.venues,
                  userLocation: widget.userLocation,
                  center: widget.center,
                  selectedVenue: _selectedVenue,
                  zoomLevel: _zoomLevel,
                  focus: _focus,
                  onVenueTap: _selectVenue,
                  onMapTap: () => setState(() => _selectedVenue = null),
                ),
                Positioned(
                  top: 14,
                  right: 12,
                  child: Column(
                    children: [
                      _MapControl(
                        icon: Icons.my_location,
                        onTap: () {
                          setState(() {
                            _selectedVenue = null;
                            _focus = widget.userLocation ?? widget.center;
                            _zoomLevel = 1;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _MapControl(
                        icon: Icons.add,
                        onTap: () => setState(
                          () => _zoomLevel = (_zoomLevel + 1).clamp(-2, 3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MapControl(
                        icon: Icons.remove,
                        onTap: () => setState(
                          () => _zoomLevel = (_zoomLevel - 1).clamp(-2, 3),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: _selectedVenue != null
                      ? _VenueInfoCard(
                          venue: _selectedVenue!,
                          onTap: () => widget.onVenueTap(_selectedVenue!),
                        )
                      : _EventsCountCard(
                          totalEvents: widget.totalEvents,
                          city: widget.venues.isNotEmpty
                              ? widget.venues.first.city
                              : 'Jakarta',
                        ),
                ),
                Positioned(
                  right: 12,
                  bottom: height >= 300 ? 92 : 84,
                  child: _MapBadge(text: 'Zoom ${_zoomLevel + 3}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WebMapCanvas extends StatelessWidget {
  const _WebMapCanvas({
    required this.venues,
    required this.center,
    required this.selectedVenue,
    required this.zoomLevel,
    required this.onVenueTap,
    required this.onMapTap,
    this.userLocation,
    this.focus,
  });

  final List<_ExploreVenue> venues;
  final LatLng center;
  final LatLng? userLocation;
  final _ExploreVenue? selectedVenue;
  final int zoomLevel;
  final LatLng? focus;
  final void Function(_ExploreVenue venue) onVenueTap;
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    final points = venues
        .where((venue) => venue.lat != null && venue.lng != null)
        .toList();
    final coordinates = [
      for (final venue in points) LatLng(venue.lat!, venue.lng!),
      if (userLocation != null) userLocation!,
      if (points.isEmpty) center,
    ];

    final rawMinLat = coordinates
        .map((point) => point.latitude)
        .reduce((a, b) => a < b ? a : b);
    final rawMaxLat = coordinates
        .map((point) => point.latitude)
        .reduce((a, b) => a > b ? a : b);
    final rawMinLng = coordinates
        .map((point) => point.longitude)
        .reduce((a, b) => a < b ? a : b);
    final rawMaxLng = coordinates
        .map((point) => point.longitude)
        .reduce((a, b) => a > b ? a : b);

    final zoomMultiplier = switch (zoomLevel) {
      <= -2 => 2.2,
      -1 => 1.55,
      0 => 1.0,
      1 => 0.68,
      2 => 0.46,
      _ => 0.32,
    };

    final focusPoint = focus ??
        (selectedVenue?.lat != null && selectedVenue?.lng != null
            ? LatLng(selectedVenue!.lat!, selectedVenue!.lng!)
            : LatLng(
                (rawMinLat + rawMaxLat) / 2,
                (rawMinLng + rawMaxLng) / 2,
              ));
    final rawLatSpan = (rawMaxLat - rawMinLat).abs() < 0.0001
        ? 0.04
        : rawMaxLat - rawMinLat;
    final rawLngSpan = (rawMaxLng - rawMinLng).abs() < 0.0001
        ? 0.04
        : rawMaxLng - rawMinLng;
    final latSpan = rawLatSpan * zoomMultiplier;
    final lngSpan = rawLngSpan * zoomMultiplier;
    final minLat = focusPoint.latitude - latSpan / 2;
    final maxLat = focusPoint.latitude + latSpan / 2;
    final minLng = focusPoint.longitude - lngSpan / 2;
    final maxLng = focusPoint.longitude + lngSpan / 2;

    Offset positionFor(LatLng point, Size size) {
      final x = ((point.longitude - minLng) / lngSpan).clamp(0.0, 1.0);
      final y = (1 - ((point.latitude - minLat) / latSpan)).clamp(0.0, 1.0);
      return Offset(34 + x * (size.width - 68), 32 + y * (size.height - 82));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMapTap,
              child: CustomPaint(painter: _WebMapPainter()),
            ),
            if (userLocation != null)
              _PositionedMapPin(
                position: positionFor(userLocation!, size),
                child: _MapPin(
                  icon: Icons.person_pin_circle,
                  color: const Color(0xFFD0BCFF),
                  selected: false,
                  onTap: () {},
                ),
              ),
            for (var i = 0; i < points.length; i++)
              _PositionedMapPin(
                position: positionFor(
                  LatLng(points[i].lat!, points[i].lng!),
                  size,
                ),
                child: _MapPin(
                  label: '${i + 1}',
                  color: const Color(0xFF56C7FF),
                  selected: selectedVenue?.name == points[i].name,
                  onTap: () => onVenueTap(points[i]),
                ),
              ),
            const Positioned(
              top: 12,
              left: 12,
              child: _MapBadge(text: 'Web map preview'),
            ),
          ],
        );
      },
    );
  }
}

class _PositionedMapPin extends StatelessWidget {
  const _PositionedMapPin({required this.position, required this.child});

  final Offset position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 17,
      top: position.dy - 34,
      child: child,
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.selected,
    required this.onTap,
    this.label,
    this.icon,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: selected ? 42 : 34,
        height: selected ? 42 : 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: selected ? 3 : 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: selected ? 0.44 : 0.28),
              blurRadius: selected ? 20 : 12,
              spreadRadius: selected ? 4 : 1,
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: const Color(0xFF170E22), size: 19)
              : Text(
                  label ?? '',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF170E22),
                    fontSize: selected ? 14 : 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF211A27).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WebMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF171225),
    );

    final districtPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF211A34);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-30, 24, size.width * 0.72, size.height * 0.46),
        const Radius.circular(42),
      ),
      districtPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.28,
          size.width * 0.76,
          size.height * 0.5,
        ),
        const Radius.circular(46),
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF1D1830),
    );

    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF3C3456);
    final accentRoadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5B4E80);

    final mainRoad = Path()
      ..moveTo(-10, size.height * 0.72)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.52,
        size.width * 0.52,
        size.height * 0.82,
        size.width + 18,
        size.height * 0.58,
      );
    canvas.drawPath(mainRoad, roadPaint);

    final crossRoad = Path()
      ..moveTo(size.width * 0.12, -8)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.3,
        size.width * 0.22,
        size.height * 0.62,
        size.width * 0.45,
        size.height + 8,
      );
    canvas.drawPath(crossRoad, accentRoadPaint);

    final river = Path()
      ..moveTo(size.width * 0.7, -12)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.22,
        size.width * 0.86,
        size.height * 0.38,
        size.width * 0.76,
        size.height + 10,
      );
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF10233D).withValues(alpha: 0.78),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Map bottom cards ──────────────────────────────────────────────────────────

class _EventsCountCard extends StatelessWidget {
  const _EventsCountCard({required this.totalEvents, required this.city});

  final int totalEvents;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF211A27).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD0BCFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.explore,
              color: Color(0xFF4D2B6C),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalEvents Events Nearby',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'From $city and nearby live venues',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueInfoCard extends StatelessWidget {
  const _VenueInfoCard({required this.venue, required this.onTap});

  final _ExploreVenue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF211A27).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD0BCFF).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: _ExploreImage(path: venue.image),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${venue.events} events · from ${venue.startingPrice}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD0BCFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map control button ────────────────────────────────────────────────────────

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF272034),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD0BCFF)),
        ),
        child: Icon(icon, color: const Color(0xFFD0BCFF), size: 15),
      ),
    );
  }
}

// ── Shared search field ───────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            cursorColor: const Color(0xFFD0BCFF),
            decoration: InputDecoration(
              hintText: 'Search events, artists, or venues',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white54,
                size: 18,
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: onClear,
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onActionTap,
  });

  final String title;
  final String action;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.05).toDouble();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26 * scale,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (action.isNotEmpty)
              TextButton(
                onPressed: onActionTap,
                child: Text(
                  action,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13 * scale,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Trending artist strip ─────────────────────────────────────────────────────

class _TrendingArtistStrip extends StatelessWidget {
  const _TrendingArtistStrip({
    required this.artists,
    required this.isLoading,
    required this.onArtistTap,
  });

  final List<Map<String, dynamic>> artists;
  final bool isLoading;
  final void Function(Map<String, dynamic> artist) onArtistTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 66,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
        ),
      );
    }

    if (artists.isEmpty) {
      return Text(
        'No trending artists yet',
        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 620;
        final itemWidth = 58.0;
        final gap = 12.0;
        final desktopCount = artists.length < 5
            ? artists.length
            : ((constraints.maxWidth + gap) / (itemWidth + gap))
                  .floor()
                  .clamp(5, artists.length)
                  .toInt();
        final visibleArtists = artists
            .take(isMobile ? 5 : desktopCount)
            .toList();

        return SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: visibleArtists.length,
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final artist = visibleArtists[index];
              final name = artist['name']?.toString() ?? 'Artist';
              final image = (artist['imageUrl'] ?? artist['avatar_url'] ?? '')
                  .toString();

              return GestureDetector(
                onTap: () => onArtistTap(artist),
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD0BCFF),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(child: _ExploreImage(path: image)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Venue tile (grid) ─────────────────────────────────────────────────────────

class _VenueTile extends StatelessWidget {
  const _VenueTile({
    required this.venue,
    required this.featured,
    required this.onTap,
  });

  final _ExploreVenue venue;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _ExploreCardBackground(
        borderColor: featured
            ? const Color(0xFFD0BCFF)
            : Colors.white.withValues(alpha: 0.12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ExploreImage(path: venue.image),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExploreVenueCardTitle(venue.name),
                  const SizedBox(height: 4),
                  _ExploreVenueCardSubtitle(
                    '${venue.events} upcoming concerts',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Venue profile page ────────────────────────────────────────────────────────

class _VenueProfilePage extends StatefulWidget {
  const _VenueProfilePage({required this.venue});

  final _ExploreVenue venue;

  @override
  State<_VenueProfilePage> createState() => _VenueProfilePageState();
}

class _VenueProfilePageState extends State<_VenueProfilePage> {
  void _openEvent(NearbyEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventraSubpageShell(
          currentIndex: 1,
          child: BuyTicketPage(
            event: event,
            onBack: () => Navigator.pop(context),
            onCheckout: (event, tickets) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventraSubpageShell(
                    currentIndex: 1,
                    child: PaymentPage(
                      event: event,
                      tickets: tickets,
                      onBack: () => Navigator.pop(context),
                      onPaymentComplete: (payment) {
                        TicketsNotifier.instance.notify();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventraSubpageShell(
                              currentIndex: 2,
                              child: PaymentStatusPage(
                                payment: payment,
                                onViewTickets: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const EventraSubpageShell(
                                            currentIndex: 2,
                                            child: EventraTicketsPage(),
                                          ),
                                    ),
                                  );
                                },
                                onBackHome: () {
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;
    final upcomingEvents = venue.upcomingEvents;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16111F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EVENTRA',
          style: GoogleFonts.poppins(
            color: const Color(0xFFD0BCFF),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue hero image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ExploreImage(path: venue.image),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.76),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _ExploreBadge(text: 'MUST VISIT VENUE'),
                          const SizedBox(height: 8),
                          Text(
                            venue.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ExploreBodyText(venue.description, maxLines: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Small map showing venue location
            if (venue.lat != null && venue.lng != null) ...[
              _VenueLocationMap(
                name: venue.name,
                position: LatLng(venue.lat!, venue.lng!),
                city: venue.city,
              ),
              const SizedBox(height: 12),
            ],

            _VenueSection(
              title: 'LOCATION',
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFD0BCFF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _ExploreBodyText('${venue.city}, Indonesia')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _VenueSection(
              title: 'ABOUT VENUE',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExploreBodyText(venue.description),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _VenueStat(
                          value: venue.startingPrice,
                          label: 'START FROM',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VenueStat(
                          value: venue.events,
                          label: 'UPCOMING EVENTS',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _ExploreSectionTitle('Upcoming Events'),
            const SizedBox(height: 12),
            if (upcomingEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'There is no upcoming events',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingEvents.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (context, index) {
                  final event = upcomingEvents[index];
                  return EventraEventCard(
                    image: event.image,
                    dateLabel: _formatDate(event.dateLabel),
                    title: event.title,
                    subtitle: event.artistName.isEmpty
                        ? widget.venue.name
                        : event.artistName,
                    venueLabel: '${event.place}, ${event.city}',
                    isFavorite: event.isFavorite,
                    onTap: () => _openEvent(event),
                    onActionTap: () => _openEvent(event),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return 'TBA';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}';
  }
}

// ── Venue location mini-map ───────────────────────────────────────────────────

class _VenueLocationMap extends StatefulWidget {
  const _VenueLocationMap({
    required this.name,
    required this.position,
    required this.city,
  });

  final String name;
  final LatLng position;
  final String city;

  @override
  State<_VenueLocationMap> createState() => _VenueLocationMapState();
}

class _VenueLocationMapState extends State<_VenueLocationMap> {
  final Completer<GoogleMapController> _ctrl = Completer();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebVenueLocationMap(
        name: widget.name,
        city: widget.city,
        position: widget.position,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.position,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(widget.name),
                  position: widget.position,
                  infoWindow: InfoWindow(title: widget.name),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              style: _darkMapStyle,
              onMapCreated: (ctrl) {
                _ctrl.complete(ctrl);
              },
            ),
            // Subtle gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFD0BCFF),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.name}, ${widget.city}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebVenueLocationMap extends StatelessWidget {
  const _WebVenueLocationMap({
    required this.name,
    required this.city,
    required this.position,
  });

  final String name;
  final String city;
  final LatLng position;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _WebMapPainter()),
            Center(
              child: _MapPin(
                icon: Icons.location_on,
                color: const Color(0xFF56C7FF),
                selected: true,
                onTap: () {},
              ),
            ),
            const Positioned(
              top: 12,
              left: 12,
              child: _MapBadge(text: 'Venue location'),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFD0BCFF),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$name, $city',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable small widgets ────────────────────────────────────────────────────

class _ExploreSectionTitle extends StatelessWidget {
  const _ExploreSectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.05).toDouble();
        return Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26 * scale,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

class _ExploreBodyText extends StatelessWidget {
  const _ExploreBodyText(this.text, {this.maxLines});
  final String text;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ExplorePanelTitle extends StatelessWidget {
  const _ExplorePanelTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ExploreCardShell extends StatelessWidget {
  const _ExploreCardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _ExploreVenueCardTitle extends StatelessWidget {
  const _ExploreVenueCardTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        height: 1.12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ExploreVenueCardSubtitle extends StatelessWidget {
  const _ExploreVenueCardSubtitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 13,
        height: 1.18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ExploreBadge extends StatelessWidget {
  const _ExploreBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ExploreCardBackground extends StatelessWidget {
  const _ExploreCardBackground({
    required this.child,
    this.borderColor = Colors.white10,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23172F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _VenueSection extends StatelessWidget {
  const _VenueSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ExploreCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExplorePanelTitle(title),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _VenueStat extends StatelessWidget {
  const _VenueStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF241A31),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreImage extends StatelessWidget {
  const _ExploreImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (path.startsWith('data:image')) {
      try {
        final base64Str = path.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      } catch (_) {
        return _fallback();
      }
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF2A2035),
      child: const Icon(Icons.music_note, color: Colors.white24),
    );
  }
}
