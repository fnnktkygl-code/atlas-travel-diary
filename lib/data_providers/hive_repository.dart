import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/map_models.dart';

class HiveRepository {
  static const String _countriesBox = 'user_countries';
  static const String _entriesBox = 'user_entries';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_countriesBox);
    await Hive.openBox<String>(_entriesBox);
  }

  static Box<String> get _cBox => Hive.box<String>(_countriesBox);
  static Box<String> get _eBox => Hive.box<String>(_entriesBox);

  static Map<String, UserCountryData> loadUserData() {
    final map = <String, UserCountryData>{};
    for (var key in _cBox.keys) {
      final jsonStr = _cBox.get(key);
      if (jsonStr != null) {
        try {
          final data = UserCountryData.fromJson(jsonDecode(jsonStr));
          map[data.code] = data;
        } catch (e) {
          // Ignore invalid data
        }
      }
    }
    return map;
  }

  static Future<void> saveUserData(UserCountryData data) async {
    await _cBox.put(data.code, jsonEncode(data.toJson()));
  }

  static List<JournalEntry> loadEntries() {
    final list = <JournalEntry>[];
    for (var key in _eBox.keys) {
      final jsonStr = _eBox.get(key);
      if (jsonStr != null) {
        try {
          list.add(JournalEntry.fromJson(jsonDecode(jsonStr)));
        } catch (e) {
          // Ignore invalid data
        }
      }
    }
    return list;
  }

  static Future<void> saveEntry(JournalEntry entry) async {
    await _eBox.put(entry.id, jsonEncode(entry.toJson()));
  }

  static Future<void> removeEntry(String entryId) async {
    await _eBox.delete(entryId);
  }

  static Future<void> clearAll() async {
    await _cBox.clear();
    await _eBox.clear();
  }
}
