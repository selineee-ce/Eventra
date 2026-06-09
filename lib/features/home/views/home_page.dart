import 'dart:async';

import 'package:eventra/data/app_config.dart';
import 'package:eventra/core/utils/search_match.dart';
import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/models/featured_event.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventra/features/home/models/exclusive_drop.dart';

class EventraHomePage extends StatefulWidget {
  const EventraHomePage({
    super.key,
    required this.controller,
    required this.onEventTap,
    this.searchQuery = '',
  });

  final HomeController controller;
  final void Function(NearbyEvent) onEventTap;
  final String searchQuery;

  @override
  State<EventraHomePage> createState() => _EventraHomePageState();
}

class _EventraHomePageState extends State<EventraHomePage> {
  final PageController _pageController = PageController();

  int currentPage = 0;
  int carouselTick = 0;
  final Map<int, int> _dropCountdowns = {};

  Duration countdown = const Duration(hours: 24);
  Timer? timer;

  HomeController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onStateChange);
    _ctrl.loadAll();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (countdown.inSeconds > 0) {
          countdown -= const Duration(seconds: 1);
        }

        // ← tambah ini
        _dropCountdowns.updateAll((id, secs) => secs > 0 ? secs - 1 : 0);

        if (normalizeSearchText(widget.searchQuery).isNotEmpty) {
          return;
        }

        carouselTick++;
        final events = _ctrl.state.featuredEvents;
        if (carouselTick >= 5 && events.isNotEmpty && _pageController.hasClients) {
          carouselTick = 0;
          currentPage = currentPage < events.length - 1 ? currentPage + 1 : 0;
          _pageController.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onStateChange);
    timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventraHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      currentPage = 0;
      carouselTick = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _onStateChange() {
    final drops = _ctrl.state.exclusiveDrops;
    for (final drop in drops) {
      if (!_dropCountdowns.containsKey(drop.id)) {
        _dropCountdowns[drop.id] = drop.countdownSeconds;
      }
    }
    setState(() {});
  }

  String get formattedCountdown {
    final hours = countdown.inHours.toString().padLeft(2, '0');
    final minutes = (countdown.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (countdown.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours : $minutes : $seconds';
  }

  @override
  Widget build(BuildContext context) {
    final state = _ctrl.state;
    final query = widget.searchQuery;
    final isSearching = normalizeSearchText(query).isNotEmpty;
    final featuredEvents = state.featuredEvents
        .where(
          (event) => matchesSearchQuery(query, [
            event.title,
            event.subtitle,
            event.tag1,
            event.tag2,
          ]),
        )
        .toList();
    final exclusiveDrops = state.exclusiveDrops
        .where(
          (drop) => matchesSearchQuery(query, [
            drop.title,
            drop.badge,
            drop.description,
            drop.type,
          ]),
        )
        .toList();
    final nearbyEvents =
        (isSearching ? state.nearbyEvents : state.visibleNearbyEvents)
            .where(
              (event) => matchesSearchQuery(query, [
                event.title,
                event.artistName,
                event.place,
                event.city,
                event.dateLabel,
                event.price,
              ]),
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
              )
            : state.hasError
            ? _buildError(state.errorMessage ?? 'Terjadi kesalahan')
            : RefreshIndicator(
                color: const Color(0xFFD0BCFF),
                backgroundColor: const Color(0xFF1B1526),
                onRefresh: _ctrl.loadAll,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // data dari tabel `featured_events`
                        buildFeaturedCarousel(featuredEvents),

                        const SizedBox(height: 22),

                        // teks dari tabel `app_config`
                        buildExclusiveHeader(),

                        const SizedBox(height: 18),

                        // data dari tabel `pass_packages`
                        buildExclusiveDrop(exclusiveDrops),

                        const SizedBox(height: 18),

                        // teks dari tabel `app_config`
                        buildNearYouHeader(isSearching: isSearching),

                        const SizedBox(height: 12),

                        // data dari tabel `nearby_events`
                        buildNearbyEvents(nearbyEvents),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _ctrl.loadAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0BCFF),
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carousel — tabel `featured_events` ────────────────────
  // field: image, tag1, tag2, title, subtitle, button
  Widget buildFeaturedCarousel(List<FeaturedEvent> events) {
    if (events.isEmpty) {
      return _buildSearchEmptyState('No featured events match your search.');
    }

    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _pageController,
        itemCount: events.length,
        onPageChanged: (index) => setState(() => currentPage = index),
        itemBuilder: (context, index) => buildFeaturedCard(events[index]),
      ),
    );
  }

  Widget buildFeaturedCard(FeaturedEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: _eventImage(event.image), // field: image
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x33000000), Color(0xD9000000)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                topTag(event.tag1), // field: tag1
                if (event.tag2 != null) ...[
                  const SizedBox(width: 8),
                  topTag(event.tag2!), // field: tag2 (nullable)
                ],
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title, // field: title
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event.subtitle, // field: subtitle
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppConfig.instance.text(
                            'home.ticket_snackbar',
                            'Tickets Clicked',
                          ),
                        ),
                      ),
                    );
                  },
                  child: buildPrimaryButton(event.button), // field: button
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrimaryButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD0BCFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
        ],
      ),
    );
  }

  // ── Exclusive Header — teks dari `app_config` ─────────────
  Widget buildExclusiveHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConfig.instance.text('home.drops_eyebrow', 'LIMITED ACCESS'),
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          AppConfig.instance.text('home.drops_title', 'Exclusive Drops'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
      ],
    );
  }

  // ── Pass Cards — tabel `pass_packages` ────────────────────
  // field: title, description (alias desc di API), price, is_favorite
  Widget buildExclusiveDrop(List<ExclusiveDrop> drops) {
    if (drops.isEmpty) {
      return _buildSearchEmptyState('No exclusive drops match your search.');
    }

    return Column(
      children: drops.map((drop) => buildExclusiveDropCard(drop)).toList(),
    );
  }

  Widget buildExclusiveDropCard(ExclusiveDrop drop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildDropImage(drop.image),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drop.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  drop.badge,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD0BCFF),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  drop.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatSeconds(
                        _dropCountdowns[drop.id] ?? drop.countdownSeconds,
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0BCFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'VIEW DETAILS',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropImage(String? image) {
    const size = 72.0;

    if (image == null || image.isEmpty) {
      return _buildDropImageFallback(Icons.event);
    }

    final isRemote =
        image.startsWith('http://') || image.startsWith('https://');
    if (isRemote) {
      return Image.network(
        image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildDropImageFallback(Icons.image_not_supported),
      );
    }

    return Image.asset(
      image,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _buildDropImageFallback(Icons.image_not_supported),
    );
  }

  Widget _buildDropImageFallback(IconData icon) {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFF5C4B7A),
      child: Icon(icon, color: Colors.white24, size: 28),
    );
  }

  // ── Near You Header — teks dari `app_config` ──────────────
  Widget buildNearYouHeader({bool isSearching = false}) {
    final nearbyCount = _ctrl.state.nearbyEvents.length;
    final isShowingAll = _ctrl.state.visibleNearbyCount >= nearbyCount;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.05).toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                // app_config key: 'home.nearby_title' → 'Happening Near You'
                AppConfig.instance.text(
                  'home.nearby_title',
                  'Happening Near You',
                ),
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
            if (!isSearching && nearbyCount > 4)
              TextButton(
                onPressed: () {
                  if (isShowingAll) {
                    _ctrl.resetNearbyEvents();
                  } else {
                    _ctrl.showAllNearbyEvents();
                  }
                },
                child: Text(
                  isShowingAll
                      ? 'SHOW LESS'
                      : AppConfig.instance.text('home.view_all', 'VIEW ALL'),
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

  // ── Nearby Grid — tabel `nearby_events` ───────────────────
  // field: image, date_label (API: date), title, place, price, is_favorite
  Widget buildNearbyEvents(List<NearbyEvent> events) {
    if (events.isEmpty) {
      return _buildSearchEmptyState('No nearby events match your search.');
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
        final item = events[index];
        return Center(
          child: EventraEventCard(
            image: item.image,
            dateLabel: item.dateLabel,
            title: item.title,
            subtitle: item.artistName.isEmpty
                ? 'artist lineup'
                : item.artistName,
            venueLabel: '${item.place}, ${item.city}',
            isFavorite: item.isFavorite,
            onTap: () => widget.onEventTap(item),
            onActionTap: () => widget.onEventTap(item),
            onFavoriteTap: () => _ctrl.toggleNearbyFavorite(item),
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget topTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$h : $m : $s';
  }

  ImageProvider _eventImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  Widget _buildSearchEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
