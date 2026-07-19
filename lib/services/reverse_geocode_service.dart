import 'dart:convert';
import 'package:http/http.dart' as http;

class ReverseGeocodeService {
  static Future<String?> getCountryCode(double lat, double lon) async {
    try {
      final uri = Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=fr');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryCode = data['countryCode'] as String?;
        return countryCode?.toLowerCase(); // Our map uses lowercase IDs
      }
    } catch (e) {
      // Ignored: network failure or parsing error
    }
    return null;
  }
}
