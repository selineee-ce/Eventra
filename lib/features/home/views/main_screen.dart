import 'package:eventra/features/home/views/home_page.dart';
import 'package:eventra/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:eventra/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final TextEditingController _searchController =
      TextEditingController();

  final List<Widget> _pages = [
    const EventraHomePage(),

    /// SEARCH PAGE
    const Center(
      child: Text(
        "Search Page",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    ),

    /// TICKETS PAGE
    const Center(
      child: Text(
        "Tickets Page",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    ),

    /// WISHLIST PAGE
    const Center(
      child: Text(
        "Wishlist Page",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    ),

    /// PROFILE PAGE
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// OPEN SEARCH PAGE
  void openSearchPage() {
    setState(() {
      _currentIndex = 1;
    });
  }

  /// OPEN NOTIFICATION PAGE
  void openNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const NotificationPage(),
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
              /// TOP NAVBAR
              Container(
                height: 70,

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                decoration: const BoxDecoration(
                  color: Color(0xFF16111F),

                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white10,
                    ),
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    /// LEFT SIDE
                    Row(
                      children: [
                        /// SEARCH BUTTON
                        GestureDetector(
                          onTap: openSearchPage,

                          child: TweenAnimationBuilder(
                            tween: Tween<double>(
                              begin: 1,
                              end: 1.05,
                            ),

                            duration:
                                const Duration(
                              milliseconds: 1200,
                            ),

                            curve: Curves.easeInOut,

                            builder: (
                              context,
                              double scale,
                              child,
                            ) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },

                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        /// LOGO
                        Text(
                          'EVENTRA',

                          style:
                              GoogleFonts.poppins(
                            color:
                                const Color(
                              0xFFD0BCFF,
                            ),

                            fontSize: 26,

                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    /// NOTIFICATION BUTTON
                    GestureDetector(
                      onTap: openNotificationPage,

                      child: TweenAnimationBuilder(
                        tween: Tween<double>(
                          begin: 1,
                          end: 1.08,
                        ),

                        duration:
                            const Duration(
                          milliseconds: 1400,
                        ),

                        curve: Curves.easeInOut,

                        builder: (
                          context,
                          double scale,
                          child,
                        ) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },

                        child: Stack(
                          children: [
                            const Icon(
                              Icons
                                  .notifications_none,
                              color: Colors.white,
                              size: 24,
                            ),

                            Positioned(
                              right: 1,
                              top: 1,

                              child: Container(
                                width: 8,
                                height: 8,

                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color(
                                    0xFFD0BCFF,
                                  ),

                                  shape:
                                      BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// SEARCH BAR ANIMATION
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 300),

                height:
                    _currentIndex == 1 ? 75 : 0,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: _currentIndex == 1
                    ? Center(
                        child: TextField(
                          controller:
                              _searchController,

                          autofocus: true,

                          style: const TextStyle(
                            color: Colors.white,
                          ),

                          decoration:
                              InputDecoration(
                            hintText:
                                'Search events, artists, tickets...',

                            hintStyle:
                                const TextStyle(
                              color:
                                  Colors.white38,
                            ),

                            filled: true,

                            fillColor:
                                const Color(
                              0xFF241B32,
                            ),

                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                30,
                              ),

                              borderSide:
                                  BorderSide
                                      .none,
                            ),

                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 20,
                            ),

                            prefixIcon:
                                const Icon(
                              Icons.search,
                              color:
                                  Colors.white54,
                            ),

                            suffixIcon:
                                GestureDetector(
                              onTap: () {
                                _searchController
                                    .clear();
                              },

                              child:
                                  const Icon(
                                Icons.close,
                                color: Colors
                                    .white54,
                              ),
                            ),
                          ),

                          onChanged: (value) {
                            /// FILTER EVENTS HERE
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

      /// BOTTOM NAVBAR
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),

        child: BottomNavigationBar(
          currentIndex: _currentIndex,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,

          backgroundColor:
              const Color(0xFF16111F),

          selectedItemColor:
              AppColors.primaryPurple,

          unselectedItemColor:
              Colors.white54,

          selectedFontSize: 11,
          unselectedFontSize: 11,

          elevation: 0,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.explore_outlined),
              activeIcon:
                  Icon(Icons.explore),
              label: 'EXPLORE',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.airplane_ticket_outlined,
              ),
              activeIcon:
                  Icon(Icons.airplane_ticket),
              label: 'TICKETS',
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.favorite_border),
              activeIcon:
                  Icon(Icons.favorite),
              label: 'WISHLIST',
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.person_outline),
              activeIcon:
                  Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}

/// NOTIFICATION PAGE
class NotificationPage
    extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0E0717),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF16111F),

        elevation: 0,

        title: Text(
          'Notifications',

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          notificationCard(
            title:
                'New VIP Access Released',

            subtitle:
                'Exclusive backstage passes are now available.',
          ),

          notificationCard(
            title: 'Event Reminder',

            subtitle:
                'Neon Dreams starts in 5 hours.',
          ),

          notificationCard(
            title: 'Preorder Open',

            subtitle:
                'Preorder tickets for World Tour Tokyo.',
          ),
        ],
      ),
    );
  }

  Widget notificationCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: const Color(
                0xFFD0BCFF,
              ).withOpacity(0.15),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons.notifications_active,
              color: Color(0xFFD0BCFF),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style:
                      GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
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