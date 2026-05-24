import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtistProfilePage extends StatelessWidget {
  final Map<String, dynamic> artistData;

  const ArtistProfilePage({super.key, required this.artistData});

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = (artistData['upcomingEvents'] as List<dynamic>? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16111F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          artistData['name'] as String? ?? 'Artist Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                artistData['imageUrl'] as String,
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 320,
                  color: const Color(0xFF1B1526),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white24, size: 72),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              artistData['name'] as String? ?? '',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              artistData['genre'] as String? ?? '',
              style: GoogleFonts.poppins(
                color: Colors.purpleAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artistData['followers'] as String? ?? '',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD0BCFF),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              artistData['description'] as String? ?? '',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upcoming Events',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (upcomingEvents.isEmpty)
              Text(
                'No upcoming events saved for this artist yet.',
                style: GoogleFonts.poppins(color: Colors.white54),
              )
            else
              ...upcomingEvents.map(
                (event) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1526),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event['lineup'] as String? ?? '',
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${event['venue']} • ${event['location']}',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['date'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD0BCFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
