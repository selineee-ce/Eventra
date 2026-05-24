import 'package:eventra/data/app_config.dart';
import 'package:eventra/features/favorites/favorites_page.dart';
import 'package:eventra/features/explore/artists/trending_artists.dart';
import 'package:eventra/features/home/controllers/home_controller.dart';
import 'package:eventra/features/home/repositories/home_repository.dart';
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // HomeController dibuat di sini (bukan di dalam build) agar tidak
  // di-recreate setiap rebuild, dan bisa di-dispose dengan benar.
  late final HomeController _homeController;

  int _currentIndex = 0;
  bool _isSearchDropdownActive = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      }
    });
  }

  void openNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // EventraHomePage menerima controller — data ditarik dari MySQL
    final pages = [
      EventraHomePage(controller: _homeController),
      const TrendingArtistsPage(),
      const EventraTicketsPage(),
      const EventraFavoritesPage(),
      const EventraProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainAppBackground,
        ),
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            suffixIcon: GestureDetector(
                              onTap: toggleSearchPage,
                              child: const Icon(Icons.close, color: Colors.white54),
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      )
                    : const SizedBox(),
              ),

              /// PAGE CONTENT
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
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
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
