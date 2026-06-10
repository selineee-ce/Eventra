import 'package:flutter/material.dart';
import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/features/promotor/views/promotor_events_page.dart';
import 'package:eventra/features/profile/profile_page.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/promotor/views/promotor_create_event_page.dart';

class PromotorDashboard extends StatefulWidget {
  const PromotorDashboard({super.key});

  @override
  State<PromotorDashboard> createState() => _PromotorDashboardState();
}

class _PromotorDashboardState extends State<PromotorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  String _promotorName = '';
  String _totalRevenue = 'Rp0';
  String _ticketSold = '0';
  String _activeEvent = '0';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final userId = EventraSession.instance.userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await EventraDatabase.instance.fetchProfile();
      final name = profile['name'] as String? ?? 'Promotor';

      final dashboard = await PromotorApi.instance.fetchDashboard(userId);
      final stats = dashboard['dashboard'] as Map<String, dynamic>? ?? {};

      final revenue = (stats['total_revenue'] as num?)?.toInt() ?? 0;
      final sold = (stats['ticket_sold'] as num?)?.toInt() ?? 0;
      final active = (stats['active_events'] as num?)?.toInt() ?? 0;

      if (!mounted) return;
      setState(() {
        _promotorName = name;
        _totalRevenue = _formatRupiah(revenue);
        _ticketSold = sold.toString();
        _activeEvent = active.toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                    const Text(
                      'EVENTRA',
                      style: TextStyle(
                        color: Color(0xFFD0BCFF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Icon(
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
                  : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROMOTOR DASHBOARD',
                        style: TextStyle(
                          color: Color(0xFFD0BCFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Welcome back, $_promotorName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PromotorCreateEventPage()),
                          ).then((_) => _loadDashboard());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0BCFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                        child: const Text(
                          '+ Create Event',
                          style: TextStyle(
                            color: Color(0xFF3D2B6C),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      _buildStatCard(
                        title: 'Total Revenue (30 d)',
                        value: _totalRevenue,
                        valueColor: const Color(0xFFD0BCFF),
                        icon: Icons.attach_money_outlined,
                      ),
                      const SizedBox(height: 12),

                      _buildStatCard(
                        title: 'Ticket Sold',
                        value: _ticketSold,
                        valueColor: const Color(0xFFD0BCFF),
                        icon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(height: 12),

                      _buildStatCard(
                        title: 'Active Event',
                        value: _activeEvent,
                        valueColor: const Color(0xFFD0BCFF),
                        icon: Icons.calendar_month_outlined,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x4D1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x33D0BCFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD0BCFF),
              size: 22,
            ),
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
            onTap: () => setState(() => _selectedIndex = 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  color: _selectedIndex == 0 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text('HOME', style: TextStyle(
                  color: _selectedIndex == 0 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                  fontSize: 10, fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PromotorEventsPage()),
              );
            },
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
                Text('EVENTS', style: TextStyle(
                  color: _selectedIndex == 1 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                  fontSize: 10, fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventraProfilePage()),
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
                Text('PROFILE', style: TextStyle(
                  color: _selectedIndex == 2 ? const Color(0xFFD0BCFF) : const Color(0xFFB3B3B3),
                  fontSize: 10, fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}