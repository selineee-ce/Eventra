import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/ticket_type.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
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
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        EventraDatabase.instance.fetchTicketTypes(widget.event.id),
        EventraDatabase.instance.fetchNearbyEventDetail(widget.event.id),
      ]);

      if (!mounted) return;

      setState(() {
        _ticketTypes = (results[0] as List<Map<String, dynamic>>)
            .map(TicketType.fromJson)
            .toList();
        _detail = results[1] as Map<String, dynamic>;
        _loading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
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

  String _formatSchedule(String dateLabel, String showTime) {
    final rawDate = dateLabel.trim();
    final rawTime = showTime.trim();
    final parsed = DateTime.tryParse(rawDate);
    final dateText = parsed == null ? rawDate : _formatLongDate(parsed);

    if (dateText.isEmpty) return rawTime.isEmpty ? 'TBA' : rawTime;
    if (rawTime.isEmpty) return dateText;
    return '$dateText • $rawTime';
  }

  String _formatLongDate(DateTime date) {
    const weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
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

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _badgeColor(String? color) {
    if (color != null && color.startsWith('#') && color.length == 7) {
      final parsed = int.tryParse(color.substring(1), radix: 16);
      if (parsed != null) {
        return Color(0xFF000000 | parsed);
      }
    }

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
    final eventName = _detail['title'] as String? ?? widget.event.title;
    final artistName = _detail['lineup'] as String? ?? widget.event.artistName;
    final dateLabel =
        _detail['date_label'] as String? ?? widget.event.dateLabel;
    final showTime = _detail['show_time'] as String? ?? '';
    final scheduleLabel = _formatSchedule(dateLabel, showTime);
    final venue = _detail['venue'] as String? ?? widget.event.place;
    final city = _detail['city'] as String? ?? widget.event.city;
    final description = _detail['description'] as String? ?? '';
    final venueLayout = _detail['venue_layout'] as String?;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image + Back ──
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 260,
                child: _buildEventImage(detailImage),
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
                const SizedBox(height: 10),
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
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Show time & venue ──
                Text(
                  scheduleLabel,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD0BCFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  eventName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height:6),
                Text(
                  artistName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFD0BCFF),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        city.isEmpty ? venue : '$venue, $city',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
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

                if (_loadError != null) ...[
                  _buildLoadError(),
                  const SizedBox(height: 18),
                ],

                if (venueLayout != null && venueLayout.isNotEmpty) ...[
                  _buildVenueLayout(venueLayout, venue),
                  const SizedBox(height: 24),
                ],

                // ── Ticket Type Cards ──
                if (_ticketTypes.isEmpty)
                  _buildNoTicketTypes()
                else
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
                      .map((t) => _buildOrderLine(t)),

                const Divider(color: Colors.white12, height: 32),
                _buildSubtotalLine(),
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
                                    maxPerOrder: ticket.maxPerOrder,
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
            child: ColoredBox(
              color: const Color(0xFF120D1B),
              child: Image.asset(
                normalizedAssetPath,
                width: double.infinity,
                fit: BoxFit.fitWidth,
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

  Widget _buildLoadError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B7A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B7A).withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF6B7A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _loadError!,
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFB3BA),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(String path) {
    if (path.isEmpty) {
      return _buildImageFallback();
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      );
    }

    if (path.startsWith('data:image')) {
      try {
        final base64Str = path.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImageFallback(),
        );
      } catch (_) {
        return _buildImageFallback();
      }
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFF2A2035),
      child: const Center(
        child: Icon(Icons.event, color: Colors.white24, size: 48),
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
    final buyLimit = t.maxPerOrder <= 0 ? t.stockRemaining : t.maxPerOrder;
    final maxBuy = buyLimit < t.stockRemaining ? buyLimit : t.stockRemaining;
    final canAddMore = !isSoldOut && t.quantity < maxBuy;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final scale = (width / 390).clamp(0.86, 1.06).toDouble();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1526),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTicketCategoryDetails(
                ticket: t,
                isSoldOut: isSoldOut,
                maxBuy: maxBuy,
                canAddMore: canAddMore,
                scale: scale,
              ),
              SizedBox(height: 12 * scale),
              Row(
                children: [
                  Expanded(child: _buildTicketPrice(t, scale)),
                  SizedBox(width: 14 * scale),
                  _buildQuantityStepper(t, canAddMore, scale),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketCategoryDetails({
    required TicketType ticket,
    required bool isSoldOut,
    required int maxBuy,
    required bool canAddMore,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: _buildTicketCategoryName(ticket, scale),
            ),
            if (ticket.badge != null) ...[
              SizedBox(width: 10 * scale),
              Flexible(child: _buildTicketBadge(ticket, scale)),
            ],
          ],
        ),
        SizedBox(height: 8 * scale),
        Wrap(
          spacing: 10 * scale,
          runSpacing: 8 * scale,
          children: [
            _buildTicketMetaPill(
              icon: isSoldOut ? Icons.event_busy : Icons.confirmation_number,
              label: isSoldOut ? 'Sold out' : '${ticket.stockRemaining} left',
              color: isSoldOut ? const Color(0xFFFF6B7A) : Colors.white54,
              scale: scale,
            ),
            _buildTicketMetaPill(
              icon: Icons.shopping_bag_outlined,
              label: 'Max $maxBuy per order',
              color: const Color(0xFFD0BCFF),
              scale: scale,
            ),
          ],
        ),
        if (!canAddMore && !isSoldOut && ticket.quantity >= maxBuy) ...[
          SizedBox(height: 8 * scale),
          Text(
            'Maximum purchase reached for this ticket type.',
            style: GoogleFonts.poppins(
              color: const Color(0xFFFFB347),
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (ticket.description != null) ...[
          SizedBox(height: 8 * scale),
          Text(
            ticket.description!,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12 * scale,
              height: 1.35,
            ),
          ),
        ],
        SizedBox(height: 8 * scale),
        for (final bullet in [
          ticket.bullet1,
          ticket.bullet2,
          ticket.bullet3,
        ].whereType<String>())
          _buildTicketBullet(bullet, scale),
      ],
    );
  }

  Widget _buildTicketCategoryName(TicketType ticket, double scale) {
    return Text(
      ticket.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18 * scale,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildTicketBadge(TicketType ticket, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: _badgeColor(ticket.badgeColor).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _badgeColor(ticket.badgeColor).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        ticket.badge!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: _badgeColor(ticket.badgeColor),
          fontSize: 10 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTicketBullet(String bullet, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white24,
            size: 12 * scale,
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Text(
              bullet,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11 * scale,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketPrice(TicketType ticket, double scale) {
    return Text(
      _formatRupiah(ticket.price),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18 * scale,
        height: 1.15,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildOrderLine(TicketType ticket) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '${ticket.name} x${ticket.quantity}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _formatRupiah(ticket.price * ticket.quantity),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalLine() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'SUBTOTAL',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            _formatRupiah(subtotal),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: const Color(0xFFD0BCFF),
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper(TicketType t, bool canAddMore, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (t.quantity > 0) t.quantity--;
          }),
          child: Container(
            width: 30 * scale,
            height: 30 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2035),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, color: Colors.white, size: 16 * scale),
          ),
        ),
        SizedBox(
          width: 36 * scale,
          child: Center(
            child: Text(
              '${t.quantity}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: canAddMore ? () => setState(() => t.quantity++) : null,
          child: Container(
            width: 30 * scale,
            height: 30 * scale,
            decoration: BoxDecoration(
              color: canAddMore ? const Color(0xFF2A2035) : Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add,
              color: canAddMore ? Colors.white : Colors.white24,
              size: 16 * scale,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoTicketTypes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        'Ticket categories are not available yet.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.white54,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTicketMetaPill({
    required IconData icon,
    required String label,
    required Color color,
    double scale = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14 * scale),
          SizedBox(width: 6 * scale),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
