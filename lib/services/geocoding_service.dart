import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  Future<Map<String, double>> getCoordinates(String cityName) async {
    if (cityName.isEmpty) {
      throw Exception("Le nom de la ville ne peut pas être vide");
    }

    final geoUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$cityName';
    final response = await http.get(Uri.parse(geoUrl));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la recherche de la ville");
    }

    final data = jsonDecode(response.body);

    if (data['results'] == null || data['results'].isEmpty) {
      throw Exception("Aucune ville trouvée");
    }

    return {
      'latitude': data['results'][0]['latitude'],
      'longitude': data['results'][0]['longitude'],
    };
  }
}