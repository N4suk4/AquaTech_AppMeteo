import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';


class WeatherService {
  Future<WeatherModel> getWeatherByCity(
  String cityName, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  
  final DateTime start = startDate ?? DateTime.now();
  final DateTime end = endDate ?? DateTime.now().add(Duration(days: 1));

    if (cityName.isEmpty) {
      throw Exception("Le nom de la ville ne peut pas être vide");
    }

    if (start.isAfter(end)) {
      throw Exception("La date de début ne peut pas être après la date de fin");
    }

    

    // Étape 1 : Géocodage
    String geoUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$cityName';
    http.Response geoResponse = await http.get(Uri.parse(geoUrl));

    if (geoResponse.statusCode != 200) {
      throw Exception("Erreur lors de la recherche de la ville");
    }

    Map<String, dynamic> geoData = jsonDecode(geoResponse.body);

    if (geoData['results'] == null || geoData['results'].isEmpty) {
      throw Exception("Aucune ville trouvée");
    }

    double latitude = geoData['results'][0]['latitude'];
    double longitude = geoData['results'][0]['longitude'];

    print('Coordonnées trouvées: $latitude, $longitude');

    // Étape 2 : Appel API météo avec toutes les données nécessaires
    String weatherUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation,cloud_cover';

    http.Response weatherResponse = await http.get(Uri.parse(weatherUrl));

    if (weatherResponse.statusCode != 200) {
      throw Exception("Erreur lors de la récupération de la météo");
    }

    Map<String, dynamic> weatherData = jsonDecode(weatherResponse.body);
    Map<String, dynamic> current = weatherData['current'];

    return WeatherModel(
      temperature: current['temperature_2m']?.toDouble() ?? 0.0,
      apparentTemperature: current['apparent_temperature']?.toDouble() ?? 0.0,
      relativeHumidity: current['relative_humidity_2m']?.toDouble() ?? 0.0,
      windSpeed: current['wind_speed_10m']?.toDouble() ?? 0.0,
      precipitation: current['precipitation']?.toDouble() ?? 0.0,
      cloudCover: current['cloud_cover']?.toDouble() ?? 0.0,
    );
  }
}