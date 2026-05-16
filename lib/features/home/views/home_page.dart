
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraHomePage extends StatefulWidget {
  const EventraHomePage({super.key});

  @override
  State<EventraHomePage> createState() => _EventraHomePageState();
}

class _EventraHomePageState extends State<EventraHomePage> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  int selectedNav = 0;
  int carouselTick = 0;
  Duration countdown = const Duration(hours: 24);
  late Timer timer;
  
  final List<Map<String, dynamic>> featuredEvents = [
    {
      'title': 'NEON DREAMS:\n2026',
      'subtitle':
          'Experience the pinnacle of immersive audio-visual performance with the season\'s most anticipated lineup.',
      'image':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1200&auto=format&fit=crop',
      'tag1': 'FEATURED',
      'tag2': 'WORLD TOUR',
    },
    {
      'title': 'WORLD TOUR\nTOKYO',
      'subtitle':
          'Step into the future of live entertainment with exclusive visuals and world-class performances.',
      'image':
          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?q=80&w=1200&auto=format&fit=crop',
      'tag1': 'TRENDING',
      'tag2': 'LIVE EVENT',
    },
  ];

  final List<Map<String, dynamic>> passes = [
    {
      'title': 'VIP Backstage Pass',
      'desc':
          'An all-access journey behind the curtain of the global tour, includes a private stage-side lounge experience.',
      'price': '\$4,999',
    },
    {
      'title': 'Gold VIP Package',
      'desc':
          'Experience the show from the very front row with a dedicated fast seat and premium service.',
      'price': '\$1,200',
    },
    {
      'title': 'Infinity Station Access',
      'desc':
          'Elevate your viewing experience from our custom-built infinity stations.',
      'price': '\$850',
    },
  ];

  final List<Map<String, dynamic>> nearbyEvents = [
    {
      'title': 'Astra Project',
      'place': 'THE HIVE',
      'price': '\$50',
      'image':
          'https://images.unsplash.com/photo-1503095396549-807759245b35?q=80&w=1200&auto=format&fit=crop',
    },
    {
      'title': 'Echoes of Solace',
      'place': 'SKY ARENA',
      'price': '\$80',
      'image':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1200&auto=format&fit=crop',
    },
  ];
  List<bool> liked = [false, false, false];
  
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {

        /// COUNTDOWN
        if (countdown.inSeconds > 0) {
          countdown = countdown - const Duration(seconds: 1);
        }

        /// CAROUSEL
        carouselTick++;

        if (carouselTick >= 5) {
          carouselTick = 0;

          if (currentPage < featuredEvents.length - 1) {
            currentPage++;
          } else {
            currentPage = 0;
          }

          _pageController.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }
  
  @override
  void dispose() {
    timer.cancel();
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      bottomNavigationBar: Container(
        height: 75,
        decoration: const BoxDecoration(
          color: Color(0xFF16111F),
          border: Border(
            top: BorderSide(color: Colors.white10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home_outlined, 'HOME', 0),
            navItem(Icons.explore_outlined, 'EXPLORE', 1),
            navItem(Icons.confirmation_num_outlined, 'TICKETS', 2),
            navItem(Icons.favorite_border, 'FAVORITES', 3),
            navItem(Icons.person_outline, 'PROFILE', 4),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'EVENTRA',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD0BCFF),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// FEATURED CAROUSEL
                SizedBox(
                  height: 340,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: featuredEvents.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final event = featuredEvents[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: NetworkImage(event['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  topTag(event['tag1']),
                                  const SizedBox(width: 8),
                                  topTag(event['tag2']),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 34,
                                      height: 1,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    event['subtitle'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tickets Clicked'),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD0BCFF),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'GET TICKETS',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                /// LIMITED ACCESS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIMITED ACCESS',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Exclusive Drops',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2035),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${countdown.inHours.toString().padLeft(2, '0')} : '
                        '${(countdown.inMinutes % 60).toString().padLeft(2, '0')} : '
                        '${(countdown.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// PASSES
                /// PASSES
                Column(
                  children: passes.asMap().entries.map((entry) {
                    int index = entry.key;
                    var pass = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1526),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C4B7A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pass['title'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  pass['desc'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  pass['price'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              setState(() {
                                liked[index] = !liked[index];
                              });
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                liked[index]
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(liked[index]),
                                color: const Color(0xFFD0BCFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                /// NEAR YOU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Happening Near You',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nearbyEvents.length,
                    itemBuilder: (context, index) {
                      final item = nearbyEvents[index];

                      return Container(
                        width: 170,
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        item['image'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'MAY 20',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['title'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item['place'],
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['price'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C4DFF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final bool isSelected = selectedNav == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNav = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFFD0BCFF) : Colors.white70,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected
                  ? const Color(0xFFD0BCFF)
                  : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}