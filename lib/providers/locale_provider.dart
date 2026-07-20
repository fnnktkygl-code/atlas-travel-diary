import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';class LocaleProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _langKey = 'language';
  
  late Box _box;
  String _currentLocale = 'fr'; // default

  String get currentLocale => _currentLocale;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _currentLocale = _box.get(_langKey, defaultValue: 'fr');
    notifyListeners();
  }

  void setLocale(String langCode) {
    if (['fr', 'en', 'es'].contains(langCode)) {
      _currentLocale = langCode;
      _box.put(_langKey, langCode);
      notifyListeners();
    }
  }

  String translate(String key) {
    return translations[_currentLocale]?[key] ?? key;
  }
}

// Global helper function for easier use in widgets
String tr(BuildContext context, String key) {
  // We use listen: true so widgets rebuild when language changes
  final provider = Provider.of<LocaleProvider>(context);
  return provider.translate(key);
}
