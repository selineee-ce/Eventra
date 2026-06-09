import 'package:flutter/material.dart';

class AppColors {
  // Navigation Bar
  static const Color primaryPurple = Color(0xFF8F6DDD); // Warna aktif navbar
  static const Color navBackground = Color(0xFF121114); // Background navbar
  static const Color inactiveGrey = Color(0xFFB3B3B3);  // Warna tidak aktif

  // Background Gradient Color
  static const Color bgStop0 = Color(0xFF241D34); // Stop 0%
  static const Color bgStop50 = Color(0xFF1B1727); // Stop 50%
  static const Color bgStop100 = Color(0xFF1E2634); // Stop 100%

  static const LinearGradient mainAppBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [
      bgStop0,
      bgStop50,
      bgStop100,
    ],
  );

}