import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../providers/auth_provider.dart';
import '../models/map_models.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class UserProfileModal extends StatelessWidget {
  const UserProfileModal({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UserProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Consumer2<MapProvider, AuthProvider>(
            builder: (context, mapProvider, authProvider, child) {
              int wishlist = 0;
              int redlist = 0;
              int lived = 0;
              int visited = 0;

              for (var data in mapProvider.userData.values) {
                if (data.status == CountryStatus.wishlist) wishlist++;
                if (data.status == CountryStatus.redlist) redlist++;
                if (data.status == CountryStatus.lived) lived++;
                if (data.status == CountryStatus.visited) visited++;
              }

              return ListView(
                controller: controller,
                children: [
                  Text(
                    tr(context, 'profile_title'),
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.uid == null ? tr(context, 'profile_guest') : tr(context, 'profile_sync'),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    tr(context, 'profile_stats_title'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(context, tr(context, 'stat_visited'), '$visited', AppTheme.countryVisited),
                  _buildStatRow(context, tr(context, 'stat_lived'), '$lived', AppTheme.countryLived),
                  _buildStatRow(context, tr(context, 'stat_wishlist'), '$wishlist', AppTheme.countryWishlist),
                  _buildStatRow(context, tr(context, 'stat_redlist'), '$redlist', AppTheme.countryRedlistHover),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.palette, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              tr(context, 'color_custom_title'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(context, 'color_custom_desc'),
                          style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Erreur Firebase : ${authProvider.errorMessage}",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (authProvider.uid != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text(tr(context, 'logout')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.outline,
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        try {
                          await authProvider.signOut();
                        } catch (e) {
                          debugPrint('Logout failed: $e');
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: Text(tr(context, 'login_sync')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.countryVisited,
                        foregroundColor: Theme.of(context).colorScheme.surfaceTint,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        await authProvider.signInWithGoogle();
                        if (context.mounted && authProvider.errorMessage == null) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
