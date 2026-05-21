import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/ticket/ticket_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraTicketsPage extends StatefulWidget {
  const EventraTicketsPage({super.key});

  @override
  State<EventraTicketsPage> createState() => _EventraTicketsPageState();
}

class _EventraTicketsPageState extends State<EventraTicketsPage> {
  List<Map<String, dynamic>> _ticketList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final tickets = await EventraDatabase.instance.fetchTickets();

    if (!mounted) {
      return;
    }

    setState(() {
      _ticketList = tickets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD0BCFF),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ..._ticketList.map((ticket) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _buildTicketCard(context, ticket: ticket),
                      );
                    }),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF8A51F2),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Buy More Tickets',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ticket['image'] as String,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['title'] as String,
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
                        ticket['venue'] as String,
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildMiniTag('SEC ${ticket['section']}'),
                          _buildMiniTag('ROW ${ticket['row_label']}'),
                          _buildMiniTag('SEAT ${ticket['seat_label']}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index.isEven ? Colors.transparent : Colors.white10,
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
                  builder: (context) => TicketDetailPage(
                    title: ticket['title'] as String,
                    imageUrl: ticket['image'] as String,
                    venue: ticket['venue'] as String,
                    date: ticket['date_label'] as String,
                    time: ticket['time_label'] as String,
                    section: ticket['section'] as String,
                    row: ticket['row_label'] as String,
                    seat: ticket['seat_label'] as String,
                    qrData: ticket['qr_data'] as String,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
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
    );
  }

  Widget _buildMiniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
