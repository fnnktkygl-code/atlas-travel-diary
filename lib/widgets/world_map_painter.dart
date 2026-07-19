import 'dart:ui' as ui;
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

      if (status == CountryStatus.redlist) {
        fillPaint.shader = null; // reset just in case
        // Custom discrete hatched shader
        fillPaint.shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(8, 8),
          [
            _getFillColor(status, isHovered),
            _getFillColor(status, isHovered),
            const Color(0x33000000), // slightly darker line
            const Color(0x33000000),
          ],
          [0.0, 0.5, 0.5, 1.0],
          TileMode.repeated,
        );
      }

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
      case CountryStatus.redlist:
        return isHovered ? AppTheme.countryRedlistHover : AppTheme.countryRedlist;
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
