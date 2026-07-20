import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/map_models.dart';
import '../data_providers/hive_repository.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import 'auth_provider.dart';

class MapProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  Map<String, UserCountryData> _userData = {};
  String? _selectedCountryId;
  StreamSubscription? _firestoreSubscription;
  bool _isMigratedToCloud = false;
  
  Map<String, UserCountryData> get userData => _userData;
  String? get selectedCountryId => _selectedCountryId;

  MapProvider(this.authProvider) {
    _init();
  }

  void _init() {
    // 1. Load local Hive data first (for immediate UI response or offline)
    _userData = HiveRepository.loadUserData();
    notifyListeners();

    // 2. React to Auth changes
    authProvider.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    final uid = authProvider.uid;
    _firestoreSubscription?.cancel();

    if (uid != null) {
      // User is logged in
      _firestoreSubscription = _firestoreService.getUserCountriesStream(uid).listen((cloudData) {
        // If cloud data is empty but local data exists, migrate it
        if (cloudData.isEmpty && _userData.isNotEmpty && !_isMigratedToCloud) {
          _migrateLocalToCloud(uid);
          _isMigratedToCloud = true;
        } else {
          // Sync cloud to local map
          _userData = cloudData;
          notifyListeners();
          
          // Optionally sync back to Hive for offline cache
          for (final data in cloudData.values) {
            HiveRepository.saveUserData(data);
          }
        }
      });
    } else {
      // User logged out, revert to local only or clear
      _userData = HiveRepository.loadUserData();
      notifyListeners();
    }
  }

  Future<void> _migrateLocalToCloud(String uid) async {
    for (final data in _userData.values) {
      if (data.status != CountryStatus.none) {
        await _firestoreService.saveUserCountry(uid, data);
      }
    }
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthChanged);
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  void selectCountry(String countryId) {
    _selectedCountryId = countryId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCountryId = null;
    notifyListeners();
  }

  void markCountryStatus(String countryId, CountryStatus status) {
    final existing = _userData[countryId];
    final newData = UserCountryData(
      code: countryId,
      status: status,
      cities: existing?.cities ?? const [],
    );
    
    // Update local immediately for responsive UI
    _userData[countryId] = newData;
    HiveRepository.saveUserData(newData);
    notifyListeners();

    // Push to Cloud
    final uid = authProvider.uid;
    if (uid != null) {
      _firestoreService.saveUserCountry(uid, newData);
    }
  }

  void removeCountryData(String countryId) {
    // Update local immediately
    _userData.remove(countryId);
    HiveRepository.saveUserData(UserCountryData(code: countryId, status: CountryStatus.none));
    notifyListeners();

    // Remove from Cloud
    final uid = authProvider.uid;
    if (uid != null) {
      _firestoreService.removeUserCountry(uid, countryId);
    }
  }

  void updateCities(String countryId, List<String> cities) {
    final existing = _userData[countryId];
    if (existing == null) return;
    
    final newData = existing.copyWith(cities: cities);
    _userData[countryId] = newData;
    HiveRepository.saveUserData(newData);
    notifyListeners();

    if (authProvider.uid != null) {
      _firestoreService.saveUserCountry(authProvider.uid!, newData);
    }
  }

  void updateNotes(String countryId, String notes) {
    final existing = _userData[countryId];
    if (existing == null) return;
    
    final newData = existing.copyWith(notes: notes);
    _userData[countryId] = newData;
    HiveRepository.saveUserData(newData);
    notifyListeners();

    if (authProvider.uid != null) {
      _firestoreService.saveUserCountry(authProvider.uid!, newData);
    }
  }

  void addPhoto(String countryId, String photoUrl) {
    final existing = _userData[countryId];
    if (existing == null) return;

    final updatedPhotos = List<String>.from(existing.photos)..add(photoUrl);
    final newData = existing.copyWith(photos: updatedPhotos);
    _userData[countryId] = newData;
    HiveRepository.saveUserData(newData);
    notifyListeners();

    if (authProvider.uid != null) {
      _firestoreService.saveUserCountry(authProvider.uid!, newData);
    }
  }

  void removePhoto(String countryId, String photoUrl) {
    final existing = _userData[countryId];
    if (existing == null) return;

    final updatedPhotos = List<String>.from(existing.photos)..remove(photoUrl);
    final newData = existing.copyWith(photos: updatedPhotos);
    _userData[countryId] = newData;
    HiveRepository.saveUserData(newData);
    notifyListeners();

    if (authProvider.uid != null) {
      _firestoreService.saveUserCountry(authProvider.uid!, newData);
    }
  }

  Future<String?> uploadPhoto(String countryId, Uint8List fileBytes, String fileName) async {
    return await _cloudinaryService.uploadPhoto(fileBytes, fileName);
  }
}
