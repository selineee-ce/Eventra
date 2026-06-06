import 'package:eventra/core/widgets/event_card.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/ticket/buy_ticket_page.dart';
import 'package:eventra/features/ticket/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtistProfilePage extends StatelessWidget {
  const ArtistProfilePage({super.key, required this.artistData});

  final Map<String, dynamic> artistData;

  @override
  Widget build(BuildContext context) {
    // Ambil data dasar dari parameters
    final imageUrl =
        artistData['imageUrl'] as String? ??
        artistData['avatar_url'] as String? ??
        '';
    final name = artistData['name'] as String? ?? 'Artist Profile';
    final followers =
        (artistData['followers'] ?? artistData['followers_count'])
            ?.toString() ??
        '0';
    final description = artistData['description'] as String? ?? '';
    final rank = artistData['rank'] as int? ?? 0;

    // Ambil data konser yang sudah di-filter oleh server
    final upcomingEvents = (artistData['upcomingEvents'] as List? ?? const [])
        .whereType<Map>()
        .map((event) => Map<String, dynamic>.from(event))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16111F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EVENTRA',
          style: GoogleFonts.poppins(
            color: const Color(0xFFD0BCFF),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArtistHero(
              imageUrl: imageUrl,
              name: name,
              followers: followers,
              eventsCount: upcomingEvents.length,
              rank: rank,
            ),
            const SizedBox(height: 14),
            _SectionPanel(
              title: 'ABOUT ${name.toUpperCase()}',
              child: Text(
                description.isEmpty
                    ? 'No artist description available.'
                    : description,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upcoming Events',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (upcomingEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'There is no upcoming events',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingEvents.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (context, index) {
                  final event = upcomingEvents[index];
                  final nearbyEvent = NearbyEvent(
                    id: _asInt(event['event_id'] ?? event['id']),
                    title: event['title']?.toString() ?? '',
                    dateLabel: event['date_label']?.toString() ?? '',
                    place: event['venue']?.toString() ?? '',
                    city: event['city']?.toString() ?? '',
                    artistName: event['lineup']?.toString() ?? name,
                    price: event['price']?.toString() ?? '',
                    image: event['image']?.toString() ?? '',
                    sortOrder: _asInt(event['sort_order']),
                    isFavorite: _asBool(event['is_favorite']),
                  );

                  return EventraEventCard(
                    image:
                        event['image'] as String? ??
                        event['image_url'] as String? ??
                        '',
                    dateLabel: _formatDate(
                      event['date_label'] as String? ?? '',
                    ),
                    title: event['title'] as String? ?? '',
                    subtitle: event['lineup'] as String? ?? name,
                    venueLabel:
                        '${event['venue'] ?? ''}, ${event['city'] ?? ''}',
                    isFavorite: nearbyEvent.isFavorite,
                    onTap: () => _openEvent(context, nearbyEvent),
                    onActionTap: () => _openEvent(context, nearbyEvent),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return 'TBA';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

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

    return '${months[parsed.month - 1]} ${parsed.day}';
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

  void _openEvent(BuildContext context, NearbyEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyTicketPage(
          event: event,
          onBack: () => Navigator.pop(context),
          onCheckout: (event, tickets) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  event: event,
                  tickets: tickets,
                  onBack: () => Navigator.pop(context),
                  onPaymentComplete: (payment) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment completed')),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============== SUB-COMPONENTS WIDGETS ==============
class _ArtistHero extends StatelessWidget {
  const _ArtistHero({
    required this.imageUrl,
    required this.name,
    required this.followers,
    required this.eventsCount,
    required this.rank,
  });

  final String imageUrl;
  final String name;
  final String followers;
  final int eventsCount;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 390,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ArtistImage(path: imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(text: '#$rank TRENDING ARTISTS'),
                  const SizedBox(height: 8),
                  Text(
                    name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 36,
                      height: 0.95,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HeroStat(label: 'FOLLOWER', value: followers),
                      const SizedBox(width: 22),
                      _HeroStat(label: 'EVENTS', value: '$eventsCount'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, size: 18),
                    label: const Text('ADD TO FAVORITES'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0BCFF),
                      foregroundColor: const Color(0xFF4D2B6C),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistImage extends StatelessWidget {
  const _ArtistImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Container(
      color: const Color(0xFF1B1526),
      child: const Icon(Icons.person, color: Colors.white24, size: 72),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD0BCFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF4D2B6C),
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
