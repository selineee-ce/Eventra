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
  int _currentIndex = 0;
  bool _isSearchDropdownActive = false;

  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _pages = [
    const EventraHomePage(),
    const Center(child: Text("Explore Page", style: TextStyle(color: Colors.white, fontSize: 20))),
    const EventraTicketsPage(),
    const Center(child: Text("Favorites Page", style: TextStyle(color: Colors.white, fontSize: 20))),
    // const EventraExplorePage(),  
    // const EventraFavoritesPage(),
    const EventraProfilePage(),  
  ];

  @override
  void dispose() {
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
                            hintText: 'Search events, artists, tickets...',
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
                              onTap: toggleSearchPage, // Klik silang untuk menutup dropdown search
                              child: const Icon(Icons.close, color: Colors.white54),
                            ),
                          ),
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                      )
                    : const SizedBox(),
              ),

              /// PAGE CONTENT
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
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