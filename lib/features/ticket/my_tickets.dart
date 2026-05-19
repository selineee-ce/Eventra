import 'package:eventra/features/ticket/ticket_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraTicketsPage extends StatefulWidget {
  const EventraTicketsPage({super.key});

  @override
  State<EventraTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<EventraTicketsPage> {
  final List<Map<String, dynamic>> _ticketList = [
    {
      'title': 'THE WEEKND : AFTER HOURS TIL DAWN',
      'image':
          'https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=1200&auto=format&fit=crop',
      'date': 'Nov 22,\n2025',
      'time': '10:00 PM',
      'venue': 'France Stadium',
      'section': '104',
      'row': 'B',
      'seat': '12',
      'qr_data': 'Eventra-TheWeeknd-Section104-RowB-Seat12'
    },
    {
      'title': 'AFTER DARK : TECHNO SPECIAL',
      'image':
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=600&auto=format&fit=crop',
      'date': 'Dec 05,\n2025',
      'time': '11:30 PM',
      'venue': 'Fabric London',
      'section': 'REAR',
      'row': '12',
      'seat': 'Free',
      'qr_data': 'Eventra-AfterDark-SectionREAR-Row12'
    },
    {
      'title': 'BLUE NOTE SESSIONS : JAZZ NIGHT',
      'image':
          'https://images.unsplash.com/photo-1511192336575-5a79af67a629?q=80&w=600&auto=format&fit=crop',
      'date': 'Jan 18,\n2026',
      'time': '08:00 PM',
      'venue': 'The Jazz Cafe',
      'section': 'VIP',
      'row': 'TABLE',
      'seat': '04',
      'qr_data': 'Eventra-BlueNote-VIP-Table04'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Your Tickets',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Ready for the night of your life? Access all your passes here',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: 'Find a ticket...',

                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 13,
                  ),

                  filled: true,
                  fillColor: const Color(0xFF1B1526),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  suffixIcon: const Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 20,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white10,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white10,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ..._ticketList.map((ticket) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),

                  child: _buildTicketCard(
                    context,
                    ticket: ticket,
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context, {
    required Map<String, dynamic> ticket,
  }) {
    return ClipPath(
      clipper: TicketListCardClipper(),

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1526),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: Image.network(
                      ticket['image'],
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          ticket['title'],

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          ticket['venue'],

                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _buildMiniTag(
                              'SEC ${ticket['section']}',
                            ),

                            const SizedBox(width: 6),

                            _buildMiniTag(
                              'ROW ${ticket['row']}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      height: 1,

                      color:
                          index % 2 == 0
                              ? Colors.transparent
                              : Colors.white10,
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder:
                        (context) => TicketDetailPage(
                          title: ticket['title'],
                          imageUrl: ticket['image'],
                          venue: ticket['venue'],
                          date: ticket['date'],
                          time: ticket['time'],
                          section: ticket['section'],
                          row: ticket['row'],
                          seat: ticket['seat'],
                          qrData: ticket['qr_data'],
                        ),
                  ),
                );
              },

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),

                alignment: Alignment.center,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      const Icon(
                        Icons.confirmation_num_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        'VIEW PASS',

                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),

      child: Text(
        text,

        style: GoogleFonts.poppins(
          color: Colors.white38,
          fontSize: 11,
        ),
      ),
    );
  }
}

class TicketListCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    double cutTop = size.height - 55;
    double radius = 12;

    path.lineTo(0, cutTop - radius);

    path.arcToPoint(
      Offset(0, cutTop + radius),
      radius: Radius.circular(radius),
    );

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, cutTop + radius);

    path.arcToPoint(
      Offset(size.width, cutTop - radius),
      radius: Radius.circular(radius),
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}