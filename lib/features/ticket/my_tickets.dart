import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/tickets_notifier.dart';
import 'package:eventra/core/utils/search_match.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';
import 'package:eventra/features/ticket/ticket_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraTicketsPage extends StatefulWidget {
  const EventraTicketsPage({super.key, this.searchQuery = '', this.onBuyMore});

  final String searchQuery;
  final VoidCallback? onBuyMore;

  @override
  State<EventraTicketsPage> createState() => _EventraTicketsPageState();
}

class _EventraTicketsPageState extends State<EventraTicketsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _ticketList = [];
  bool _isLoading = true;
  String _localSearchQuery = '';

  String get _effectiveSearchQuery =>
      normalizeSearchText(_localSearchQuery).isNotEmpty
      ? _localSearchQuery
      : widget.searchQuery;

  List<Map<String, dynamic>> get _filteredTickets => _ticketList
      .where(
        (ticket) => matchesSearchQuery(_effectiveSearchQuery, [
          ticket['title'],
          ticket['venue'],
          ticket['date_label'],
          ticket['time_label'],
          ticket['section'],
          ticket['row_label'],
          ticket['seat_label'],
        ]),
      )
      .toList();

  String _cleanLabel(dynamic value, String prefix) {
    return value
        .toString()
        .replaceFirst(RegExp('^$prefix\\s+', caseSensitive: false), '')
        .trim();
  }

  @override
  void initState() {
    super.initState();
    _loadTickets();
    TicketsNotifier.instance.addListener(_loadTickets);
  }

  @override
  void dispose() {
    TicketsNotifier.instance.removeListener(_loadTickets);
    _searchController.dispose();
    super.dispose();
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
    final filteredTickets = _filteredTickets;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConfig.instance.text('tickets.title', 'Your Tickets'),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConfig.instance.text(
                        'tickets.subtitle',
                        'Ready for the night of your life? Access all your passes here',
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _localSearchQuery = value);
                      },
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppConfig.instance.text(
                          'tickets.search_hint',
                          'Find a ticket...',
                        ),
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white38,
                          size: 20,
                        ),
                        suffixIcon: _localSearchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _localSearchQuery = '');
                                },
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
                    if (filteredTickets.isEmpty)
                      _buildEmptySearchState()
                    else
                      ...filteredTickets.map((ticket) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _buildTicketCard(context, ticket: ticket),
                        );
                      }),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: widget.onBuyMore,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFF8A51F2),
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppConfig.instance.text(
                                  'tickets.buy_more',
                                  'Buy More Tickets',
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFF2A2035),
                      child: const Icon(
                        Icons.confirmation_number,
                        color: Colors.white24,
                        size: 28,
                      ),
                    ),
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
                          _buildMiniTag(
                            'ROW ${_cleanLabel(ticket['row_label'], 'ROW')}',
                          ),
                          _buildMiniTag(
                            'SEAT ${_cleanLabel(ticket['seat_label'], 'SEAT')}',
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
                  builder: (context) => EventraSubpageShell(
                    currentIndex: 2,
                    child: TicketDetailPage(
                      title: ticket['title'] as String,
                      imageUrl: ticket['image'] as String,
                      venue: ticket['venue'] as String,
                      date: ticket['date_label'] as String,
                      time: ticket['time_label'] as String,
                      section: ticket['section'] as String,
                      row: _cleanLabel(ticket['row_label'], 'ROW'),
                      seat: _cleanLabel(ticket['seat_label'], 'SEAT'),
                      qrData: ticket['qr_data'] as String,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 6,
                ),
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
                      AppConfig.instance.text('tickets.view_pass', 'VIEW PASS'),
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
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: Color(0xFFD0BCFF), size: 34),
          const SizedBox(height: 12),
          Text(
            'No tickets match your search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
