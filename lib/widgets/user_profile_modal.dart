import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../providers/auth_provider.dart';
import '../models/map_models.dart';
import '../theme/app_theme.dart';

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
          decoration: const BoxDecoration(
            color: AppTheme.panelBg,
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
                  const Text(
                    'Mon Profil de Voyageur',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.uid == null ? 'Utilisateur invité (Données locales)' : 'Compte synchronisé',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Mes Statistiques Détaillées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Pays visités', '$visited', AppTheme.countryVisited),
                  _buildStatRow('Pays habités', '$lived', AppTheme.countryLived),
                  _buildStatRow('Liste d\'envies', '$wishlist', AppTheme.countryWishlist),
                  _buildStatRow('Liste rouge (exclus)', '$redlist', AppTheme.countryRedlistHover),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.mapBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.palette, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Personnalisation des couleurs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bientôt disponible : Vous pourrez bientôt choisir vos propres couleurs pour la carte !',
                          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (authProvider.uid != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mapStroke,
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        authProvider.signOut();
                        Navigator.pop(context);
                      },
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Se connecter pour synchroniser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.countryVisited,
                        foregroundColor: AppTheme.ink1,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
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

  Widget _buildStatRow(String label, String value, Color color) {
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
                style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
