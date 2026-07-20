import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panel_widget.dart';
import '../../providers/geo_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/countries.dart';
import '../../models/map_models.dart';
import '../../providers/locale_provider.dart';

class GeoPanel extends StatelessWidget {
  const GeoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<GeoProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        return PanelWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(context, 'geo_title'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(context, 'geo_desc'),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(tr(context, 'geo_searching'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                        foregroundColor: Theme.of(context).colorScheme.surfaceTint,
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
                      child: Text('${tr(context, 'mark_visited').split(' ').first} ${countriesData[provider.detectedCountryCode!]?.getName(localeProvider.currentLocale) ?? provider.detectedCountryCode!} ${tr(context, 'visited').toLowerCase()}'),
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
