import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/core/utils/search_match.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/explore/artists/artists_profile.dart';
import 'package:eventra/features/ticket/buy_ticket_page.dart';
import 'package:eventra/features/ticket/payment_page.dart';
import 'package:eventra/features/ticket/payment_status_page.dart';
import 'package:eventra/data/tickets_notifier.dart';
import 'package:eventra/features/ticket/my_tickets.dart';
import 'package:eventra/data/favorites_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.query});

  final String query;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late String _currentQuery;
  bool _isLoading = true;
  
  dynamic _topResult;
  List<dynamic> _otherResults = [];

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.query;
    _searchController = TextEditingController(text: _currentQuery);
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_currentQuery.trim().isEmpty) {
      setState(() {
        _topResult = null;
        _otherResults = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final artistsData = await EventraDatabase.instance.fetchTrendingArtists();
      final eventsData = await EventraDatabase.instance.fetchNearbyEvents(location: '');
      
      final allEvents = eventsData.map(NearbyEvent.fromJson).toList();

      // Score Artists: Focus only on Name and Genre as requested
      final List<Map<String, dynamic>> scoredArtists = artistsData.map((a) {
        final score = searchMatchScore(_currentQuery, [
          a['name'],
          a['genre'],
        ]);
        return {...a, '_score': score, '_type': 'artist'};
      }).where((a) => (a['_score'] as int) > 0).toList();

      // Score Events: Focus on Title and Place (Venue/City)
      final List<Map<String, dynamic>> scoredEvents = allEvents.map((e) {
        final score = searchMatchScore(_currentQuery, [
          e.title,
          e.place,
          e.city,
        ]);
        return {'data': e, '_score': score, '_type': 'event'};
      }).where((e) => (e['_score'] as int) > 0).toList();

      // Determine which events are already shown inside artist cards
      // Only absorb if the query matches the artist's name (strong primary match)
      final Set<int> displayedEventIds = {};
      for (final artist in scoredArtists) {
        final artistName = artist['name']?.toString() ?? '';
        final nameScore = searchMatchScore(_currentQuery, [artistName]);
        
        // If the query matches the artist name specifically, we hide their events to avoid redundancy
        if (nameScore >= 65) { // Exact, startsWith, or word match
          final upcoming = artist['upcomingEvents'] as List? ?? [];
          for (final eMap in upcoming) {
            displayedEventIds.add(_asInt(eMap['event_id'] ?? eMap['id']));
          }
        }
      }

      // Filter events to exclude duplicates only if they were "absorbed"
      final List<Map<String, dynamic>> uniqueEvents = scoredEvents.where((e) {
        final event = e['data'] as NearbyEvent;
        return !displayedEventIds.contains(event.id);
      }).toList();

      // Combine and Sort
      final allResults = [...scoredArtists, ...uniqueEvents];
      
      if (allResults.isNotEmpty) {
        allResults.sort((a, b) {
          final scoreA = a['_score'] as int;
          final scoreB = b['_score'] as int;
          
          if (scoreB != scoreA) {
            return scoreB.compareTo(scoreA);
          }

          // Primary names
          final nameA = normalizeSearchText(a['_type'] == 'artist' ? a['name'] : (a['data'] as NearbyEvent).title);
          final nameB = normalizeSearchText(b['_type'] == 'artist' ? b['name'] : (b['data'] as NearbyEvent).title);
          
          final query = _currentQuery.toLowerCase().trim();
          final startsA = nameA.startsWith(query);
          final startsB = nameB.startsWith(query);
          
          if (startsA && !startsB) return -1;
          if (!startsA && startsB) return 1;

          // If scores are equal and startsWith is same, prioritize events for specific title matches
          if (a['_type'] == 'event' && b['_type'] == 'artist') {
            final event = a['data'] as NearbyEvent;
            if (normalizeSearchText(event.title).contains(query)) return -1;
          }
          
          // Default to artist priority for tied general matches
          if (a['_type'] == 'artist' && b['_type'] != 'artist') return -1;
          if (a['_type'] != 'artist' && b['_type'] == 'artist') return 1;
          
          return 0;
        });
        
        _topResult = allResults.first;
        _otherResults = allResults.skip(1).toList();
      } else {
        _topResult = null;
        _otherResults = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(NearbyEvent event) async {
    final nextStatus = !event.isFavorite;
    
    setState(() {
      // Update top result if it's an event
      if (_topResult != null && _topResult['_type'] == 'event' && (_topResult['data'] as NearbyEvent).id == event.id) {
        _topResult['data'] = (_topResult['data'] as NearbyEvent).copyWith(isFavorite: nextStatus);
      }
      
      // Update other results
      for (var i = 0; i < _otherResults.length; i++) {
        final res = _otherResults[i];
        if (res['_type'] == 'event' && (res['data'] as NearbyEvent).id == event.id) {
          _otherResults[i]['data'] = (res['data'] as NearbyEvent).copyWith(isFavorite: nextStatus);
        }
        
        // Also update in artist's upcoming events list within cards
        if (res['_type'] == 'artist') {
          final upcoming = List<Map<String, dynamic>>.from(res['upcomingEvents'] ?? []);
          for (var j = 0; j < upcoming.length; j++) {
            final eId = _asInt(upcoming[j]['event_id'] ?? upcoming[j]['id']);
            if (eId == event.id) {
              upcoming[j]['is_favorite'] = nextStatus;
            }
          }
          _otherResults[i]['upcomingEvents'] = upcoming;
        }
      }

      // Update in top result artist's upcoming events if applicable
      if (_topResult != null && _topResult['_type'] == 'artist') {
        final upcoming = List<Map<String, dynamic>>.from(_topResult['upcomingEvents'] ?? []);
        for (var i = 0; i < upcoming.length; i++) {
          final eId = _asInt(upcoming[i]['event_id'] ?? upcoming[i]['id']);
          if (eId == event.id) {
            upcoming[i]['is_favorite'] = nextStatus;
          }
        }
        _topResult['upcomingEvents'] = upcoming;
      }
    });

    try {
      await EventraDatabase.instance.setNearbyFavorite(
        eventId: event.id,
        isFavorite: nextStatus,
      );
      FavoritesNotifier.instance.notify();
    } catch (e) {
      _toggleFavorite(event.copyWith(isFavorite: nextStatus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
                    : _buildResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1526),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                onSubmitted: (value) {
                  setState(() {
                    _currentQuery = value;
                  });
                  _performSearch();
                },
                decoration: InputDecoration(
                  hintText: 'Search again...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_topResult == null) {
      return Center(
        child: Text(
          'No results found',
          style: GoogleFonts.poppins(color: Colors.white54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Top Result',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildResultCard(_topResult, isTop: true),
        
        if (_otherResults.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(
            'Other Results',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._otherResults.map((res) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildResultCard(res, isTop: false),
          )),
        ],
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildResultCard(dynamic result, {required bool isTop}) {
    final isArtist = result['_type'] == 'artist';
    
    if (isArtist) {
      final name = result['name'] ?? 'Unknown Artist';
      final imageUrl = result['imageUrl'] ?? result['avatar_url'] ?? '';
      final genre = result['genre'] ?? '';
      final upcomingEvents = (result['upcomingEvents'] as List? ?? []);

      return Container(
        padding: EdgeInsets.all(isTop ? 16 : 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1526),
          borderRadius: BorderRadius.circular(isTop ? 20 : 16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isTop ? 40 : 28,
                  backgroundImage: _getImageProvider(imageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isTop ? 24 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Artist • $genre',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD0BCFF),
                          fontSize: isTop ? 14 : 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: isTop ? 16 : 12),
                  onPressed: () => _openArtistProfile(result),
                ),
              ],
            ),
            if (upcomingEvents.isNotEmpty) ...[
              SizedBox(height: isTop ? 20 : 12),
              Text(
                'Events by $name',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isTop ? 16 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: isTop ? 295 : 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: upcomingEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final eventMap = upcomingEvents[index];
                    final event = NearbyEvent(
                      id: _asInt(eventMap['event_id'] ?? eventMap['id']),
                      title: eventMap['title']?.toString() ?? '',
                      dateLabel: eventMap['date_label']?.toString() ?? '',
                      place: eventMap['venue']?.toString() ?? '',
                      city: eventMap['city']?.toString() ?? '',
                      artistName: eventMap['lineup']?.toString() ?? name,
                      price: eventMap['price']?.toString() ?? '',
                      image: eventMap['image']?.toString() ?? '',
                      isFavorite: _asBool(eventMap['is_favorite']),
                      sortOrder: _asInt(eventMap['sort_order']),
                    );
                    return SizedBox(
                      width: isTop ? 260 : 180,
                      child: EventraEventCard(
                        image: event.image,
                        dateLabel: event.dateLabel,
                        title: event.title,
                        subtitle: event.artistName,
                        venueLabel: '${event.place}, ${event.city}',
                        isFavorite: event.isFavorite,
                        compact: true,
                        onTap: () => _openEvent(event),
                        onActionTap: () => _openEvent(event),
                        onFavoriteTap: () => _toggleFavorite(event),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      final event = result['data'] as NearbyEvent;
      if (!isTop) {
        // More compact version for non-top results
        return GestureDetector(
          onTap: () => _openEvent(event),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1526),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    image: _getImageProvider(event.image),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Event • ${event.artistName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD0BCFF),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white54, size: 11),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${event.place}, ${event.city}',
                              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    event.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFFD0BCFF),
                    size: 20,
                  ),
                  onPressed: () => _toggleFavorite(event),
                ),
              ],
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: () => _openEvent(event),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1526),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: _getImageProvider(event.image),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Event • ${event.artistName}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD0BCFF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      event.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFD0BCFF),
                      size: 28,
                    ),
                    onPressed: () => _toggleFavorite(event),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${event.place}, ${event.city}',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('assets/')) return AssetImage(path);
    return const AssetImage('assets/images/image1.jpeg'); // Fallback
  }

  void _openArtistProfile(Map<String, dynamic> artist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventraSubpageShell(
          currentIndex: 1,
          child: ArtistProfilePage(artistData: artist),
        ),
      ),
    );
  }

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
                                      builder: (context) => EventraSubpageShell(
                                        currentIndex: 2,
                                        child: EventraTicketsPage(),
                                      ),
                                    ),
                                  );
                                },
                                onBackHome: () {
                                  Navigator.popUntil(context, (route) => route.isFirst);
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

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true';
  }
}
