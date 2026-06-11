import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/features/profile/profile_page.dart';
import 'package:eventra/features/promotor/views/promotor_dashboard.dart';
import 'package:eventra/features/promotor/views/promotor_create_event_page.dart';
import 'package:eventra/features/promotor/views/promotor_edit_event_page.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/promotor/views/promotor_event_detail_page.dart';

class PromotorEventsPage extends StatefulWidget {
  const PromotorEventsPage({super.key});

  @override
  State<PromotorEventsPage> createState() => _PromotorEventsPageState();
}

class _PromotorEventsPageState extends State<PromotorEventsPage> {
  int _selectedIndex = 1;
  int _selectedFilter = 0;
  bool _isLoading = true;

  List<Map<String, dynamic>> _events = [];

  List<String> get _filters {
    final liveCount = _events.where((e) => e['status'] == 'live').length;
    final completedCount = _events.where((e) => e['status'] == 'completed').length;
    final draftCount = _events.where((e) => e['status'] == 'draft').length;
    return ['ALL EVENTS', 'Live ($liveCount)', 'Draft ($draftCount)', 'Past Events ($completedCount)'];
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  Future<void> _deleteEvent(int eventId) async {
    final userId = EventraSession.instance.userId;
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Delete Event', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this event? This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PromotorApi.instance.deleteEvent(userId: userId, eventId: eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted')),
      );
      _loadEvents();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${e.toString()}')),
      );
    }
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openEventDetail(Map<String, dynamic> event) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PromotorEventDetailPage(event: event),
      ),
    );

    if (result == true) {
      _loadEvents();
    }
  }

  Widget _buildEventImage(dynamic imageData, double height) {
    final imageStr = imageData?.toString();
    if (imageStr == null || imageStr.isEmpty) {
      return Container(height: height, width: double.infinity, color: const Color(0xFF2A1F3D));
    }

    if (imageStr.startsWith('data:image')) {
      try {
        final base64Str = imageStr.split(',').last;
        final bytes = base64Decode(base64Str);
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
    // Backend returns YYYY-MM-DD, convert to readable format
    try {
      final parts = str.split('-');
      if (parts.length == 3) {
        const months = ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        final month = int.tryParse(parts[1]) ?? 0;
        final day = int.tryParse(parts[2]) ?? 0;
        if (month >= 1 && month <= 12) {
          return '${months[month]} $day';
        }
      }
    } catch (_) {}
    return str;
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedFilter == 0) return _events;
    if (_selectedFilter == 1) return _events.where((e) => e['status'] == 'live').toList();
    if (_selectedFilter == 2) return _events.where((e) => e['status'] == 'draft').toList();
    return _events.where((e) => e['status'] == 'completed').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.search, color: Colors.white, size: 24),
                    Text(
                      'EVENTRA',
                      style: TextStyle(
                        color: Color(0xFFD0BCFF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
                    : _events.isEmpty
                        ? _buildEmptyState()
                        : Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My Events',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Manage your roster, track live ticket sales, and analyze post-event revenue.',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(_filters.length, (index) {
                                          final isSelected = _selectedFilter == index;
                                          return GestureDetector(
                                            onTap: () => setState(() => _selectedFilter = index),
                                            child: Container(
                                              margin: const EdgeInsets.only(right: 10),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFD0BCFF)
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFFD0BCFF)
                                                      : Colors.white30,
                                                ),
                                              ),
                                              child: Text(
                                                _filters[index],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? const Color(0xFF3D2B6C)
                                                      : Colors.white70,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    if (_filteredEvents.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 40),
                                        child: Center(
                                          child: Text(
                                            'No events in this category yet.',
                                            style: TextStyle(color: Colors.white38, fontSize: 14),
                                          ),
                                        ),
                                      )
                                    else
                                      ..._filteredEvents.map(
                                        (event) => Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _buildEventCard(event),
                                        ),
                                      ),

                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),

                              Positioned(
                                bottom: 16,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const PromotorCreateEventPage()),
                                    ).then((_) => _loadEvents());
                                  },
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD0BCFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Color(0xFF3D2B6C),
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),

              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your roster, track live ticket sales, and analyze post-event revenue.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_note_outlined, color: Colors.white24, size: 56),
                    const SizedBox(height: 12),
                    const Text(
                      'No events yet',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the + button to create your first event.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 10,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PromotorCreateEventPage()),
              ).then((_) => _loadEvents());
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFD0BCFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF3D2B6C),
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final status = event['status'] as String;

    if (status == 'live') return _buildLiveCard(event);
    if (status == 'draft') return _buildDraftCard(event);
    return _buildCompletedCard(event);
  }

  Widget _buildLiveCard(Map<String, dynamic> event) {
    final ticketSold = _toInt(event['ticket_sold']);
    final ticketTotal = _toInt(event['ticket_total']);
    final progress = ticketTotal > 0 ? ticketSold / ticketTotal : 0.0;
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
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
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
                      child: Text(
                        event['title']?.toString() ?? 'Untitled Event',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _deleteEvent(_toInt(event['id'])),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EST. REVENUE',
                      style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1),
                    ),
                    Text(
                      _formatRupiah(revenue),
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DRAFT',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
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
                      child: Text(
                        event['title']?.toString() ?? 'Untitled Event',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _deleteEvent(_toInt(event['id'])),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
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
                          builder: (context) => PromotorEditEventPage(existingEvent: event),
                        ),
                      ).then((_) => _loadEvents());
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFD0BCFF)),
                    label: const Text(
                      'CONTINUE EDITING',
                      style: TextStyle(
                        color: Color(0xFFD0BCFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD0BCFF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
            ),
            child: const Text(
              'COMPLETED',
              style: TextStyle(color: Color(0xFF2ECC71), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            '${_formatEventDate(event['event_date'])} • ${event['location'] ?? '-'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),

          Text(
            event['title']?.toString() ?? 'Untitled Event',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FINAL ATTENDANCE',
                      style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ticketSold / $ticketTotal',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL PAYOUT',
                      style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(revenue),
                      style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121114),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PromotorDashboard()),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  color: _selectedIndex == 0 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'HOME',
                  style: TextStyle(
                    color: _selectedIndex == 0 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _selectedIndex == 1 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                      size: 26,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.star,
                        color: _selectedIndex == 1 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                        size: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'EVENTS',
                  style: TextStyle(
                    color: _selectedIndex == 1 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventraProfilePage(isPromotorView: true)),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectedIndex == 2 ? Icons.person : Icons.person_outline,
                  color: _selectedIndex == 2 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'PROFILE',
                  style: TextStyle(
                    color: _selectedIndex == 2 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}