import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panel_widget.dart';
import '../../providers/map_provider.dart';
import '../../providers/locale_provider.dart';
import '../../data/countries.dart';
import '../../theme/app_theme.dart';

class JournalPanel extends StatelessWidget {
  const JournalPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final journalEntries = provider.entries;

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
                    final entry = journalEntries[index];
                    final countryName = countriesData[entry.countryCode]?.getName(localeProvider.currentLocale) ?? entry.countryCode;
                    
                    return InkWell(
                      onTap: () => provider.selectCountry(entry.countryCode),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.countryVisited,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.title?.isNotEmpty == true ? entry.title! : countryName,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            if (entry.title?.isNotEmpty == true || entry.city?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  [if (entry.title?.isNotEmpty == true) countryName, if (entry.city?.isNotEmpty == true) entry.city].join(' • '),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            if (entry.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  entry.note,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                                    fontSize: 13,
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
