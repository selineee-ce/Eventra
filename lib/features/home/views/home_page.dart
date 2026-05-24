import 'dart:async';

import 'package:eventra/data/app_config.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/controllers/home_state.dart';
import 'package:eventra/features/home/models/featured_event.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/pass_package.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EventraHomePage
//
// Semua card di halaman ini mengambil data dari MySQL via backend Node.js:
//
//   Carousel  → tabel `featured_events`
//              GET /api/home/featured-events
//              field: id, title, subtitle, image, tag1, tag2, button, sort_order, is_favorite
//
//   Pass cards → tabel `pass_packages`
//               GET /api/home/passes
//               field: id, title, description (alias desc), price, sort_order, is_favorite
//
//   Nearby grid → tabel `nearby_events`
//                GET /api/home/nearby-events
//                field: id, title, date_label (alias date), place, price, image, sort_order, is_favorite
//
//   Teks UI    → tabel `app_config`
//               GET /api/app-config (diload di main.dart via AppConfig)
// ─────────────────────────────────────────────────────────────────────────────

class EventraHomePage extends StatefulWidget {
  const EventraHomePage({super.key, required this.controller});

  final HomeController controller;

  @override
  State<EventraHomePage> createState() => _EventraHomePageState();
}

class _EventraHomePageState extends State<EventraHomePage> {
  final PageController _pageController = PageController();

  int currentPage = 0;
  int carouselTick = 0;

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

  void _onStateChange() => setState(() {});

  String get formattedCountdown {
    final hours   = countdown.inHours.toString().padLeft(2, '0');
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
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
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
                            buildPasses(state.passes),

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
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
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
              label: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
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
                    color: Colors.white, fontSize: 34,
                    height: 1, fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event.subtitle, // field: subtitle
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppConfig.instance.text('home.ticket_snackbar', 'Tickets Clicked'),
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
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
        ],
      ),
    );
  }

  // ── Exclusive Header — teks dari `app_config` ─────────────
  Widget buildExclusiveHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // app_config key: 'home.drops_eyebrow' → value: 'LIMITED ACCESS'
              AppConfig.instance.text('home.drops_eyebrow', 'LIMITED ACCESS'),
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
            Text(
              // app_config key: 'home.drops_title' → value: 'Exclusive Drops'
              AppConfig.instance.text('home.drops_title', 'Exclusive Drops'),
              style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2035),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            formattedCountdown,
            style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  // ── Pass Cards — tabel `pass_packages` ────────────────────
  // field: title, description (alias desc di API), price, is_favorite
  Widget buildPasses(List<PassPackage> passes) {
    return Column(
      children: passes.map((pass) => buildPassCard(pass)).toList(),
    );
  }

  Widget buildPassCard(PassPackage pass) {
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
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF5C4B7A),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pass.title, // field: title
                  style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pass.description, // field: description (API: desc)
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  pass.price, // field: price
                  style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          // field: is_favorite → POST /api/passes/:id/favorite
          IconButton(
            onPressed: () => _ctrl.togglePassFavorite(pass),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                pass.isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(pass.isFavorite),
                color: const Color(0xFFD0BCFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Near You Header — teks dari `app_config` ──────────────
  Widget buildNearYouHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          // app_config key: 'home.nearby_title' → 'Happening Near You'
          AppConfig.instance.text('home.nearby_title', 'Happening Near You'),
          style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: _ctrl.showAllNearbyEvents,
          child: Text(
            // app_config key: 'home.view_all' → 'VIEW ALL'
            AppConfig.instance.text('home.view_all', 'VIEW ALL'),
            style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),
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
      itemBuilder: (context, index) => buildNearbyCard(events[index]),
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
                      child: const Icon(Icons.music_note, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.dateLabel, // field: date_label (API: date)
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.title, // field: title
          style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          item.place, // field: place
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.price, // field: price
              style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24,
              ),
            ),
            // field: is_favorite → POST /api/nearby-events/:id/favorite
            GestureDetector(
              onTap: () => _ctrl.toggleNearbyFavorite(item),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(item.isFavorite),
                  width: 38, height: 38,
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
          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ImageProvider _eventImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path); // untuk path lokal seperti 'assets/images/image1.jpeg'
  }
}
