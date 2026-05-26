import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/favorites_notifier.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraFavoritesPage extends StatefulWidget {
  const EventraFavoritesPage({super.key, required this.controller});

  final HomeController controller;

  @override
  State<EventraFavoritesPage> createState() => _EventraFavoritesPageState();
}

class _EventraFavoritesPageState extends State<EventraFavoritesPage> {
  List<Map<String, dynamic>> favorites = [];
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
    // Fetch dari /api/favorites
    // Query di server.js:
    //   SELECT ... FROM pass_packages WHERE is_favorite = 1
    //   UNION
    //   SELECT ... FROM nearby_events WHERE is_favorite = 1
    final loadedFavorites = await EventraDatabase.instance.fetchFavorites();

    if (!mounted) return;

    setState(() {
      favorites = loadedFavorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> favorite) async {
    final id = int.tryParse(favorite['id'].toString());
    final type = favorite['type'] as String? ?? 'event';

    if (id == null) {
      return;
    }

    final previousFavorites = List<Map<String, dynamic>>.from(favorites);
    setState(() {
      favorites = favorites.where((item) {
        return item['id'] != id || item['type'] != type;
      }).toList();
    });

    try {
      await widget.controller.setFavoriteByType(
        type: type,
        id: id,
        isFavorite: false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        favorites = previousFavorites;
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
                if (favorites.isEmpty)
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
                  ...favorites.map(_favoriteCard),
              ],
            ),
    );
  }

  Widget _favoriteCard(Map<String, dynamic> favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x26D0BCFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              favorite['type'] == 'pass'
                  ? Icons.workspace_premium_outlined
                  : Icons.event_outlined,
              color: const Color(0xFFD0BCFF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite['title'] as String? ?? '',
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
                  favorite['subtitle'] as String? ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                favorite['price'] as String? ?? '',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _removeFavorite(favorite),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B3157),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite, color: Color(0xFFD0BCFF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
