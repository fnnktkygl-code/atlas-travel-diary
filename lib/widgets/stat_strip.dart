import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../models/map_models.dart';
import '../theme/app_theme.dart';

class StatStrip extends StatelessWidget {
  const StatStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        int visited = 0;
        int wishlist = 0;
        int lived = 0;
        
        for (var data in provider.userData.values) {
          if (data.status == CountryStatus.visited) visited++;
          if (data.status == CountryStatus.lived) lived++;
          if (data.status == CountryStatus.wishlist) wishlist++;
        }
        
        final totalExplored = visited + lived;
        final pctExplored = ((totalExplored / 188.0) * 100).toStringAsFixed(1);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          decoration: BoxDecoration(
            color: AppTheme.mapStroke,
            border: Border.all(color: AppTheme.mapStroke),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildCell('pays visités', '$totalExplored', false),
              _buildCell('du monde exploré', '$pctExplored%', true),
              _buildCell('pays habités', '$lived', false),
              _buildCell('envies de voyage', '$wishlist', false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(String label, String value, bool bump) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 1), // gap
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        color: AppTheme.mapBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: bump ? const Color(0xFFFBBF24) : AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.grey, // text-dim equivalent
              ),
            ),
          ],
        ),
      ),
    );
  }
}
