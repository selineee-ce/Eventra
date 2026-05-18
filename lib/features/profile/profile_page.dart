import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // --- PROFILE HEADER ---
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                child: Icon(Icons.person, size: 80, color: Colors.white24),
              ),
              const SizedBox(height: 15),
              Text(
                "Sabrina Aryan",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "DIAMOND MEMBER | NYC",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD0BCFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),

              // --- EDIT PROFILE BUTTON ---
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFF4D2B6C)),
                  label: Text(
                    "EDIT PROFILE",
                    style: GoogleFonts.poppins(color: Color(0xFF4D2B6C), fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0BCFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- STATS CARDS ---
              Row(
                children: [
                  _buildStatCard("24", "UPCOMING EVENTS"),
                  const SizedBox(width: 15),
                  _buildStatCard("158", "POINTS EARNED"),
                ],
              ),
              const SizedBox(height: 30),

              // --- ACCOUNT SETTINGS LIST ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ACCOUNT SETTINGS",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildSettingsItem(Icons.favorite_border, "Favourites"),
              _buildSettingsItem(Icons.download_outlined, "Downloads"),
              _buildSettingsItem(Icons.language, "Languages", trailingText: "ENGLISH (US)"),
              _buildSettingsItem(Icons.location_on_outlined, "Location"),
              _buildSettingsItem(Icons.subscriptions_outlined, "Subscription", trailingText: "PREMIUM ACTIVE"),
              _buildSettingsItem(Icons.dark_mode_outlined, "Display", trailingText: "DARK"),

              const SizedBox(height: 30),

              // --- LOGOUT BUTTON ---
              GestureDetector(
                onTap: () {
                  // Tambahkan logika logout di sini
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Color(0xFFFFB7AE), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "LOG OUT",
                      style: GoogleFonts.poppins(
                        color: Color(0xFFFFB7AE),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Statistik
  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1526),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                color: Color(0xFFCFBBFD),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Item Pengaturan
  Widget _buildSettingsItem(IconData icon, String title, {String? trailingText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x331E1E2E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD0BCFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD0BCFF), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }
}