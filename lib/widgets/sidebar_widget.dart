import 'package:flutter/material.dart';
import 'panels/search_panel.dart';
import 'panels/geo_panel.dart';
import 'panels/detail_panel.dart';
import 'panels/journal_panel.dart';
import 'panels/panel_widget.dart';
import '../providers/map_provider.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/map_models.dart';
import '../data/countries.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GeoPanel(),
          const SearchPanel(),
          const DetailPanel(),
          const JournalPanel(),
          _buildWishlistPanel(),
        ],
      ),
    );
  }

  Widget _buildWishlistPanel() {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        final wishlistIds = provider.userData.entries
            .where((e) => e.value.status == CountryStatus.wishlist)
            .map((e) => e.key)
            .toList();

        return PanelWidget(
          title: 'Liste d\'envies',
          trailing: Text(
            '${wishlistIds.length}',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          child: wishlistIds.isEmpty
              ? const Text(
                  'Aucun pays en liste d\'envies.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wishlistIds.map((id) {
                    final name = countriesData[id]?.name ?? id;
                    return ActionChip(
                      label: Text(name),
                      backgroundColor: AppTheme.countryWishlist.withValues(alpha: 0.1),
                      side: const BorderSide(color: AppTheme.countryWishlist),
                      onPressed: () {
                        provider.selectCountry(id);
                      },
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
