import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panel_widget.dart';
import '../../providers/map_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/map_models.dart';
import '../../data/countries.dart';
import '../../theme/app_theme.dart';

class JournalPanel extends StatelessWidget {
  const JournalPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final journalEntries = provider.userData.values
            .where((data) =>
                data.status == CountryStatus.visited ||
                data.status == CountryStatus.lived)
            .toList();

        // Sort by date descending (most recent first)
        journalEntries.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });

        return PanelWidget(
          title: tr(context, 'journal'),
          trailing: Text(
            '${journalEntries.length}',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          child: journalEntries.isEmpty
              ? Text(
                  tr(context, 'journal_empty'),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: journalEntries.length,
                  itemBuilder: (context, index) {
                    final data = journalEntries[index];
                    final name = countriesData[data.code]?.getName(localeProvider.currentLocale) ?? data.code;
                    final dateStr = data.date != null
                        ? '${data.date!.day}/${data.date!.month}/${data.date!.year}'
                        : '';
                    
                      return InkWell(
                        onTap: () => provider.selectCountry(data.code),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: data.status == CountryStatus.visited
                                              ? AppTheme.countryVisited
                                              : AppTheme.countryLived,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (data.cities.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    data.cities.join(' • '),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                  },
                ),
        );
      },
    );
  }
}
