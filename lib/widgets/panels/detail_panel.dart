import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../models/map_models.dart';
import '../../data/countries.dart';
import 'panel_widget.dart';
import '../../theme/app_theme.dart';

class DetailPanel extends StatelessWidget {
  const DetailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        final selectedId = provider.selectedCountryId;
        
        if (selectedId == null) {
          return const PanelWidget(
            title: 'Pays sélectionné',
            child: Text(
              'Cliquez sur un pays de la carte, ou utilisez la recherche, pour voir ses détails et ajouter un voyage.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        final countryInfo = countriesData[selectedId];
        final name = countryInfo?.name ?? selectedId;
        
        final currentData = provider.userData[selectedId];
        final isVisited = currentData?.status == CountryStatus.visited;
        final isLived = currentData?.status == CountryStatus.lived;
        final isWish = currentData?.status == CountryStatus.wishlist;
        final isRedlist = currentData?.status == CountryStatus.redlist;

        return PanelWidget(
          title: 'Pays sélectionné',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVisited ? AppTheme.countryVisited : AppTheme.panelBg,
                      foregroundColor: isVisited ? AppTheme.ink1 : AppTheme.textColor,
                      side: BorderSide(color: isVisited ? AppTheme.countryVisited : AppTheme.mapStroke),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isVisited ? CountryStatus.none : CountryStatus.visited);
                    },
                    child: Text(isVisited ? 'Visité ✓' : 'Marquer visité'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLived ? AppTheme.countryLived : AppTheme.panelBg,
                      foregroundColor: isLived ? AppTheme.ink1 : AppTheme.textColor,
                      side: BorderSide(color: isLived ? AppTheme.countryLived : AppTheme.mapStroke),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isLived ? CountryStatus.none : CountryStatus.lived);
                    },
                    child: Text(isLived ? 'Habité ✓' : 'Marquer habité'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWish ? AppTheme.countryWishlist : AppTheme.panelBg,
                      foregroundColor: isWish ? AppTheme.ink1 : AppTheme.textColor,
                      side: BorderSide(color: isWish ? AppTheme.countryWishlist : AppTheme.mapStroke),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isWish ? CountryStatus.none : CountryStatus.wishlist);
                    },
                    child: Text(isWish ? 'Envie ✓' : 'Envie d\'y aller'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRedlist ? AppTheme.countryRedlistHover : AppTheme.panelBg,
                      foregroundColor: isRedlist ? Colors.white : AppTheme.textColor,
                      side: BorderSide(color: isRedlist ? AppTheme.countryRedlistHover : AppTheme.mapStroke),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isRedlist ? CountryStatus.none : CountryStatus.redlist);
                    },
                    child: Text(isRedlist ? 'Liste rouge ✓' : 'Liste rouge'),
                  ),
                ],
              ),
              if (currentData != null && currentData.status != CountryStatus.none) ...[
                const SizedBox(height: 16),
                const Divider(color: AppTheme.mapStroke),
                TextButton(
                  onPressed: () {
                    provider.removeCountryData(selectedId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('Supprimer ce pays'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
