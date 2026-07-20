import 'package:flutter/material.dart';
import 'panels/search_panel.dart';
import 'panels/geo_panel.dart';
import 'panels/detail_panel.dart';
import 'panels/journal_panel.dart';
import 'panels/panel_widget.dart';
import '../providers/map_provider.dart';
import '../providers/locale_provider.dart';
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
          _buildWishlistPanel(context),
          _buildRedlistPanel(context),
        ],
      ),
    );
  }

  Widget _buildWishlistPanel(BuildContext context) {
    return Consumer2<MapProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final wishlistIds = provider.userData.entries
            .where((e) => e.value.status == CountryStatus.wishlist)
            .map((e) => e.key)
            .toList();

        return PanelWidget(
          title: tr(context, 'wishlist'),
          trailing: Text(
            '${wishlistIds.length}',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          child: wishlistIds.isEmpty
              ? Text(
                  tr(context, 'wishlist_panel_empty'),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wishlistIds.map((id) {
                    final name = countriesData[id]?.getName(localeProvider.currentLocale) ?? id;
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

  Widget _buildRedlistPanel(BuildContext context) {
    return Consumer2<MapProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final redlistIds = provider.userData.entries
            .where((e) => e.value.status == CountryStatus.redlist)
            .map((e) => e.key)
            .toList();

        if (redlistIds.isEmpty) return const SizedBox.shrink(); // Hide panel if empty to save space

        return PanelWidget(
          title: tr(context, 'redlist'),
          trailing: Text(
            '${redlistIds.length}',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: redlistIds.map((id) {
              final name = countriesData[id]?.getName(localeProvider.currentLocale) ?? id;
              return ActionChip(
                label: Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                backgroundColor: AppTheme.countryRedlistHover.withValues(alpha: 0.1),
                side: BorderSide(color: AppTheme.countryRedlistHover.withValues(alpha: 0.5)),
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
