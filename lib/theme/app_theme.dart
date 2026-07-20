import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors (Status) - Same for Light & Dark
  static const Color countryVisited = Color(0xFF10B981);
  static const Color countryVisitedHover = Color(0xFF34D399);
  
  static const Color countryLived = Color(0xFF3B82F6);
  static const Color countryLivedHover = Color(0xFF60A5FA);
  
  static const Color countryWishlist = Color(0xFFF59E0B);
  static const Color countryWishlistHover = Color(0xFFFBBF24);
  
  static const Color countryRedlist = Color(0xFF1E2433);
  static const Color countryRedlistHover = Color(0xFF2A3441);
  
  static const Color cityDot = Color(0xFFF8FAFC);

  // Dark Theme Colors
  static const Color _darkBgColor = Color(0xFF0B1121);
  static const Color _darkTextColor = Color(0xFFE2E8F0);
  static const Color _darkMapBg = Color(0xFF0F172A);
  static const Color _darkMapStroke = Color(0xFF1E293B);
  static const Color _darkCountryFill = Color(0xFF334155);
  static const Color _darkCountryHover = Color(0xFF475569);
  static const Color _darkPanelBg = Color(0xFF0F172A);
  static const Color _darkInk1 = Color(0xFF0B1121);

  // Light Theme Colors
  static const Color _lightBgColor = Color(0xFFF1F5F9); // slate-100
  static const Color _lightTextColor = Color(0xFF0F172A); // slate-900
  static const Color _lightMapBg = Color(0xFFFFFFFF); // white
  static const Color _lightMapStroke = Color(0xFFCBD5E1); // slate-300
  static const Color _lightCountryFill = Color(0xFFE2E8F0); // slate-200
  static const Color _lightCountryHover = Color(0xFF94A3B8); // slate-400
  static const Color _lightPanelBg = Color(0xFFFFFFFF); // white
  static const Color _lightInk1 = Color(0xFFF8FAFC); // slate-50

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBgColor,
      cardColor: _darkPanelBg,
      dividerColor: _darkMapStroke,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _darkTextColor, fontFamily: 'Outfit'),
        titleLarge: TextStyle(color: _darkTextColor, fontFamily: 'Outfit'),
        headlineSmall: TextStyle(color: _darkTextColor, fontFamily: 'Outfit'),
      ),
      colorScheme: const ColorScheme.dark(
        primary: countryVisited,
        surface: _darkMapBg,
        onSurface: _darkTextColor,
        outline: _darkMapStroke,
        surfaceContainer: _darkCountryFill,
        surfaceContainerHigh: _darkCountryHover,
        surfaceTint: _darkInk1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBgColor,
      cardColor: _lightPanelBg,
      dividerColor: _lightMapStroke,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _lightTextColor, fontFamily: 'Outfit'),
        titleLarge: TextStyle(color: _lightTextColor, fontFamily: 'Outfit'),
        headlineSmall: TextStyle(color: _lightTextColor, fontFamily: 'Outfit'),
      ),
      colorScheme: const ColorScheme.light(
        primary: countryVisited,
        surface: _lightMapBg,
        onSurface: _lightTextColor,
        outline: _lightMapStroke,
        surfaceContainer: _lightCountryFill,
        surfaceContainerHigh: _lightCountryHover,
        surfaceTint: _lightInk1,
      ),
    );
  }
}
