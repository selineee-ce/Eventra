import 'package:eventra/core/widgets/navbar.dart';
import 'package:eventra/core/widgets/topbar.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/views/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyTicketPage extends StatelessWidget {
  const BuyTicketPage({super.key, required this.event});

  final NearbyEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navbar sama seperti MainScreen ──
            MainTopNavBar(
              onSearchTap: () {},
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),

            // ── Konten ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image dengan back button
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 280,
                          child: Image.network(
                            event.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF2A2035),
                              child: const Icon(Icons.music_note, color: Colors.white24, size: 60),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16, left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFD0BCFF), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                event.place,
                                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.calendar_today, color: Color(0xFFD0BCFF), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                event.dateLabel,
                                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            event.price,
                            style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: hubungkan ke flow pembayaran
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD0BCFF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'BUY TICKET',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navbar sama seperti MainScreen ──
      bottomNavigationBar: MainNavBar(
        currentIndex: 0, // Home tetap aktif saat di halaman ini
        onTap: (index) {
          // Kembali ke MainScreen dan pindah tab
          Navigator.pop(context);
        },
      ),
    );
  }
}