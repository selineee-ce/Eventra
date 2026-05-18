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
  int carouselTick = 0;
  int visibleNearbyCount = 4;

  Duration countdown = const Duration(hours: 24);

  late Timer timer;

  final List<Map<String, dynamic>> featuredEvents = [
    {
      'title': 'NEON DREAMS:\n2026',
      'subtitle':
        'Experience the pinnacle of immersive audio-visual performance with the season\'s most anticipated lineup.',
      'image': 'assets/images/image2.jpeg',
      'tag1': 'FEATURED',
      'tag2': 'WORLD TOUR',
      'button': 'GET TICKETS',
    },
    {
      'title': 'SONIC\nHORIZON',
      'subtitle':
        'Journey beyond the edge of sound with an avant-garde showcase of world-class electronic producers and light-bending stage craft.',
      'image': 'assets/images/image1.jpeg',
      'tag1': 'FAVOURITES',
      'tag2': 'EUROPE TOUR',
      'button': 'PREORDER NOW',
    },
    {
      'title': 'STARDUST\nECHOES',
      'subtitle':
        'Join thousands for an emotional journey through the year’s most iconic anthems.',
      'image': 'assets/images/image3.jpeg',
      'tag1': 'FAVOURITES',
      'button': 'GET TICKETS',
    },
  ];

  final List<Map<String, dynamic>> passes = [
    {
      'title': 'VIP Backstage Pass',
      'desc':
        'An all-access journey behind the curtain of the global tour.',
      'price': '\$4,999',
    },
    {
      'title': 'Gold VIP Package',
      'desc':
        'Experience the show from the very front row with premium service.',
      'price': '\$1,200',
    },
    {
      'title': 'Infinity Station Access',
      'desc':
        'Elevate your viewing experience from our infinity stations.',
      'price': '\$850',
    },
  ];

  final List<Map<String, dynamic>> nearbyEvents = [
    {
    'title': 'Astra Project',
    'date': 'MAY 20',
    'place': 'THE HIVE',
    'price': '\$50',
    'image':
      'https://images.unsplash.com/photo-1503095396549-807759245b35?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Echoes of Solace',
    'date': 'MAY 29',
    'place': 'SKY ARENA',
    'price': '\$80',
    'image':
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Nova Pulse',
    'date': 'JUN 02',
    'place': 'LUNA DOME',
    'price': '\$65',
    'image':
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Midnight Mirage',
    'date': 'JUN 10',
    'place': 'NEON CLUB',
    'price': '\$90',
    'image':
      'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Velvet Frequency',
    'date': 'JUN 18',
    'place': 'ORBIT HALL',
    'price': '\$70',
    'image':
      'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Lunar Echo',
    'date': 'JUN 22',
    'place': 'AETHER STAGE',
    'price': '\$75',
    'image':
      'https://images.unsplash.com/photo-1499364615650-ec38552f4f34?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Digital Bloom',
    'date': 'JUL 01',
    'place': 'NOVA HALL',
    'price': '\$60',
    'image':
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Afterlight',
    'date': 'JUL 08',
    'place': 'SPECTRA ARENA',
    'price': '\$95',
    'image':
      'https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Electric Aura',
    'date': 'JUL 15',
    'place': 'VOID CLUB',
    'price': '\$55',
    'image':
      'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?q=80&w=1200&auto=format&fit=crop',
    },
    {
    'title': 'Celestial Noise',
    'date': 'JUL 21',
    'place': 'COSMOS DOME',
    'price': '\$110',
    'image':
      'https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?q=80&w=1200&auto=format&fit=crop',
    }
  ];

  List<bool> liked = [false, false, false];

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          if (countdown.inSeconds > 0) {
            countdown -= const Duration(seconds: 1);
          }

          carouselTick++;

          if (carouselTick >= 5) {
            carouselTick = 0;

            currentPage =
                currentPage < featuredEvents.length - 1
                    ? currentPage + 1
                    : 0;

            _pageController.animateToPage(
              currentPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String get formattedCountdown {
    final hours = countdown.inHours.toString().padLeft(2, '0');

    final minutes =
        (countdown.inMinutes % 60).toString().padLeft(2, '0');

    final seconds =
        (countdown.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours : $minutes : $seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 12),

                buildFeaturedCarousel(),

                const SizedBox(height: 22),

                buildExclusiveHeader(),

                const SizedBox(height: 18),

                buildPasses(),

                const SizedBox(height: 18),

                buildNearYouHeader(),

                const SizedBox(height: 12),

                buildNearbyEvents(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFeaturedCarousel() {
    return SizedBox(
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

          return buildFeaturedCard(event);
        },
      ),
    );
  }

  Widget buildFeaturedCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        image: DecorationImage(
          image: AssetImage(event['image']),
          fit: BoxFit.cover,
        ),
      ),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              Color(0x33000000),
              Color(0xD9000000),
            ],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                topTag(event['tag1']),
                if (event['tag2'] != null) ...[
                  const SizedBox(width: 8),
                  topTag(event['tag2']),
                ],
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

                  child: buildPrimaryButton(event['button']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrimaryButton(String text) {
    return Container(
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
            text,

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
    );
  }

  Widget buildExclusiveHeader() {
    return Row(
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
            formattedCountdown,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasses() {
    return Column(
      children:
          passes.asMap().entries.map((entry) {
            final index = entry.key;
            final pass = entry.value;

            return buildPassCard(index, pass);
          }).toList(),
    );
  }

  Widget buildPassCard(
    int index,
    Map<String, dynamic> pass,
  ) {
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
  }

  Widget buildNearYouHeader() {
    return Row(
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
          onPressed: () {
            setState(() {
              visibleNearbyCount = 10;
            });
          },
          child: Text(
            'VIEW ALL',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNearbyEvents() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleNearbyCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, index) {
        final item = nearbyEvents[index];
        return buildNearbyCard(item);
      },
    );
  }

  Widget buildNearbyCard(Map<String, dynamic> item) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 175,
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
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        item['date'],

                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),
        ],
      ),
    );
  }

  Widget topTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

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
}