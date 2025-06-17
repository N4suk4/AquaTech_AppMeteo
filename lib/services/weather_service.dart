import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';


class WeatherService {
  Future<WeatherModel> getWeatherByCity(String cityName) async {

    String geoUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$cityName';
  
    http.Response geoResponse = await http.get(Uri.parse(geoUrl));

    Map<String, dynamic> geoData = jsonDecode(geoResponse.body);

    double latitude = geoData['results'][0]['latitude'];
    double longitude = geoData['results'][0]['longitude'];

    print('Coordonnées trouvées: $latitude, $longitude');

    throw UnimplementedError('Géocodage OK, météo pas encore');

  }
}