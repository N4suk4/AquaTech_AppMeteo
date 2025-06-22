import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'geocoding_service.dart';

class WeatherService {
  final GeocodingService _geocodingService = GeocodingService();

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    final coordinates = await _geocodingService.getCoordinates(cityName);
    final latitude = coordinates['latitude']!;
    final longitude = coordinates['longitude']!;

    final weatherUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation,cloud_cover'
        '&timezone=auto';

    final response = await http.get(Uri.parse(weatherUrl));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la récupération de la météo");
    }

    final weatherData = jsonDecode(response.body);
    final current = weatherData['current'];

    return WeatherModel(
      temperature: current['temperature_2m']?.toDouble() ?? 0.0,
      apparentTemperature: current['apparent_temperature']?.toDouble() ?? 0.0,
      relativeHumidity: current['relative_humidity_2m']?.toDouble() ?? 0.0,
      windSpeed: current['wind_speed_10m']?.toDouble() ?? 0.0,
      precipitation: current['precipitation']?.toDouble() ?? 0.0,
      cloudCover: current['cloud_cover']?.toDouble() ?? 0.0,
      utcOffsetSeconds: weatherData['utc_offset_seconds'] ?? 0,
      latitude: latitude,
      longitude: longitude,
    );
  }
}