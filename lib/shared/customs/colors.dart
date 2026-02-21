import 'package:flutter/material.dart';

/// App brand colors for Urban Taxi Ride Maharashtra
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primaryYellow = Color(0xFFFFC200);
  static const Color primaryYellowLight = Color(0xFFFFF4CC);
  static const Color primaryOrange = Color(0xFFFFA100);

  // Neutral colors
  static const Color black = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundGrey = Color(0xFFF3F4F6);
  static const Color backgroundWhite = Color(0xFFEDEDED);

  // Accent colors
  static const Color blueLight = Color(0xFFEAF2FF);
  static const Color blue = Color(0xFF3F66A7);
  static const Color greenLight = Color(0xFFE9F7EF);

  // Status colors
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  // Grey shades
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black12 = Color(0x1F000000);

  // Border/Divider colors
  static const Color border = Color(0xFFE6E6E6);
  static const Color borderDark = Color(0xFFD0D0D0);
  static const Color divider = Color(0xFFEDEDED);

  // Surface/background variants (ticket, cards)
  static const Color surfaceOffWhite = Color(0xFFF8F8F5);
  static const Color thermalPaper = Color(0xFFF5F5F0);
  static const Color placeholderGrey = Color(0xFFE0E0E0);

  // Legacy/Deprecated - kept for gradual migration
  @Deprecated('Use black instead')
  static const Color textPrimary = Color(0xFF1A1A1A);
  @Deprecated('Use AppColors constants instead')
  static const Color grey = Color(0xFF757575);
  @Deprecated('Use border instead')
  static const Color lightGrey = Color(0xFFE6E6E6);
}
