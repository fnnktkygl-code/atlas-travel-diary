import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data_providers/hive_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/map_provider.dart';
import 'providers/geo_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/map_screen.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await HiveRepository.init();

  final localeProvider = LocaleProvider();
  await localeProvider.init();
  
  final themeProvider = ThemeProvider();
  await themeProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MapProvider>(
          create: (context) => MapProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previous) => previous ?? MapProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<MapProvider, GeoProvider>(
          create: (context) => GeoProvider(context.read<MapProvider>()),
          update: (context, mapProvider, previous) => previous ?? GeoProvider(mapProvider),
        ),
      ],
      child: const AtlasApp(),
    ),
  );
}

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Atlas',
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const MapScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
