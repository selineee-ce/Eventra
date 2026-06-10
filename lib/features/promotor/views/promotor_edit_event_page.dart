import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/features/promotor/views/promotor_events_page.dart';

class _TicketData {
  String type;
  String price;
  String available;
  DateTime? salesEndDate;
  TimeOfDay? salesEndTime;

  _TicketData({
    this.type = 'General Admission',
    this.price = '',
    this.available = '',
    this.salesEndDate,
    this.salesEndTime,
  });

  Map<String, dynamic> get badgeInfo {
    switch (type) {
      case 'VIP Access':
        return {'badge': 'Premium', 'color': const Color(0xFF1A6B4A)};
      case 'Backstage Pass':
        return {'badge': 'Ultimate', 'color': const Color(0xFF8B1A1A)};
      default:
        return {'badge': 'Standard', 'color': const Color(0xFF5B3F9E)};
    }
  }

  String get description {
    switch (type) {
      case 'VIP Access':
        return 'Express entry, exclusive VIP lounge access and 2 complimentary drinks.';
      case 'Backstage Pass':
        return 'Personal meet & greet with artists, and exclusive side-stage viewing platform.';
      default:
        return 'Standard entry to the main arena floor.';
    }
  }

  String get formattedPrice {
    if (price.isEmpty) return 'Rp. -';
    final num = int.tryParse(price.replaceAll('.', '')) ?? 0;
    final parts = num.toString().split('');
    final reversed = parts.reversed.toList();
    final withDots = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) withDots.add('.');
      withDots.add(reversed[i]);
    }
    return 'Rp. ${withDots.reversed.join('')},00';
  }

  String get formattedSalesEnd {
    if (salesEndDate == null) return '';
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final date = '${months[salesEndDate!.month - 1]} ${salesEndDate!.day}';
    if (salesEndTime == null) return date;
    final h = salesEndTime!.hourOfPeriod == 0 ? 12 : salesEndTime!.hourOfPeriod;
    final m = salesEndTime!.minute.toString().padLeft(2, '0');
    final p = salesEndTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$date • $h:$m $p';
  }
}

class _PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final num = int.tryParse(digits) ?? 0;
    final parts = num.toString().split('');
    final reversed = parts.reversed.toList();
    final withDots = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) withDots.add('.');
      withDots.add(reversed[i]);
    }
    final formatted = withDots.reversed.join('');
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PromotorEditEventPage extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;

  const PromotorEditEventPage({super.key, this.existingEvent});

  @override
  State<PromotorEditEventPage> createState() => _PromotorEditEventPageState();
}

class _PromotorEditEventPageState extends State<PromotorEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _venueController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _selectedLocation;

  // Image
  Uint8List? _pickedImageBytes;
  String? _imageBase64; // new picked image (base64)
  String? _existingImage; // existing image string from backend (could be base64 or url)
  bool _isSubmitting = false;

  final List<String> _locations = [
    'Jakarta', 'Bandung', 'Surabaya', 'Bali',
    'Yogyakarta', 'Medan', 'Makassar',
  ];

  final List<String> _ticketTypes = [
    'General Admission', 'VIP Access', 'Backstage Pass', 'Other',
  ];

  late List<_TicketData> _tickets;

  @override
  void initState() {
    super.initState();

    final event = widget.existingEvent ?? {};

    _titleController = TextEditingController(text: event['title']?.toString() ?? '');
    _artistController = TextEditingController(text: event['artist_name']?.toString() ?? '');
    _venueController = TextEditingController(text: event['venue']?.toString() ?? '');
    _descriptionController = TextEditingController(text: event['description']?.toString() ?? '');

    // Parse event_date (YYYY-MM-DD) and event_time (HH:MM)
    _selectedDate = _parseApiDate(event['event_date']) ?? DateTime.now();
    _selectedTime = _parseApiTime(event['event_time']) ?? const TimeOfDay(hour: 9, minute: 41);

    final loc = event['location']?.toString();
    _selectedLocation = (loc != null && _locations.contains(loc)) ? loc : null;

    _existingImage = event['image']?.toString();

    // Parse existing tickets
    final ticketsData = event['tickets'];
    if (ticketsData is List && ticketsData.isNotEmpty) {
      _tickets = ticketsData.map((t) {
        final map = Map<String, dynamic>.from(t as Map);
        return _TicketData(
          type: map['type']?.toString() ?? 'General Admission',
          price: _toIntString(map['price']),
          available: _toIntString(map['available']),
          salesEndDate: _parseApiDate(map['sales_end_date']),
          salesEndTime: _parseApiTime(map['sales_end_time']),
        );
      }).toList();
    } else {
      _tickets = [];
    }
  }

  String _toIntString(dynamic value) {
    if (value == null) return '';
    if (value is num) return value.toInt().toString();
    return value.toString();
  }

  DateTime? _parseApiDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    try {
      final parts = str.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2].split('T').first.substring(0, 2).contains(':') ? parts[2].substring(0, 2) : parts[2].substring(0, 2)),
        );
      }
    } catch (_) {}
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseApiTime(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    try {
      final parts = str.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Image picker ─────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);

    setState(() {
      _pickedImageBytes = bytes;
      _imageBase64 = 'data:image/jpeg;base64,$base64Str';
    });
  }

  Widget _buildExistingImagePreview() {
    final imageStr = _existingImage;
    if (imageStr == null || imageStr.isEmpty) return _imagePlaceholder();

    if (imageStr.startsWith('data:image')) {
      try {
        final base64Str = imageStr.split(',').last;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        );
      } catch (_) {
        return _imagePlaceholder();
      }
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.add_photo_alternate_outlined, color: Colors.white38, size: 36),
      SizedBox(height: 8),
      Text(
        'Tap to upload an image',
        style: TextStyle(color: Colors.white38, fontSize: 13),
      ),
    ],
  );

  // ── Pickers ────────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => _darkTheme(ctx, child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => _darkTheme(ctx, child!),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<DateTime?> _pickSalesEndDate(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
    builder: (ctx, child) => _darkTheme(ctx, child!),
  );

  Future<TimeOfDay?> _pickSalesEndTime(TimeOfDay? initial) => showTimePicker(
    context: context,
    initialTime: initial ?? TimeOfDay.now(),
    builder: (ctx, child) => _darkTheme(ctx, child!),
  );

  Widget _darkTheme(BuildContext ctx, Widget child) => Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD0BCFF),
        surface: Color(0xFF1E1E2E),
      ),
    ),
    child: child,
  );

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String _toApiDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _toApiTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String? _ticketSalesEndDate(_TicketData ticket) {
    if (ticket.salesEndDate == null) return null;
    return _toApiDate(ticket.salesEndDate!);
  }

  String? _ticketSalesEndTime(_TicketData ticket) {
    if (ticket.salesEndTime == null) return null;
    return _toApiTime(ticket.salesEndTime!);
  }

  // ── Ticket modal ───────────────────────────────────────────────────────────
  void _openTicketModal({_TicketData? existing, int? editIndex}) {
    final ticket = existing != null
        ? _TicketData(
            type: existing.type,
            price: existing.price,
            available: existing.available,
            salesEndDate: existing.salesEndDate,
            salesEndTime: existing.salesEndTime,
          )
        : _TicketData();

    final isCustomType = !_ticketTypes.contains(ticket.type) || ticket.type == 'Other';
    String selectedType = isCustomType ? 'Other' : ticket.type;
    final customTypeController = TextEditingController(text: isCustomType && ticket.type != 'Other' ? ticket.type : '');
    final priceController = TextEditingController(text: ticket.price);
    final availableController = TextEditingController(text: ticket.available);
    DateTime? salesEndDate = ticket.salesEndDate;
    TimeOfDay? salesEndTime = ticket.salesEndTime;
    String? salesEndError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  editIndex != null ? 'Edit Ticket' : 'Add Ticket',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Ticket Type', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: const Color(0xFF2A2A3E),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco(),
                  items: _ticketTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setModal(() => selectedType = val!),
                ),
                if (selectedType == 'Other') ...[
                  const SizedBox(height: 14),
                  const Text('Custom Ticket Name', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: customTypeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco().copyWith(hintText: 'e.g. Early Bird', hintStyle: const TextStyle(color: Colors.white38)),
                  ),
                ],
                const SizedBox(height: 14),

                const Text('Price (Rp)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _PriceInputFormatter(),
                  ],
                  decoration: _inputDeco().copyWith(
                    hintText: '0',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Available Tickets', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: availableController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDeco().copyWith(
                    hintText: '0',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Sales End', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final d = await _pickSalesEndDate(salesEndDate);
                          if (d != null) setModal(() => salesEndDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A3E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            salesEndDate != null ? _formatDate(salesEndDate!) : 'Pick date',
                            style: TextStyle(
                              color: salesEndDate != null ? Colors.white : Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await _pickSalesEndTime(salesEndTime);
                          if (t != null) setModal(() => salesEndTime = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A3E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            salesEndTime != null ? _formatTime(salesEndTime!) : 'Pick time',
                            style: TextStyle(
                              color: salesEndTime != null ? Colors.white : Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (salesEndError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      salesEndError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (salesEndDate != null) {
                        final eventDateTime = DateTime(
                          _selectedDate.year, _selectedDate.month, _selectedDate.day,
                          _selectedTime.hour, _selectedTime.minute,
                        );
                        final salesEndDateTime = DateTime(
                          salesEndDate!.year, salesEndDate!.month, salesEndDate!.day,
                          salesEndTime?.hour ?? 23, salesEndTime?.minute ?? 59,
                        );

                        if (salesEndDateTime.isAfter(eventDateTime) || salesEndDateTime.isAtSameMomentAs(eventDateTime)) {
                          setModal(() => salesEndError = 'Sales end must be before the event date/time');
                          return;
                        }
                      }

                      final finalType = selectedType == 'Other'
                          ? (customTypeController.text.trim().isEmpty ? 'Other' : customTypeController.text.trim())
                          : selectedType;

                      final newTicket = _TicketData(
                        type: finalType,
                        price: priceController.text.replaceAll('.', ''),
                        available: availableController.text,
                        salesEndDate: salesEndDate,
                        salesEndTime: salesEndTime,
                      );
                      setState(() {
                        if (editIndex != null) {
                          _tickets[editIndex] = newTicket;
                        } else {
                          _tickets.add(newTicket);
                        }
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0BCFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Save Ticket',
                      style: TextStyle(color: Color(0xFF3D2B6C), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco() => InputDecoration(
    filled: true,
    fillColor: const Color(0xFF2A2A3E),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit(String status) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = EventraSession.instance.userId;
    final eventId = widget.existingEvent?['id'];
    if (userId == null || eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update: missing event or user info')),
      );
      return;
    }

    if (status == 'live' && _tickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ticket before publishing')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final eventIdInt = (eventId is num) ? eventId.toInt() : int.tryParse(eventId.toString()) ?? 0;

      await PromotorApi.instance.updateEvent(
        userId: userId,
        eventId: eventIdInt,
        title: _titleController.text.trim(),
        artistName: _artistController.text.trim(),
        venue: _venueController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _selectedLocation ?? '',
        eventDate: _toApiDate(_selectedDate),
        eventTime: _toApiTime(_selectedTime),
        image: _imageBase64, // null if not changed -> backend keeps existing via COALESCE
        status: status,
        tickets: _tickets.map((t) => {
          'type': t.type,
          'price': t.price,
          'available': t.available,
          'sales_end_date': _ticketSalesEndDate(t),
          'sales_end_time': _ticketSalesEndTime(t),
        }).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'live' ? 'Event published!' : 'Saved as draft'),
          backgroundColor: const Color(0xFF2ECC71),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PromotorEventsPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    const Text(
                      'EVENTRA',
                      style: TextStyle(
                        color: Color(0xFFD0BCFF), fontSize: 18,
                        fontWeight: FontWeight.bold, letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main form card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0x4D1E1E2E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Event',
                                style: TextStyle(
                                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Image picker
                              _label('Event Image'),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A3E),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: _pickedImageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.memory(_pickedImageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                        )
                                      : _buildExistingImagePreview(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              _label('Event Title'),
                              TextFormField(
                                controller: _titleController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDeco(),
                                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                              ),
                              const SizedBox(height: 16),

                              _label('Artist Name'),
                              TextFormField(
                                controller: _artistController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDeco(),
                                validator: (v) => v == null || v.isEmpty ? 'Artist name is required' : null,
                              ),
                              const SizedBox(height: 16),

                              _label('Venue'),
                              TextFormField(
                                controller: _venueController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDeco(),
                                validator: (v) => v == null || v.isEmpty ? 'Venue is required' : null,
                              ),
                              const SizedBox(height: 16),

                              _label('Time'),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: _pillButton(_formatDate(_selectedDate)),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _pickTime,
                                    child: _pillButton(_formatTime(_selectedTime)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _label('Location'),
                              DropdownButtonFormField<String>(
                                value: _selectedLocation,
                                dropdownColor: const Color(0xFF1E1E2E),
                                style: const TextStyle(color: Colors.white),
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                                decoration: _inputDeco(),
                                items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                                onChanged: (v) => setState(() => _selectedLocation = v),
                                validator: (v) => v == null ? 'Location is required' : null,
                              ),
                              const SizedBox(height: 16),

                              _label('Description'),
                              TextFormField(
                                controller: _descriptionController,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 5,
                                decoration: _inputDeco(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () => _openTicketModal(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            decoration: BoxDecoration(
                              color: const Color(0x221E1E2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white38),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white54, size: 22),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Create Ticket',
                                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ..._tickets.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTicketCard(e.value, e.key),
                        )),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _isSubmitting ? null : () => _submit('draft'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFD0BCFF)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text(
                                    'Save as Draft',
                                    style: TextStyle(color: Color(0xFFD0BCFF), fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : () => _submit('live'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD0BCFF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3D2B6C)),
                                        )
                                      : const Text(
                                          'Publish Event',
                                          style: TextStyle(color: Color(0xFF3D2B6C), fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
  );

  Widget _pillButton(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF3D2B6C),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
  );

  Widget _buildTicketCard(_TicketData ticket, int index) {
    final badge = ticket.badgeInfo;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              ticket.type,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: badge['color'],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(badge['badge'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _openTicketModal(existing: ticket, editIndex: index),
                          child: const Icon(Icons.edit_square, color: Color(0xFFD0BCFF), size: 20),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => _tickets.removeAt(index)),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _bullet(ticket.description),
                _bullet('Ticket prices do not include local tax & service fee'),
                _bullet('Please note: each tickets is valid for 1 day'),
                if (ticket.formattedSalesEnd.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white54, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Sales end on ${ticket.formattedSalesEnd}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(30, (i) => Expanded(
                child: Container(height: 1, color: i.isEven ? Colors.white24 : Colors.transparent),
              )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.formattedPrice,
                  style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  ticket.available.isNotEmpty ? '${ticket.available} Available' : '- Available',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 13)),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4))),
      ],
    ),
  );
}