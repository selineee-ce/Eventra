import 'package:flutter/material.dart';
import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:eventra/features/promotor/views/promotor_dashboard.dart';
import 'package:eventra/features/promotor/views/promotor_events_page.dart';
import 'package:eventra/features/promotor/views/promotor_profile_page.dart';

class PromotorAnalyticsPage extends StatefulWidget {
  const PromotorAnalyticsPage({super.key});

  @override
  State<PromotorAnalyticsPage> createState() => _PromotorAnalyticsPageState();
}

class _PromotorAnalyticsPageState extends State<PromotorAnalyticsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _fansByLocation = [];
  int _totalFans = 0;

  bool _showAllRevenue = false;
  bool _showAllSellThrough = false;
  bool _showAllFans = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = EventraSession.instance.userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final eventsFuture = PromotorApi.instance.fetchEvents(userId);
      final fansFuture = PromotorApi.instance.fetchFansByLocation(userId);

      final events = await eventsFuture;
      print('[Analytics] fetched events: ${events.length}');
      print('[Analytics] statuses: ${events.map((e) => e['status']).toList()}');
      final fansResult = await fansFuture;
      print('[Analytics] fansResult: $fansResult');

      if (!mounted) return;

      final fansData = (fansResult['data'] is List)
          ? List<Map<String, dynamic>>.from(
              (fansResult['data'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
            )
          : <Map<String, dynamic>>[];
      print('[Analytics] fansData parsed: ${fansData.length}');

      setState(() {
        _events = events.where((e) => e['status'] == 'live' || e['status'] == 'completed').toList();
        print('[Analytics] _events set: ${_events.length}');
        _fansByLocation = fansData;
        _totalFans = _toInt(fansResult['totalFans']);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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

  double _sellThroughRate(Map<String, dynamic> event) {
    final sold = _toInt(event['ticket_sold']);
    final total = _toInt(event['ticket_total']);
    if (total == 0) return 0;
    return (sold / total).clamp(0.0, 1.0);
  }

  Map<String, dynamic>? get _topEvent {
    if (_events.isEmpty) return null;
    final sorted = [..._events]
      ..sort((a, b) => _toInt(b['revenue']).compareTo(_toInt(a['revenue'])));
    return sorted.first;
  }

  Map<String, dynamic>? get _needsAttentionEvent {
    final liveEvents = _events.where((e) => e['status'] == 'live').toList();
    if (liveEvents.isEmpty) return null;
    final sorted = [...liveEvents]
      ..sort((a, b) => _sellThroughRate(a).compareTo(_sellThroughRate(b)));
    return sorted.first;
  }

  int get _maxRevenue {
    if (_events.isEmpty) return 1;
    final max = _events.map((e) => _toInt(e['revenue'])).reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1 : max;
  }

  int get _maxFanCount {
    if (_fansByLocation.isEmpty) return 1;
    final max = _fansByLocation.map((f) => _toInt(f['fanCount'])).reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1 : max;
  }

  List<Map<String, dynamic>> get _sortedByRevenue {
    final sorted = [..._events]
      ..sort((a, b) => _toInt(b['revenue']).compareTo(_toInt(a['revenue'])));
    return sorted;
  }

  List<Map<String, dynamic>> get _sortedBySellThrough {
    final sorted = [..._events]
      ..sort((a, b) => _sellThroughRate(b).compareTo(_sellThroughRate(a)));
    return sorted;
  }

  List<Map<String, dynamic>> get _sortedByFans {
    final sorted = [..._fansByLocation]
      ..sort((a, b) => _toInt(b['fanCount']).compareTo(_toInt(a['fanCount'])));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.search, color: Colors.white, size: 24),
                    Text('EVENTRA',
                        style: TextStyle(
                            color: const Color(0xFFD0BCFF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
                  : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Performance insights across your events',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        if (_events.isEmpty)
                          _buildEmptyState()
                        else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildTopEventCard()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildAttentionEventCard()),
                            ],
                          ),
                          const SizedBox(height: 28),

                          Text(
                            'Revenue per Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...(_showAllRevenue ? _sortedByRevenue : _sortedByRevenue.take(3))
                              .map((e) => _buildRevenueBar(e)),
                          if (_sortedByRevenue.length > 3)
                            _buildViewAllButton(
                              isExpanded: _showAllRevenue,
                              onTap: () => setState(() => _showAllRevenue = !_showAllRevenue),
                            ),
                          const SizedBox(height: 28),

                          Text(
                            'Sell-Through Rate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...(_showAllSellThrough ? _sortedBySellThrough : _sortedBySellThrough.take(3))
                              .map((e) => _buildSellThroughRow(e)),
                          if (_sortedBySellThrough.length > 3)
                            _buildViewAllButton(
                              isExpanded: _showAllSellThrough,
                              onTap: () => setState(() => _showAllSellThrough = !_showAllSellThrough),
                            ),
                          const SizedBox(height: 28),
                        ],

                        Text(
                          'Fan Geography',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalFans total fans following your artist profile',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        if (_fansByLocation.isEmpty)
                          _buildFanEmptyState()
                        else ...[
                          ...(_showAllFans ? _sortedByFans : _sortedByFans.take(3))
                              .map((f) => _buildFanLocationBar(f)),
                          if (_sortedByFans.length > 3)
                            _buildViewAllButton(
                              isExpanded: _showAllFans,
                              onTap: () => setState(() => _showAllFans = !_showAllFans),
                            ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart_outlined, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(
            'No analytics yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Publish an event to start seeing performance data.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFanEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        'No fans have followed your artist profile yet.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 13),
      ),
    );
  }

  Widget _buildTopEventCard() {
    final event = _topEvent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0BCFF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'TOP EVENT',
                style: TextStyle(
                  color: const Color(0xFFD0BCFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event?['title']?.toString() ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event != null ? _formatRupiah(_toInt(event['revenue'])) : 'Rp0',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionEventCard() {
    final event = _needsAttentionEvent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📉', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'NEEDS ATTENTION',
                style: TextStyle(
                  color: const Color(0xFFFFB347),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event?['title']?.toString() ?? 'All caught up',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event != null
                ? '${(_sellThroughRate(event) * 100).toStringAsFixed(0)}% sold'
                : 'No live events',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBar(Map<String, dynamic> event) {
    final revenue = _toInt(event['revenue']);
    final ratio = revenue / _maxRevenue;
    final isTop = _topEvent != null && event['id'] == _topEvent!['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event['title']?.toString() ?? 'Untitled',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatRupiah(revenue),
                style: TextStyle(
                  color: isTop ? const Color(0xFFD0BCFF) : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTop ? const Color(0xFFD0BCFF) : const Color(0xFF8B7AB0),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellThroughRow(Map<String, dynamic> event) {
    final rate = _sellThroughRate(event);
    final percent = (rate * 100).toStringAsFixed(0);

    String badge;
    Color badgeColor;
    if (rate >= 1.0) {
      badge = 'SOLD OUT';
      badgeColor = const Color(0xFF2ECC71);
    } else if (rate >= 0.7) {
      badge = 'HIGH';
      badgeColor = const Color(0xFF2ECC71);
    } else if (rate >= 0.4) {
      badge = 'MEDIUM';
      badgeColor = const Color(0xFFFFB347);
    } else {
      badge = 'LOW';
      badgeColor = const Color(0xFFFF6B7A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event['title']?.toString() ?? 'Untitled',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                    minHeight: 7,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFanLocationBar(Map<String, dynamic> fan) {
    final location = fan['location']?.toString() ?? 'Unknown';
    final count = _toInt(fan['fanCount']);
    final ratio = count / _maxFanCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFD0BCFF), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$count ${count == 1 ? 'fan' : 'fans'}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF56C7FF)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton({required bool isExpanded, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isExpanded ? 'SHOW LESS' : 'VIEW ALL',
              style: TextStyle(
                color: const Color(0xFFD0BCFF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFFD0BCFF),
              size: 18,
            ),
          ],
        ),
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
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PromotorDashboard(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_outlined, color: Color(0xFFB3B3B3), size: 24),
                const SizedBox(height: 4),
                Text('HOME',
                    style: TextStyle(
                        color: const Color(0xFFB3B3B3), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PromotorEventsPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFB3B3B3), size: 26),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: const Icon(Icons.star, color: Color(0xFFB3B3B3), size: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('EVENTS',
                    style: TextStyle(
                        color: const Color(0xFFB3B3B3), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.bar_chart_rounded, color: Color(0xFFB3B3B3), size: 24),
                  ],
                ),
                const SizedBox(height: 4),
                Text('ANALYTICS',
                    style: TextStyle(
                        color: const Color(0xFFD0BCFF), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PromotorProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, color: Color(0xFFB3B3B3), size: 24),
                const SizedBox(height: 4),
                Text('PROFILE',
                    style: TextStyle(
                        color: const Color(0xFFB3B3B3), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}