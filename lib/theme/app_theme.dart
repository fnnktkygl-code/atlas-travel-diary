import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgColor = Color(0xFF0B1121);
  static const Color textColor = Color(0xFFE2E8F0);
  
  static const Color mapBg = Color(0xFF0F172A);
  static const Color mapStroke = Color(0xFF1E293B);
  
  static const Color countryFill = Color(0xFF334155);
  static const Color countryHover = Color(0xFF475569);
  
  static const Color countryVisited = Color(0xFF10B981);
  static const Color countryVisitedHover = Color(0xFF34D399);
  
  static const Color countryLived = Color(0xFF3B82F6);
  static const Color countryLivedHover = Color(0xFF60A5FA);
  
  static const Color countryWishlist = Color(0xFFF59E0B);
  static const Color countryWishlistHover = Color(0xFFFBBF24);
  
  static const Color countryRedlist = Color(0xFF1E2433);
  static const Color countryRedlistHover = Color(0xFF2A3441);
  
  static const Color cityDot = Color(0xFFF8FAFC);
  
  static const Color panelBg = Color(0xFF0F172A);
  static const Color ink1 = Color(0xFF0B1121);
  
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textColor, fontFamily: 'Outfit'),
        titleLarge: TextStyle(color: textColor, fontFamily: 'Outfit'),
        headlineSmall: TextStyle(color: textColor, fontFamily: 'Outfit'),
      ),
      colorScheme: const ColorScheme.dark(
        primary: countryVisited,
        surface: mapBg,
      ),
    );
  }
}
