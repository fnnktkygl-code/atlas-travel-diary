import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panel_widget.dart';
import '../../providers/geo_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/countries.dart';
import '../../models/map_models.dart';

class GeoPanel extends StatelessWidget {
  const GeoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GeoProvider>(
      builder: (context, provider, child) {
        return PanelWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📍 Détection de localisation',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vous propose d\'ajouter un pays quand vous y êtes',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: provider.isAutoTracking,
                    onChanged: provider.toggleAutoTracking,
                    activeTrackColor: AppTheme.countryVisited.withValues(alpha: 0.5),
                    activeThumbColor: AppTheme.countryVisited,
                  ),
                ],
              ),
              if (provider.isAutoTracking) ...[
                const SizedBox(height: 16),
                if (provider.isLocating)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Recherche...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  )
                else ...[
                  Text(
                    provider.statusMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (provider.detectedCountryCode != null &&
                      (provider.mapProvider.userData[provider.detectedCountryCode]?.status ?? CountryStatus.none) != CountryStatus.visited &&
                      (provider.mapProvider.userData[provider.detectedCountryCode]?.status ?? CountryStatus.none) != CountryStatus.lived) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.countryVisited,
                        foregroundColor: AppTheme.ink1,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        provider.mapProvider.markCountryStatus(
                          provider.detectedCountryCode!,
                          CountryStatus.visited,
                        );
                        // Stop locating after marking visited
                        provider.toggleAutoTracking(false);
                      },
                      child: Text('Marquer ${countriesData[provider.detectedCountryCode!]?.name ?? provider.detectedCountryCode!} comme visité'),
                    ),
                  ],
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
