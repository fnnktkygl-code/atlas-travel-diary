import 'package:flutter/material.dart';

import '../models/map_models.dart';
import '../theme/app_theme.dart';

class ParsedMapGroup {
  final String id;
  final List<Path> paths;
  
  ParsedMapGroup({required this.id, required this.paths});
}

class WorldMapPainter extends CustomPainter {
  final List<ParsedMapGroup> parsedGroups;
  final Map<String, UserCountryData> userData;
  final String? hoveredCountryId;

  WorldMapPainter({
    required this.parsedGroups,
    required this.userData,
    this.hoveredCountryId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background ocean is drawn by the parent widget's Container

    final strokePaint = Paint()
      ..color = AppTheme.mapStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..strokeJoin = StrokeJoin.round;

    for (var group in parsedGroups) {
      final isHovered = group.id == hoveredCountryId;
      final status = userData[group.id]?.status ?? CountryStatus.none;

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = _getFillColor(status, isHovered);

      for (var path in group.paths) {
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  Color _getFillColor(CountryStatus status, bool isHovered) {
    switch (status) {
      case CountryStatus.visited:
        return isHovered ? AppTheme.countryVisitedHover : AppTheme.countryVisited;
      case CountryStatus.lived:
        return isHovered ? AppTheme.countryLivedHover : AppTheme.countryLived;
      case CountryStatus.wishlist:
        return isHovered ? AppTheme.countryWishlistHover : AppTheme.countryWishlist;
      case CountryStatus.none:
        return isHovered ? AppTheme.countryHover : AppTheme.countryFill;
    }
  }

  @override
  bool shouldRepaint(covariant WorldMapPainter oldDelegate) {
    return oldDelegate.hoveredCountryId != hoveredCountryId ||
           oldDelegate.userData != userData;
  }
}
