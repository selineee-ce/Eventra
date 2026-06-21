import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/features/promotor/views/promotor_event_detail_page.dart';
import 'package:eventra/features/promotor/views/promotor_edit_event_page.dart';
import 'package:google_fonts/google_fonts.dart';

class PromotorSearchPage extends StatefulWidget {
  const PromotorSearchPage({super.key});

  @override
  State<PromotorSearchPage> createState() => _PromotorSearchPageState();
}

class _PromotorSearchPageState extends State<PromotorSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: All, 1: Live, 2: Draft, 3: Completed
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];

  final List<String> _filters = [
    'ALL',
    'LIVE',
    'DRAFT',
    'PAST',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final userId = EventraSession.instance.userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final events = await PromotorApi.instance.fetchEvents(userId);
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    final userId = EventraSession.instance.userId;
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Delete Event', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this event? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PromotorApi.instance.deleteEvent(userId: userId, eventId: eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Event deleted')));
      _loadEvents();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${e.toString()}')),
      );
    }
  }

  Future<void> _openEventDetail(Map<String, dynamic> event) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PromotorEventDetailPage(event: event)),
    );
    if (result == true) _loadEvents();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> results = _events;

    // Filter by status first
    if (_selectedFilter == 1) {
      results = results.where((e) => e['status'] == 'live').toList();
    } else if (_selectedFilter == 2) {
      results = results.where((e) => e['status'] == 'draft').toList();
    } else if (_selectedFilter == 3) {
      results = results.where((e) => e['status'] == 'completed').toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((e) {
        final title = (e['title'] ?? '').toString().toLowerCase();
        final location = (e['location'] ?? '').toString().toLowerCase();
        final artist = (e['artist_name'] ?? '').toString().toLowerCase();
        final venue = (e['venue'] ?? '').toString().toLowerCase();
        return title.contains(query) ||
            location.contains(query) ||
            artist.contains(query) ||
            venue.contains(query);
      }).toList();
    }

    return results;
  }

  Widget _buildEventImage(dynamic imageData, double height) {
    final imageStr = imageData?.toString();
    if (imageStr == null || imageStr.isEmpty) {
      return Container(height: height, width: double.infinity, color: const Color(0xFF2A1F3D));
    }
    if (imageStr.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imageStr.split(',').last);
        return Image.memory(bytes, height: height, width: double.infinity, fit: BoxFit.cover);
      } catch (_) {
        return Container(height: height, width: double.infinity, color: const Color(0xFF2A1F3D));
      }
    }
    return Container(height: height, width: double.infinity, color: const Color(0xFF2A1F3D));
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp$buffer';
  }

  String _formatEventDate(dynamic dateValue) {
    if (dateValue == null) return '-';
    final str = dateValue.toString();
    try {
      final parts = str.split('-');
      if (parts.length == 3) {
        const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final month = int.tryParse(parts[1]) ?? 0;
        final day = int.tryParse(parts[2]) ?? 0;
        if (month >= 1 && month <= 12) return '${months[month]} $day';
      }
    } catch (_) {}
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Search Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search title, artist, location...',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilter == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD0BCFF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFD0BCFF) : Colors.white30,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF3D2B6C) : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              // Results or loading
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
                    : filtered.isEmpty
                        ? _buildEmptyResults()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final event = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildEventCard(event),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try checking spelling or changing filters.',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final status = event['status'] as String;
    if (status == 'live') return _buildLiveCard(event);
    if (status == 'draft') return _buildDraftCard(event);
    return _buildCompletedCard(event);
  }

  Widget _buildLiveCard(Map<String, dynamic> event) {
    final revenue = _toInt(event['revenue']);

    return GestureDetector(
      onTap: () => _openEventDetail(event),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x4D1E1E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildEventImage(event['image'], 160),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.red, borderRadius: BorderRadius.circular(6)),
                    child: const Text('LIVE',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Text(
                    '${_formatEventDate(event['event_date'])} • ${event['location'] ?? '-'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(event['title']?.toString() ?? 'Untitled Event',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => _deleteEvent(_toInt(event['id'])),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EST. REVENUE',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 11, letterSpacing: 1)),
                      Text(_formatRupiah(revenue),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> event) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildEventImage(event['image'], 140),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('DRAFT',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                child: Text(
                  '${_formatEventDate(event['event_date'])} • ${event['location'] ?? '-'}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(event['title']?.toString() ?? 'Untitled Event',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () => _deleteEvent(_toInt(event['id'])),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Setup incomplete. Review your event details and ticket types before publishing.',
                  style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PromotorEditEventPage(existingEvent: event)),
                      ).then((_) => _loadEvents());
                    },
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFFD0BCFF)),
                    label: const Text('CONTINUE EDITING',
                        style: TextStyle(
                            color: Color(0xFFD0BCFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD0BCFF)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildCompletedCard(Map<String, dynamic> event) {
    final ticketSold = _toInt(event['ticket_sold']);
    final ticketTotal = _toInt(event['ticket_total']);
    final revenue = _toInt(event['revenue']);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A4A2E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.4)),
            ),
            child: const Text('COMPLETED',
                style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text('${_formatEventDate(event['event_date'])} • ${event['location'] ?? '-'}',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(event['title']?.toString() ?? 'Untitled Event',
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FINAL ATTENDANCE',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 11, letterSpacing: 0.8)),
                    const SizedBox(height: 4),
                    Text('$ticketSold / $ticketTotal',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL PAYOUT',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 11, letterSpacing: 0.8)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(revenue),
                        style: const TextStyle(
                            color: Color(0xFFD0BCFF),
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
