import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/ticket_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyTicketPage extends StatefulWidget {
  const BuyTicketPage({
    super.key,
    required this.event,
    required this.onBack,
    required this.onCheckout,
  });

  final NearbyEvent event;
  final VoidCallback onBack;
  final void Function(NearbyEvent event, List<TicketType> tickets) onCheckout;

  @override
  State<BuyTicketPage> createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  List<TicketType> _ticketTypes = [];
  Map<String, dynamic> _detail = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      EventraDatabase.instance.fetchTicketTypes(widget.event.id),
      EventraDatabase.instance.fetchNearbyEventDetail(widget.event.id),
    ]);
    setState(() {
      _ticketTypes = (results[0] as List<Map<String, dynamic>>)
          .map(TicketType.fromJson)
          .toList();
      _detail = results[1] as Map<String, dynamic>;
      _loading = false;
    });
  }

  int get subtotal =>
      _ticketTypes.fold(0, (sum, t) => sum + t.price * t.quantity);

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp. ${buffer.toString()}';
  }

  Color _badgeColor(String? color) {
    switch (color) {
      case 'purple':
        return const Color(0xFFD0BCFF);
      case 'orange':
        return const Color(0xFFFFB347);
      case 'red':
        return const Color(0xFFFF6B7A);
      default:
        return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
      );
    }

    final detailImage =
        _detail['detail_image'] as String? ?? widget.event.image;
    final artistName = _detail['artist_name'] as String? ?? widget.event.title;
    final showTime = _detail['show_time'] as String? ?? widget.event.dateLabel;
    final venue = _detail['place'] as String? ?? widget.event.place;
    final description = _detail['description'] as String? ?? '';
    final venueLayout = _detail['venue_layout'] as String?;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image + Back ──
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 260,
                child: Image.network(
                  detailImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF2A2035)),
                ),
              ),
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF0E0717)],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Text(
                  'Get Your Tickets',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'CHOOSE YOUR EXPERIENCE',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Show time & venue ──
                Text(
                  showTime,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD0BCFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  artistName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFD0BCFF),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      venue,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                if (venueLayout != null && venueLayout.isNotEmpty) ...[
                  _buildVenueLayout(venueLayout, venue),
                  const SizedBox(height: 24),
                ],

                // ── Ticket Type Cards ──
                ..._ticketTypes.map((t) => _buildTicketCard(t)),

                const SizedBox(height: 24),

                // ── Order Summary ──
                Text(
                  'Order Summary',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                if (subtotal == 0)
                  Center(
                    child: Text(
                      'No tickets selected yet',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ..._ticketTypes
                      .where((t) => t.quantity > 0)
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${t.name} x${t.quantity}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _formatRupiah(t.price * t.quantity),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                const Divider(color: Colors.white12, height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBTOTAL',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _formatRupiah(subtotal),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD0BCFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Taxes and fees calculated at next step',
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: subtotal > 0
                        ? () {
                            final selectedTickets = _ticketTypes
                                .where((ticket) => ticket.quantity > 0)
                                .map(
                                  (ticket) => TicketType(
                                    id: ticket.id,
                                    name: ticket.name,
                                    badge: ticket.badge,
                                    badgeColor: ticket.badgeColor,
                                    description: ticket.description,
                                    bullet1: ticket.bullet1,
                                    bullet2: ticket.bullet2,
                                    bullet3: ticket.bullet3,
                                    price: ticket.price,
                                    stockRemaining: ticket.stockRemaining,
                                    quantity: ticket.quantity,
                                  ),
                                )
                                .toList();
                            widget.onCheckout(widget.event, selectedTickets);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0BCFF),
                      disabledBackgroundColor: Colors.white12,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                      'Continue to Checkout',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueLayout(String assetPath, String venue) {
    final normalizedAssetPath = _normalizeVenueLayoutAsset(assetPath);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Venue Layout',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            venue,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                normalizedAssetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: const Color(0xFF2A2035),
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      color: Colors.white24,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeVenueLayoutAsset(String assetPath) {
    const jpgOnlyLayouts = {
      'assets/stadiums/atlas_layout.png': 'assets/stadiums/atlas_layout.jpg',
      'assets/stadiums/gbk_layout.png': 'assets/stadiums/gbk_layout.jpg',
      'assets/stadiums/grand_layout.png': 'assets/stadiums/grand_layout.jpg',
      'assets/stadiums/sleman_layout.png': 'assets/stadiums/sleman_layout.jpg',
    };

    return jpgOnlyLayouts[assetPath] ?? assetPath;
  }

  Widget _buildTicketCard(TicketType t) {
    final isSoldOut = t.stockRemaining <= 0;
    final canAddMore = !isSoldOut && t.quantity < t.stockRemaining;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (t.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _badgeColor(t.badgeColor).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _badgeColor(t.badgeColor).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    t.badge!,
                    style: GoogleFonts.poppins(
                      color: _badgeColor(t.badgeColor),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isSoldOut ? Icons.event_busy : Icons.confirmation_number,
                color: isSoldOut ? const Color(0xFFFF6B7A) : Colors.white38,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                isSoldOut ? 'Sold out' : '${t.stockRemaining} tickets left',
                style: GoogleFonts.poppins(
                  color: isSoldOut ? const Color(0xFFFF6B7A) : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (t.description != null) ...[
            const SizedBox(height: 8),
            Text(
              t.description!,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          for (final bullet in [
            t.bullet1,
            t.bullet2,
            t.bullet3,
          ].whereType<String>())
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white24,
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      bullet,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatRupiah(t.price),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (t.quantity > 0) t.quantity--;
                    }),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2035),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        '${t.quantity}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: canAddMore
                        ? () => setState(() => t.quantity++)
                        : null,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: canAddMore
                            ? const Color(0xFF2A2035)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: canAddMore ? Colors.white : Colors.white24,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
