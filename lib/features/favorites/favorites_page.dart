import 'package:eventra/data/app_config.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/core/utils/search_match.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/favorites_notifier.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';
import 'package:eventra/features/explore/artists/artists_profile.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraFavoritesPage extends StatefulWidget {
  const EventraFavoritesPage({
    super.key,
    required this.controller,
    required this.onEventTap,
    this.searchQuery = '',
  });

  final HomeController controller;
  final void Function(NearbyEvent) onEventTap;
  final String searchQuery;

  @override
  State<EventraFavoritesPage> createState() => _EventraFavoritesPageState();
}

class _EventraFavoritesPageState extends State<EventraFavoritesPage> {
  List<NearbyEvent> favoriteEvents = [];
  List<Map<String, dynamic>> favoriteArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();

    // Dengarkan sinyal dari HomeController setiap kali ada toggle favorit
    // → auto reload tanpa user harus pull-to-refresh manual
    FavoritesNotifier.instance.addListener(_loadFavorites);
  }

  @override
  void didUpdateWidget(covariant EventraFavoritesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFavorites();
  }

  @override
  void dispose() {
    FavoritesNotifier.instance.removeListener(_loadFavorites);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final loadedFavorites = await EventraDatabase.instance.fetchFavorites();

      if (!mounted) return;

      setState(() {
        favoriteEvents = loadedFavorites
            .where((item) => item['type']?.toString() == 'event')
            .map(
              (item) => NearbyEvent.fromJson(item).copyWith(isFavorite: true),
            )
            .toList();
        favoriteArtists = loadedFavorites
            .where((item) => item['type']?.toString() == 'artist')
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      final loadedEvents = await EventraDatabase.instance.fetchNearbyEvents();

      if (!mounted) return;

      setState(() {
        favoriteEvents = loadedEvents
            .map(NearbyEvent.fromJson)
            .where((event) => event.isFavorite)
            .toList();
        favoriteArtists = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(NearbyEvent event) async {
    final previousFavorites = List<NearbyEvent>.from(favoriteEvents);
    setState(() {
      favoriteEvents = favoriteEvents
          .where((item) => item.id != event.id)
          .toList();
    });

    try {
      await widget.controller.setFavoriteByType(
        type: 'event',
        id: event.id,
        isFavorite: false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        favoriteEvents = previousFavorites;
      });
    }
  }

  Future<void> _removeArtist(Map<String, dynamic> artist) async {
    final previousArtists = List<Map<String, dynamic>>.from(favoriteArtists);
    final id = int.tryParse(artist['id']?.toString() ?? '') ?? 0;
    setState(() {
      favoriteArtists = favoriteArtists
          .where((item) => item['id']?.toString() != artist['id']?.toString())
          .toList();
    });

    try {
      await EventraDatabase.instance.setArtistFavorite(
        artistId: id,
        isFavorite: false,
      );
      FavoritesNotifier.instance.notify();
    } catch (_) {
      if (!mounted) return;
      setState(() => favoriteArtists = previousArtists);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFavorites = favoriteEvents
        .where(
          (event) => matchesSearchQuery(widget.searchQuery, [
            event.title,
            event.artistName,
            event.place,
            event.city,
            event.dateLabel,
            event.price,
          ]),
        )
        .toList();
    final filteredArtists = favoriteArtists
        .where(
          (artist) => matchesSearchQuery(widget.searchQuery, [
            artist['title'],
            artist['subtitle'],
            artist['genre'],
            artist['description'],
          ]),
        )
        .toList();
    final totalFavorites = filteredFavorites.length + filteredArtists.length;
    final hasAnyFavorites =
        favoriteEvents.isNotEmpty || favoriteArtists.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFFD0BCFF),
      backgroundColor: const Color(0xFF1B1526),
      onRefresh: _loadFavorites,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              children: [
                _buildHeader(),
                const SizedBox(height: 22),
                if (!hasAnyFavorites)
                  _buildEmptyState()
                else if (totalFavorites == 0)
                  _buildSearchEmptyState()
                else ...[
                  Text(
                    '$totalFavorites saved items',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionTitle('Favorite Artists'),
                  _buildArtistsStrip(filteredArtists),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Favorite Events'),
                  _buildFavoritesGrid(filteredFavorites),
                ],
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFD0BCFF),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.instance.text('favorites.title', 'Favorites'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your saved artists and events, ready when tickets open.',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            color: Color(0xFFD0BCFF),
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            AppConfig.instance.text(
              'favorites.empty',
              'Your saved artists and events will appear here.',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart on any artist or event to keep it here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(List<NearbyEvent> events) {
    if (events.isEmpty) {
      return _sectionEmpty('No favorite events yet.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        mainAxisExtent: 340,
      ),
      itemBuilder: (context, index) {
        return Center(child: _favoriteEventCard(events[index]));
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildArtistsStrip(List<Map<String, dynamic>> artists) {
    if (artists.isEmpty) {
      return _sectionEmpty('No favorite artists yet.');
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _favoriteArtistCard(artists[index]),
      ),
    );
  }

  Widget _sectionEmpty(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: Color(0xFFD0BCFF), size: 38),
          const SizedBox(height: 12),
          Text(
            'No saved events match your search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteEventCard(NearbyEvent event) {
    return EventraEventCard(
      image: event.image,
      dateLabel: event.dateLabel,
      title: event.title,
      subtitle: event.artistName.isEmpty ? 'artist lineup' : event.artistName,
      venueLabel: '${event.place}, ${event.city}',
      isFavorite: true,
      onTap: () => widget.onEventTap(event),
      onFavoriteTap: () => _removeFavorite(event),
      onActionTap: () => widget.onEventTap(event),
    );
  }

  Widget _favoriteArtistCard(Map<String, dynamic> artist) {
    final image =
        artist['image']?.toString() ??
        artist['avatar_url']?.toString() ??
        '';

    final title =
        artist['title']?.toString() ??
        artist['name']?.toString() ??
        'Saved artist';

    final subtitle =
        artist['subtitle']?.toString() ??
        artist['genre']?.toString() ??
        '';

    return GestureDetector(
      onTap: () => _openArtistProfile(artist),
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1526),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // IMAGE
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFD0BCFF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: _artistImage(image),
            ),

            const SizedBox(width: 12),

            // TEXT AREA
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // HEART BUTTON
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 18,
              onPressed: () => _removeArtist(artist),
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFFD0BCFF),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openArtistProfile(Map<String, dynamic> artist) {
    final image =
        artist['image']?.toString() ?? artist['avatar_url']?.toString() ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventraSubpageShell(
          currentIndex: 3,
          child: ArtistProfilePage(
            artistData: {
              ...artist,
              'name': artist['title'] ?? artist['name'],
              'imageUrl': image,
              'followers': artist['followers'] ?? artist['followers_count'],
              'is_favorite': true,
              'upcomingEvents': artist['upcomingEvents'] ?? [],
            },
          ),
        ),
      ),
    );
  }

  Widget _artistImage(String image) {
    if (image.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(image, fit: BoxFit.cover),
      );
    }
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(image, fit: BoxFit.cover),
      );
    }
    return const Icon(Icons.person, color: Color(0xFFD0BCFF));
  }
}
