import 'package:eventra/data/app_config.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/favorites_notifier.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraFavoritesPage extends StatefulWidget {
  const EventraFavoritesPage({
    super.key,
    required this.controller,
    required this.onEventTap,
  });

  final HomeController controller;
  final void Function(NearbyEvent) onEventTap;

  @override
  State<EventraFavoritesPage> createState() => _EventraFavoritesPageState();
}

class _EventraFavoritesPageState extends State<EventraFavoritesPage> {
  List<NearbyEvent> favoriteEvents = [];
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
  void dispose() {
    FavoritesNotifier.instance.removeListener(_loadFavorites);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final loadedEvents = await EventraDatabase.instance.fetchNearbyEvents();

    if (!mounted) return;

    setState(() {
      favoriteEvents = loadedEvents
          .map(NearbyEvent.fromJson)
          .where((event) => event.isFavorite)
          .toList();
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
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
                if (favoriteEvents.isEmpty)
                  _buildEmptyState()
                else ...[
                  Text(
                    '${favoriteEvents.length} saved events',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFavoritesGrid(),
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
                  'Your saved events, ready when tickets open.',
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
              'Your saved passes and events will appear here.',
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
            'Tap the heart on any event to keep it here.',
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

  Widget _buildFavoritesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favoriteEvents.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        mainAxisExtent: 340,
      ),
      itemBuilder: (context, index) {
        return Center(child: _favoriteEventCard(favoriteEvents[index]));
      },
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
}
