import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketDetailPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String venue;
  final String date;
  final String time;
  final String section;
  final String row;
  final String seat;
  final String qrData;

  const TicketDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.venue,
    required this.date,
    required this.time,
    required this.section,
    required this.row,
    required this.seat,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      appBar: AppBar(
        title: Text(
          'EVENTRA',
          style: GoogleFonts.poppins(
            color: const Color(0xFFD0BCFF),
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFF0E0717),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: ClipPath(
            clipper: TicketDetailCardClipper(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1526),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //1. Gambar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  //2. Judul Event
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 3. Grid Kolom Waktu (DATE & TIME) sejajar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGridInfo('DATE', date.replaceAll('\n', ' ')),
                        _buildGridInfo('TIME', time),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Divider(color: Colors.white10, thickness: 1),
                  ),
                  const SizedBox(height: 15),

                  // 4. Info Venue Lokasi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VENUE',
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF8A51F2),
                              size: 25,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                venue,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Box Kursi (SECTION, ROW, SEAT)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildSeatBox('SECTION', section)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSeatBox('ROW', row)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSeatBox('SEAT', seat)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 45),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: List.generate(
                        25,
                        (index) => Expanded(
                          child: Container(
                            height: 1,
                            color: index % 2 == 0
                                ? Colors.transparent
                                : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 7. Bagian QR Code bawah terintegrasi di dalam satu cetakan tiket
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.qr_code_2,
                            color: Color(0xFF0E0717),
                            size: 150,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          qrData,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketDetailCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    double cutTop = size.height - 238;
    double radius = 25;

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
