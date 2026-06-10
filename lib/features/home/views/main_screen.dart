import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/data/tickets_notifier.dart';
import 'package:eventra/features/auth/views/login_page.dart';
import 'package:eventra/features/favorites/favorites_page.dart';
import 'package:eventra/features/explore/views/explore_page.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/ticket_type.dart';
import 'package:eventra/features/home/repositories/home_repository.dart';
import 'package:eventra/features/ticket/buy_ticket_page.dart';
import 'package:eventra/features/ticket/payment_page.dart';
import 'package:eventra/features/ticket/payment_status_page.dart';
import 'package:flutter/material.dart';
import 'package:eventra/core/constants/colors.dart';

//Import Page
import 'package:eventra/features/home/views/home_page.dart';
import 'package:eventra/features/home/views/notification_page.dart';
import 'package:eventra/features/ticket/my_tickets.dart';

import 'package:eventra/features/profile/profile_page.dart';

//Import Widget
import 'package:eventra/core/widgets/topbar.dart';
import 'package:eventra/core/widgets/navbar.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // HomeController dibuat di sini (bukan di dalam build) agar tidak
  // di-recreate setiap rebuild, dan bisa di-dispose dengan benar.
  late final HomeController _homeController;

  late int _currentIndex;
  bool _isSearchDropdownActive = false;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    if (!EventraSession.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      });
    }

    // HomeRepository → EventraDatabase → server.js → MySQL
    _homeController = HomeController(repository: const HomeRepository());
  }

  @override
  void dispose() {
    _homeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void toggleSearchPage() {
    setState(() {
      _isSearchDropdownActive = !_isSearchDropdownActive;
      if (!_isSearchDropdownActive) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void openNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventraSubpageShell(
          currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
          child: const NotificationPage(),
        ),
      ),
    );
  }

  NearbyEvent? _selectedEvent; // ← tambah variable ini
  NearbyEvent? _checkoutEvent;
  List<TicketType> _checkoutTickets = [];
  Map<String, dynamic>? _paymentResult;
  int _buyTicketReturnIndex = 0;

  void openBuyTicketPage(NearbyEvent event) {
    setState(() {
      _buyTicketReturnIndex = _currentIndex <= 4 ? _currentIndex : 0;
      _selectedEvent = event;
      _currentIndex = 5; // index khusus buy ticket
    });
  }

  void closeBuyTicketPage() {
    setState(() {
      _selectedEvent = null;
      _checkoutEvent = null;
      _checkoutTickets = [];
      _paymentResult = null;
      _currentIndex = _buyTicketReturnIndex;
    });
  }

  void openPaymentPage(NearbyEvent event, List<TicketType> tickets) {
    setState(() {
      _checkoutEvent = event;
      _checkoutTickets = tickets;
      _paymentResult = null;
      _currentIndex = 6;
    });
  }

  void closePaymentPage() {
    setState(() {
      _checkoutEvent = null;
      _checkoutTickets = [];
      _paymentResult = null;
      _currentIndex = _selectedEvent == null ? 0 : 5;
    });
  }

  void openPaymentStatus(Map<String, dynamic> payment) {
    TicketsNotifier.instance.notify();
    setState(() {
      _paymentResult = payment;
      _currentIndex = 7;
    });
  }

  void viewGeneratedTickets() {
    TicketsNotifier.instance.notify();
    setState(() {
      _selectedEvent = null;
      _checkoutEvent = null;
      _checkoutTickets = [];
      _paymentResult = null;
      _currentIndex = 2;
    });
  }

  void backHomeFromPaymentStatus() {
    setState(() {
      _selectedEvent = null;
      _checkoutEvent = null;
      _checkoutTickets = [];
      _paymentResult = null;
      _currentIndex = 0;
      _buyTicketReturnIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // EventraHomePage menerima controller — data ditarik dari MySQL
    final pages = [
      EventraHomePage(
        controller: _homeController,
        onEventTap: openBuyTicketPage,
        searchQuery: _searchQuery,
      ),
      ExplorePage(searchQuery: _searchQuery),
      EventraTicketsPage(
        searchQuery: _searchQuery,
        onBuyMore: () {
          setState(() {
            _currentIndex = 1;
            _selectedEvent = null;
            _checkoutEvent = null;
            _checkoutTickets = [];
            _paymentResult = null;
          });
        },
      ),
      EventraFavoritesPage(
        controller: _homeController,
        onEventTap: openBuyTicketPage,
        searchQuery: _searchQuery,
      ),
      const EventraProfilePage(),
      if (_selectedEvent != null)
        BuyTicketPage(
          event: _selectedEvent!,
          onBack: closeBuyTicketPage,
          onCheckout: openPaymentPage,
        ),
      if (_checkoutEvent != null)
        PaymentPage(
          event: _checkoutEvent!,
          tickets: _checkoutTickets,
          onBack: closePaymentPage,
          onPaymentComplete: openPaymentStatus,
        ),
      if (_paymentResult != null)
        PaymentStatusPage(
          payment: _paymentResult!,
          onViewTickets: viewGeneratedTickets,
          onBackHome: backHomeFromPaymentStatus,
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: SafeArea(
          child: Column(
            children: [
              /// TOP NAVBAR - MEMANGGIL COMPONENT DARI TOPBAR.DART
              MainTopNavBar(
                onSearchTap: toggleSearchPage,
                onNotificationTap: openNotificationPage,
              ),

              ///SEARCH BAR DROPDOWN
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSearchDropdownActive ? 75 : 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isSearchDropdownActive
                    ? Center(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: AppConfig.instance.text(
                              'search.hint',
                              'Search events, artists, tickets...',
                            ),
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF241B32),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: toggleSearchPage,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          onSubmitted: (_) {
                            if (_currentIndex > 4) {
                              setState(() => _currentIndex = 0);
                            }
                          },
                        ),
                      )
                    : const SizedBox(),
              ),

              /// PAGE CONTENT
              Expanded(
                child: IndexedStack(
                  index: _currentIndex > pages.length - 1 ? 0 : _currentIndex,
                  children: pages,
                ),
              ),
            ],
          ),
        ),
      ),

      /// BOTTOM NAVBAR - MEMANGGIL COMPONENT DARI NAVBAR.DART
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: MainNavBar(
          currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
          onTap: (index) {
            final previousIndex = _currentIndex;
            setState(() {
              _currentIndex = index;
              _selectedEvent = null;
              _checkoutEvent = null;
              _checkoutTickets = [];
              _paymentResult = null;
            });

            // Reload home data if navigating back to home tab from elsewhere
            if (index == 0 && previousIndex != 0) {
              _homeController.loadAll();
            }
          },
        ),
      ),
    );
  }
}
