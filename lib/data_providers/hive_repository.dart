import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/map_models.dart';

class HiveRepository {
  static const String _boxName = 'user_countries';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  static Map<String, UserCountryData> loadUserData() {
    final map = <String, UserCountryData>{};
    for (var key in _box.keys) {
      final jsonStr = _box.get(key);
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
    await _box.put(data.code, jsonEncode(data.toJson()));
  }
}
