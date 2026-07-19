import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../widgets/world_map_widget.dart';
import '../widgets/stat_strip.dart';
import '../widgets/sidebar_widget.dart';

import '../models/map_models.dart';
import '../data/countries.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  void _showAddCountryModal(BuildContext context, String countryId, MapProvider provider) {
    provider.selectCountry(countryId); // Select it so sidebar updates too
    final countryInfo = countriesData[countryId];
    final name = countryInfo?.name ?? countryId;
    final currentData = provider.userData[countryId];
    final isVisited = currentData?.status == CountryStatus.visited || currentData?.status == CountryStatus.lived;
    final isWish = currentData?.status == CountryStatus.wishlist;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajouter $name',
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: Text(isVisited ? 'Déjà marqué comme visité' : 'Marquer comme visité'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVisited ? AppTheme.countryVisited : AppTheme.panelBg,
                  foregroundColor: isVisited ? AppTheme.ink1 : AppTheme.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  provider.markCountryStatus(countryId, isVisited ? CountryStatus.none : CountryStatus.visited);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.favorite_border),
                label: Text(isWish ? 'Déjà dans la liste d\'envies' : 'Ajouter à la liste d\'envies'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWish ? AppTheme.countryWishlist : AppTheme.panelBg,
                  foregroundColor: isWish ? AppTheme.ink1 : AppTheme.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  provider.markCountryStatus(countryId, isWish ? CountryStatus.none : CountryStatus.wishlist);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas - Carnet de voyage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, child) {
          final mapWidget = WorldMapWidget(
            userData: provider.userData,
            onCountryTap: provider.selectCountry,
            onCountryDoubleTap: (id) => _showAddCountryModal(context, id, provider),
          );

          return Column(
            children: [
              const StatStrip(),
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: mapWidget),
                          const SizedBox(
                            width: 340,
                            child: SidebarWidget(),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          SizedBox(
                            height: 400,
                            child: mapWidget,
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SidebarWidget(),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


