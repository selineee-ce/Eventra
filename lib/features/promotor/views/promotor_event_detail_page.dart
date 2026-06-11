import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:eventra/features/promotor/views/promotor_edit_event_page.dart';

class PromotorEventDetailPage extends StatefulWidget {
  const PromotorEventDetailPage({super.key, required this.event});

  final Map<String, dynamic> event;

  @override
  State<PromotorEventDetailPage> createState() => _PromotorEventDetailPageState();
}

class _PromotorEventDetailPageState extends State<PromotorEventDetailPage> {
  bool _isDeleting = false;

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
    if (dateValue == null) return 'TBA';
    final str = dateValue.toString();
    try {
      final parts = str.split('-');
      if (parts.length == 3) {
        const months = ['', 'January','February','March','April','May','June','July','August','September','October','November','December'];
        final month = int.tryParse(parts[1]) ?? 0;
        final day = int.tryParse(parts[2]) ?? 0;
        final year = parts[0];
        if (month >= 1 && month <= 12) {
          return '${months[month]} $day, $year';
        }
      }
    } catch (_) {}
    return str;
  }

  Widget _buildEventImage(dynamic imageData) {
    final imageStr = imageData?.toString();
    if (imageStr == null || imageStr.isEmpty) {
      return Container(
        height: 240,
        width: double.infinity,
        color: const Color(0xFF2A1F3D),
        child: const Icon(Icons.event, color: Colors.white24, size: 48),
      );
    }

    if (imageStr.startsWith('data:image')) {
      try {
        final base64Str = imageStr.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return Container(
          height: 240,
          width: double.infinity,
          color: const Color(0xFF2A1F3D),
          child: const Icon(Icons.event, color: Colors.white24, size: 48),
        );
      }
    }

    return Container(
      height: 240,
      width: double.infinity,
      color: const Color(0xFF2A1F3D),
      child: const Icon(Icons.event, color: Colors.white24, size: 48),
    );
  }

  Future<void> _deleteEvent() async {
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
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await PromotorApi.instance.deleteEvent(
        userId: userId,
        eventId: _toInt(widget.event['id']),
      );
      if (!mounted) return;
      Navigator.pop(context, true); // signal caller to refresh
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final status = event['status']?.toString() ?? 'draft';
    final title = event['title']?.toString() ?? 'Untitled Event';
    final artistName = event['artist_name']?.toString() ?? '';
    final venue = event['venue']?.toString() ?? '';
    final location = event['location']?.toString() ?? '';
    final description = event['description']?.toString() ?? '';
    final tickets = (event['tickets'] is List)
        ? List<Map<String, dynamic>>.from(
            (event['tickets'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
          )
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: _buildEventImage(event['image']),
                  ),
                  Container(
                    height: 240,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0E0717)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
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
                  Positioned(
                    top: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: status == 'live' ? Colors.red : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
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
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    if (artistName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        artistName,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD0BCFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFFD0BCFF), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatEventDate(event['event_date'])} • ${event['event_time'] ?? '-'}',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFD0BCFF), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            venue.isEmpty ? location : '$venue, $location',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],

                    if (tickets.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Ticket Types',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...tickets.map((ticket) => _buildTicketRow(ticket)),
                    ],

                    const SizedBox(height: 28),

                    // ── Action buttons ──
                    if (status == 'draft') ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PromotorEditEventPage(existingEvent: event),
                              ),
                            ).then((_) => Navigator.pop(context, true));
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFD0BCFF)),
                          label: Text(
                            'CONTINUE EDITING',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD0BCFF),
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
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting ? null : _deleteEvent,
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        label: Text(
                          _isDeleting ? 'DELETING...' : 'DELETE EVENT',
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
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
        ),
      ),
    );
  }

  Widget _buildTicketRow(Map<String, dynamic> ticket) {
    final type = ticket['type']?.toString() ?? 'Ticket';
    final price = _toInt(ticket['price']);
    final available = _toInt(ticket['available']);
    final sold = _toInt(ticket['sold']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sold $sold / $available',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRupiah(price),
            style: GoogleFonts.poppins(
              color: const Color(0xFFD0BCFF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}