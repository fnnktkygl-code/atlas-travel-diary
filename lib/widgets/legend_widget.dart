import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(context, AppTheme.countryVisited, tr(context, 'visited')),
          _buildLegendItem(context, AppTheme.countryLived, tr(context, 'lived')),
          _buildLegendItem(context, AppTheme.countryWishlist, tr(context, 'wishlist')),
          _buildLegendItem(context, AppTheme.countryRedlist, tr(context, 'redlist')),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
