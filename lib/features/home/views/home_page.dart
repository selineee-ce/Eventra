import 'dart:async';

import 'package:eventra/data/app_config.dart';
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
  });

  final HomeController controller;
  final void Function(NearbyEvent) onEventTap;

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
    _ctrl.loadAll(); // fetch ketiga tabel sekaligus (paralel)

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (countdown.inSeconds > 0) {
          countdown -= const Duration(seconds: 1);
        }

        // ← tambah ini
        _dropCountdowns.updateAll((id, secs) => secs > 0 ? secs - 1 : 0);

        carouselTick++;
        final events = _ctrl.state.featuredEvents;
        if (carouselTick >= 5 &&
            events.isNotEmpty &&
            _pageController.hasClients) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // data dari tabel `featured_events`
                        buildFeaturedCarousel(state.featuredEvents),

                        const SizedBox(height: 22),

                        // teks dari tabel `app_config`
                        buildExclusiveHeader(),

                        const SizedBox(height: 18),

                        // data dari tabel `pass_packages`
                        buildExclusiveDrop(state.exclusiveDrops),

                        const SizedBox(height: 18),

                        // teks dari tabel `app_config`
                        buildNearYouHeader(),

                        const SizedBox(height: 12),

                        // data dari tabel `nearby_events`
                        buildNearbyEvents(state.visibleNearbyEvents),

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
                    fontSize: 13,
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
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        ),
        Text(
          AppConfig.instance.text('home.drops_title', 'Exclusive Drops'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  // ── Pass Cards — tabel `pass_packages` ────────────────────
  // field: title, description (alias desc di API), price, is_favorite
  Widget buildExclusiveDrop(List<ExclusiveDrop> drops) {
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
            child: drop.image != null
                ? Image.network(
                    drop.image!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFF5C4B7A),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white24,
                        size: 28,
                      ),
                    ),
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF5C4B7A),
                    child: const Icon(
                      Icons.event,
                      color: Colors.white24,
                      size: 28,
                    ),
                  ),
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
                    fontSize: 11,
                  ),
                ),
                Text(
                  drop.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
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
                                fontSize: 11,
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

  // ── Near You Header — teks dari `app_config` ──────────────
  Widget buildNearYouHeader() {
    final nearbyCount = _ctrl.state.nearbyEvents.length;
    final isShowingAll = _ctrl.state.visibleNearbyCount >= nearbyCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          // app_config key: 'home.nearby_title' → 'Happening Near You'
          AppConfig.instance.text('home.nearby_title', 'Happening Near You'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {
            if (isShowingAll) {
              _ctrl.resetNearbyEvents(); // ← tambah method ini
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
            ),
          ),
        ),
      ],
    );
  }

  // ── Nearby Grid — tabel `nearby_events` ───────────────────
  // field: image, date_label (API: date), title, place, price, is_favorite
  Widget buildNearbyEvents(List<NearbyEvent> events) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, index) {
        final item = events[index];
        return GestureDetector(
          onTap: () => widget.onEventTap(item),
          child: buildNearbyCard(item),
        );
      },
    );
  }

  Widget buildNearbyCard(NearbyEvent item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 175,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    item.image, // field: image (URL Unsplash dari DB)
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF2A2035),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white24,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.dateLabel, // field: date_label (API: date)
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: Text(
            item.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),

        const SizedBox(height: 4),

        SizedBox(
          height: 18,
          child: Text(
            item.place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _ctrl.toggleNearbyFavorite(item),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(item.isFavorite),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF3B3157),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_outline,
                color: const Color(0xFFD0BCFF),
              ),
            ),
          ),
        ),
      ],
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
          fontSize: 10,
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
    return AssetImage(
      path,
    ); // untuk path lokal seperti 'assets/images/image1.jpeg'
  }
}
