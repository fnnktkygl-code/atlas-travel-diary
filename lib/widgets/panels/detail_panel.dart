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
              if (isRedlist) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.countryRedlistHover.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.countryRedlistHover.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.countryRedlistHover, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ce pays est exclu de vos statistiques globales de surface et de complétion du monde.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (currentData != null && (currentData.status == CountryStatus.visited || currentData.status == CountryStatus.lived)) ...[
                const SizedBox(height: 24),
                _CitiesSection(
                  countryId: selectedId,
                  cities: currentData.cities,
                  provider: provider,
                ),
              ],
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
class _CitiesSection extends StatefulWidget {
  final String countryId;
  final List<String> cities;
  final MapProvider provider;

  const _CitiesSection({
    Key? key,
    required this.countryId,
    required this.cities,
    required this.provider,
  }) : super(key: key);

  @override
  State<_CitiesSection> createState() => _CitiesSectionState();
}

class _CitiesSectionState extends State<_CitiesSection> {
  final TextEditingController _controller = TextEditingController();

  void _addCity(String val) {
    final text = val.trim();
    if (text.isNotEmpty && !widget.cities.contains(text)) {
      final newCities = List<String>.from(widget.cities)..add(text);
      widget.provider.updateCities(widget.countryId, newCities);
      _controller.clear();
    }
  }

  void _removeCity(String city) {
    final newCities = List<String>.from(widget.cities)..remove(city);
    widget.provider.updateCities(widget.countryId, newCities);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Villes visitées',
          style: TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.cities.map((city) {
            return Chip(
              label: Text(city),
              onDeleted: () => _removeCity(city),
              backgroundColor: AppTheme.mapStroke,
              deleteIconColor: Colors.grey,
              side: BorderSide.none,
              labelStyle: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.all(4),
            );
          }).toList(),
        ),
        if (widget.cities.isNotEmpty) const SizedBox(height: 12),
        TextField(
          controller: _controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Ajouter une ville (Entrée pour valider)',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppTheme.mapBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.countryVisited),
              onPressed: () => _addCity(_controller.text),
            ),
          ),
          onSubmitted: _addCity,
        ),
      ],
    );
  }
}
