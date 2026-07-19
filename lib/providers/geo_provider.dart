import 'package:flutter/material.dart';
import '../services/geolocation_service.dart';
import '../services/reverse_geocode_service.dart';
import '../models/map_models.dart';
import 'map_provider.dart';

class GeoProvider extends ChangeNotifier {
  final MapProvider mapProvider;
  
  bool _isAutoTracking = false;
  bool _isLocating = false;
  String? _detectedCountryCode;
  String _statusMessage = '';

  bool get isAutoTracking => _isAutoTracking;
  bool get isLocating => _isLocating;
  String? get detectedCountryCode => _detectedCountryCode;
  String get statusMessage => _statusMessage;

  GeoProvider(this.mapProvider);

  void toggleAutoTracking(bool value) {
    _isAutoTracking = value;
    if (_isAutoTracking) {
      _detectLocation();
    } else {
      _detectedCountryCode = null;
      _statusMessage = '';
    }
    notifyListeners();
  }

  Future<void> _detectLocation() async {
    _isLocating = true;
    _statusMessage = 'Recherche de votre position...';
    notifyListeners();

    final position = await GeolocationService.getCurrentPosition();
    if (position == null) {
      _isLocating = false;
      _statusMessage = 'Impossible d\'obtenir la position.';
      _detectedCountryCode = null;
      notifyListeners();
      return;
    }

    final countryCode = await ReverseGeocodeService.getCountryCode(
        position.latitude, position.longitude);

    _isLocating = false;

    if (countryCode == null) {
      _statusMessage = 'Position trouvée, mais impossible d\'identifier le pays.';
      _detectedCountryCode = null;
    } else {
      _detectedCountryCode = countryCode;
      
      // Check if we already have this country visited
      final userData = mapProvider.userData[countryCode];
      if (userData != null && (userData.status == CountryStatus.visited || userData.status == CountryStatus.lived)) {
        _statusMessage = 'Vous êtes dans un pays déjà visité.';
      } else {
        _statusMessage = 'Nouveau pays détecté ! Voulez-vous l\'ajouter ?';
      }
    }
    
    notifyListeners();
  }
}
