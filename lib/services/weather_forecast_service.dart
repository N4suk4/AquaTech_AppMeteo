import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';


/// Service pour récupérer les prévisions météo quotidiennes à partir de l'API Open-Meteo

class WeatherForecastService {
  Future<WeatherForecastModel> getForecastByCity(String cityName) async {
    // Étape 1 : Géocodage pour obtenir les coordonnées
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

    // Étape 2 : Appel API météo daily forecast
    String weatherUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,cloud_cover_mean&timezone=auto';

    http.Response weatherResponse = await http.get(Uri.parse(weatherUrl));

    if (weatherResponse.statusCode != 200) {
      throw Exception("Erreur lors de la récupération des prévisions météo");
    }

    Map<String, dynamic> weatherData = jsonDecode(weatherResponse.body);
    final daily = weatherData['daily'];

    return WeatherForecastModel(
      dates: List<String>.from(daily['time']),
      tempMax: List<double>.from(daily['temperature_2m_max'].map((e) => (e as num).toDouble())),
      tempMin: List<double>.from(daily['temperature_2m_min'].map((e) => (e as num).toDouble())),
      precipitation: List<double>.from(daily['precipitation_sum'].map((e) => (e as num).toDouble())),
      cloudCover: List<double>.from(daily['cloud_cover_mean'].map((e) => (e as num).toDouble())),
    );
  }
}