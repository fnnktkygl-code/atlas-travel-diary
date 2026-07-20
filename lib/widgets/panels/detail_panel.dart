import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/map_models.dart';
import '../../providers/map_provider.dart';
import '../../providers/locale_provider.dart';
import '../../data/countries.dart';
import '../../data/cities.dart';
import '../../theme/app_theme.dart';
import '../../screens/entry_editor_screen.dart';
import 'panel_widget.dart';

class DetailPanel extends StatelessWidget {
  const DetailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final selectedId = provider.selectedCountryId;
        
        if (selectedId == null) {
          return PanelWidget(
            title: tr(context, 'country_selected'),
            child: Text(
              tr(context, 'country_selected_empty'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        final countryInfo = countriesData[selectedId];
        final name = countryInfo?.getName(localeProvider.currentLocale) ?? selectedId;
        
        final currentData = provider.userData[selectedId];
        final isVisited = currentData?.status == CountryStatus.visited;
        final isLived = currentData?.status == CountryStatus.lived;
        final isWish = currentData?.status == CountryStatus.wishlist;
        final isRedlist = currentData?.status == CountryStatus.redlist;

        return PanelWidget(
          title: tr(context, 'country_selected'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
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
                      backgroundColor: isVisited ? AppTheme.countryVisited : Theme.of(context).cardColor,
                      foregroundColor: isVisited ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isVisited ? AppTheme.countryVisited : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isVisited ? CountryStatus.none : CountryStatus.visited);
                    },
                    child: Text(isVisited ? '${tr(context, 'visited')} ✓' : tr(context, 'mark_visited')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLived ? AppTheme.countryLived : Theme.of(context).cardColor,
                      foregroundColor: isLived ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isLived ? AppTheme.countryLived : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isLived ? CountryStatus.none : CountryStatus.lived);
                    },
                    child: Text(isLived ? '${tr(context, 'lived')} ✓' : tr(context, 'mark_lived')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWish ? AppTheme.countryWishlist : Theme.of(context).cardColor,
                      foregroundColor: isWish ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isWish ? AppTheme.countryWishlist : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isWish ? CountryStatus.none : CountryStatus.wishlist);
                    },
                    child: Text(isWish ? '${tr(context, 'wishlist')} ✓' : tr(context, 'add_wishlist')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRedlist ? AppTheme.countryRedlistHover : Theme.of(context).cardColor,
                      foregroundColor: isRedlist ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isRedlist ? AppTheme.countryRedlistHover : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isRedlist ? CountryStatus.none : CountryStatus.redlist);
                    },
                    child: Text(isRedlist ? '${tr(context, 'redlist')} ✓' : tr(context, 'add_redlist')),
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
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.countryRedlistHover, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr(context, 'redlist_info'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
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
                _EntriesSection(
                  countryId: selectedId,
                  provider: provider,
                ),
              ],
              if (currentData != null && currentData.status != CountryStatus.none) ...[
                const SizedBox(height: 16),
                Divider(color: Theme.of(context).colorScheme.outline),
                TextButton(
                  onPressed: () {
                    provider.removeCountryData(selectedId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: Text(tr(context, 'remove_country')),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EntriesSection extends StatelessWidget {
  final String countryId;
  final MapProvider provider;

  const _EntriesSection({
    Key? key,
    required this.countryId,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = provider.entries.where((e) => e.countryCode == countryId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr(context, 'journal'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.countryVisited),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EntryEditorScreen(countryCode: countryId),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
          ],
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              tr(context, 'journal_empty'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                child: ListTile(
                  title: Text(entry.title?.isNotEmpty == true ? entry.title! : (entry.city?.isNotEmpty == true ? entry.city! : tr(context, 'journal'))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${entry.date.day}/${entry.date.month}/${entry.date.year}", style: const TextStyle(fontSize: 12)),
                      if (entry.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(entry.note, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EntryEditorScreen(countryCode: countryId, existingEntry: entry),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
