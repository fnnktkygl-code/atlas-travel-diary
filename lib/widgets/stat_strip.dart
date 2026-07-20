import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../models/map_models.dart';
import '../theme/app_theme.dart';
import '../data/countries.dart';

class StatStrip extends StatelessWidget {
  const StatStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        int visited = 0;
        int wishlist = 0;
        int lived = 0;
        int redlistCount = 0;
        int citiesCount = 0;
        
        double exploredArea = 0.0;
        double redlistArea = 0.0;
        double totalGlobalArea = 0.0;
        
        for (var c in countriesData.values) {
           totalGlobalArea += c.area;
        }
        
        for (var entry in provider.userData.entries) {
          final id = entry.key;
          final status = entry.value.status;
          final area = countriesData[id]?.area ?? 0.0;
          
          if (status == CountryStatus.visited) {
            visited++;
            exploredArea += area;
            citiesCount += entry.value.cities.length;
          } else if (status == CountryStatus.lived) {
            lived++;
            exploredArea += area;
            citiesCount += entry.value.cities.length;
          } else if (status == CountryStatus.wishlist) {
            wishlist++;
          } else if (status == CountryStatus.redlist) {
            redlistCount++;
            redlistArea += area;
          }
        }
        
        final totalExplored = visited + lived;
        final totalCountriesDenominator = (countriesData.length - redlistCount).clamp(1.0, 999.0);
        final pctCountries = ((totalExplored / totalCountriesDenominator) * 100).toStringAsFixed(1);
        
        final totalAreaDenominator = (totalGlobalArea - redlistArea).clamp(1.0, double.infinity);
        final pctArea = ((exploredArea / totalAreaDenominator) * 100).toStringAsFixed(1);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          decoration: BoxDecoration(
            color: AppTheme.mapStroke,
            border: Border.all(color: AppTheme.mapStroke),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildCell('pays explorés', '$totalExplored', false),
              _buildCell('% pays monde', '$pctCountries%', true),
              _buildCell('% surface monde', '$pctArea%', true),
              _buildCell('villes visitées', '$citiesCount', false),
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
