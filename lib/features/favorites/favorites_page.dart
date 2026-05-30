import 'package:eventra/data/app_config.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/favorites_notifier.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraFavoritesPage extends StatefulWidget {
  const EventraFavoritesPage({super.key, required this.controller});

  final HomeController controller;

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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              children: [
                Text(
                  AppConfig.instance.text('favorites.title', 'Favorites'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                if (favoriteEvents.isEmpty)
                  Text(
                    AppConfig.instance.text(
                      'favorites.empty',
                      'Your saved passes and events will appear here.',
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 15,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoriteEvents.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, index) {
                      return _favoriteEventCard(favoriteEvents[index]);
                    },
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
      venueLabel: '${event.place},\n${event.city}',
      isFavorite: true,
      onFavoriteTap: () => _removeFavorite(event),
      onActionTap: () {},
    );
  }
}
