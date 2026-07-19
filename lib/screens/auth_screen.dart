import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.public, size: 80, color: AppTheme.countryVisited),
              const SizedBox(height: 24),
              const Text(
                'Atlas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre carnet de voyage synchronisé',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Se connecter avec Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.countryLived,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.read<AuthProvider>().signInWithGoogle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
