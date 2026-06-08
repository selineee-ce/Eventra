import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/features/explore/artists/trending_artists.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/ticket/buy_ticket_page.dart';
import 'package:eventra/features/ticket/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _artists = [];
  List<NearbyEvent> _events = [];
  bool _loadingArtists = true;
  bool _loadingEvents = true;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredArtists {
    if (_searchQuery.isEmpty) return _artists;
    final query = _searchQuery.toLowerCase();
    return _artists.where((artist) {
      final name = (artist['name'] as String? ?? '').toLowerCase();
      return name.contains(query);
    }).toList();
  }

  List<NearbyEvent> get _filteredEvents {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return _events.where((event) {
      final title = event.title.toLowerCase();
      final artist = event.artistName.toLowerCase();
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  List<_ExploreVenue> get _venues {
    final grouped = <String, List<NearbyEvent>>{};
    for (final event in _events) {
      final key =
          '${event.place.trim().toLowerCase()}|${event.city.trim().toLowerCase()}';
      grouped.putIfAbsent(key, () => []).add(event);
    }

    return grouped.values
        .map((events) {
          final first = events.first;
          return _ExploreVenue(
            name: first.place.isEmpty ? first.title : first.place,
            city: first.city,
            image: first.image,
            startingPrice: first.price.isEmpty ? '-' : first.price,
            events: events.length.toString(),
            description: _venueDescription(first, events.length),
            upcomingEvents: events,
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
    return '${event.place} hosts $eventCount upcoming Eventra ${eventCount == 1 ? 'event' : 'events'}, including $artist. Ticket categories and venue details follow the same event data used on the home page.';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty)
            _buildSearchResults()
          else ...[
            if (_loadingEvents)
              const SizedBox(
                height: 238,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
                ),
              )
            else if (_venues.isNotEmpty)
              _MapPreview(totalEvents: _events.length, venue: _venues.first),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Trending Artists',
              action: 'VIEW ALL',
              onActionTap: _openTrendingArtists,
            ),
            const SizedBox(height: 12),
            _TrendingArtistStrip(
              artists: _artists,
              isLoading: _loadingArtists,
              onArtistTap: _openTrendingArtists,
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
                final columns = constraints.maxWidth >= 520 ? 3 : 2;
                if (_loadingEvents) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
                    ),
                  );
                }

                if (_venues.isEmpty) {
                  return Text(
                    'No venues found yet',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _venues.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    mainAxisExtent: 170,
                  ),
                  itemBuilder: (context, index) {
                    final venue = _venues[index];
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
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final artists = _filteredArtists;
    final events = _filteredEvents;
    final hasResults = artists.isNotEmpty || events.isNotEmpty;

    if (!hasResults) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'Tidak ada hasil untuk "$_searchQuery"',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    final topArtist = artists.isNotEmpty ? artists.first : null;
    final topEvent = events.isNotEmpty ? events.first : null;
    
    // Spotify-like logic: prioritize artist if it starts with query
    final topResult = topArtist != null && topEvent != null
        ? (topArtist['name'].toString().toLowerCase().startsWith(_searchQuery.toLowerCase()) ? topArtist : topEvent)
        : topArtist ?? topEvent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topResult != null) ...[
          Text(
            'Top Result',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (topResult is Map<String, dynamic>)
            _buildFeaturedArtistCard(topResult)
          else
            _buildFeaturedEventCard(topResult as NearbyEvent),
          const SizedBox(height: 32),
        ],
        
        Text(
          'Artists & Events',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...artists.where((a) => a != topResult).map((artist) {
          final name = artist['name'] as String? ?? 'Unknown';
          final image = (artist['imageUrl'] ?? artist['image_url'] ?? '') as String;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCompactArtistCard(artist, name, image),
          );
        }),
        ...events.where((e) => e != topResult).map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCompactEventCard(event),
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedArtistCard(Map<String, dynamic> artist) {
    final name = artist['name'] as String? ?? 'Unknown Artist';
    final image = (artist['imageUrl'] ?? artist['image_url'] ?? '') as String;
    final upcomingEvents = (artist['upcomingEvents'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .take(3)
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D243F),
            const Color(0xFF1B1526),
          ],
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Side: Artist Info
            Container(
              width: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD0BCFF).withValues(alpha: 0.3), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: _buildImage(image, 90, 90),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0BCFF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Artist',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD0BCFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right Side: Events as mini-cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Events',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (upcomingEvents.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No events found',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      ...upcomingEvents.map((event) {
                        final title = event['title'] ?? event['lineup'] ?? 'Event';
                        final date = event['date_label'] ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD0BCFF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    date.split(' ').isNotEmpty ? date.split(' ')[0].substring(0, 3).toUpperCase() : '',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFD0BCFF),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      date,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedEventCard(NearbyEvent event) {
    // Find other events from the same artist to show next to it
    final moreEvents = _events
        .where((e) => e.artistName == event.artistName && e.id != event.id)
        .take(3)
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D243F),
            const Color(0xFF1B1526),
          ],
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Side: Main Event Info
            Container(
              width: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(event.image, 110, 110),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.artistName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD0BCFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Right Side: More from Artist as mini-cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'More from Artist',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (moreEvents.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No other events',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      ...moreEvents.map((e) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _buildImage(e.image, 32, 32),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      e.dateLabel,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactArtistCard(
    Map<String, dynamic> artist,
    String name,
    String image,
  ) {
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
            child: _buildImage(image, 72, 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                  'Artist',
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
        builder: (_) => const Scaffold(
          backgroundColor: Color(0xFF0E0717),
          body: SafeArea(child: TrendingArtistsPage()),
        ),
      ),
    );
  }

  void _openVenue(_ExploreVenue venue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _VenueProfilePage(venue: venue)),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search events, artists, or venues',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.totalEvents, required this.venue});

  final int totalEvents;
  final _ExploreVenue venue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _VenueProfilePage(venue: venue)),
        );
      },
      child: SizedBox(
        height: 238,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MapPainter()),
              Positioned(
                top: 18,
                right: 14,
                child: Column(
                  children: const [
                    _MapControl(icon: Icons.my_location),
                    SizedBox(height: 8),
                    _MapControl(icon: Icons.add),
                    SizedBox(height: 8),
                    _MapControl(icon: Icons.remove),
                  ],
                ),
              ),
              const Center(
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFF1F1B2D),
                  size: 72,
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Container(
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
                              'From ${venue.city} and nearby live venues',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF8D8A8E);
    canvas.drawRect(Offset.zero & size, background);

    final road = Paint()
      ..color = const Color(0xFFD4D2D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    final smallRoad = Paint()
      ..color = const Color(0xFFBDB9B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var i = -2; i < 8; i++) {
      final y = i * 46.0;
      canvas.drawLine(Offset(-20, y), Offset(size.width + 40, y + 80), road);
      canvas.drawLine(
        Offset(size.width + 20, y + 8),
        Offset(-40, y + 92),
        smallRoad,
      );
    }

    final block = Paint()..color = const Color(0xFF77747B);
    for (var x = 14.0; x < size.width; x += 64) {
      for (var y = 18.0; y < size.height; y += 58) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 42, 26),
            const Radius.circular(3),
          ),
          block,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF272034),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0BCFF)),
      ),
      child: Icon(icon, color: const Color(0xFFD0BCFF), size: 15),
    );
  }
}

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

class _TrendingArtistStrip extends StatelessWidget {
  const _TrendingArtistStrip({
    required this.artists,
    required this.isLoading,
    required this.onArtistTap,
  });

  final List<Map<String, dynamic>> artists;
  final bool isLoading;
  final VoidCallback onArtistTap;

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

    final visibleArtists = artists.take(5).toList();
    if (visibleArtists.isEmpty) {
      return Text(
        'No trending artists yet',
        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
      );
    }

    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: visibleArtists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final artist = visibleArtists[index];
          final name = artist['name']?.toString() ?? 'Artist';
          final image = (artist['imageUrl'] ?? artist['image_url'] ?? '')
              .toString();

          return GestureDetector(
            onTap: onArtistTap,
            child: SizedBox(
              width: 58,
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
  }
}

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
        builder: (_) => BuyTicketPage(
          event: event,
          onBack: () => Navigator.pop(context),
          onCheckout: (event, tickets) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  event: event,
                  tickets: tickets,
                  onBack: () => Navigator.pop(context),
                  onPaymentComplete: (payment) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment completed')),
                    );
                  },
                ),
              ),
            );
          },
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

class _ExploreVenue {
  const _ExploreVenue({
    required this.name,
    required this.city,
    required this.image,
    required this.startingPrice,
    required this.events,
    required this.description,
    required this.upcomingEvents,
  });

  final String name;
  final String city;
  final String image;
  final String startingPrice;
  final String events;
  final String description;
  final List<NearbyEvent> upcomingEvents;
}
