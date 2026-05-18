import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTopNavBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const MainTopNavBar({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF16111F),
        border: Border(
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SIDE (SEARCH & LOGO)
          Row(
            children: [
              GestureDetector(
                onTap: onSearchTap,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1, end: 1.05),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  builder: (context, double scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 18),
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

          /// RIGHT SIDE (NOTIFICATION)
          GestureDetector(
            onTap: onNotificationTap,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 1, end: 1.08),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeInOut,
              builder: (context, double scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 24,
                  ),
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD0BCFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}