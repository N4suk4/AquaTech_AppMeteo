import 'dart:convert';
import 'package:http/http.dart' as http;


// Service pour récupérer les températures horaires à partir de l'API Open-Meteo

class WeatherHourService {
  Future<Map<String, double>> getHourlyTemperatures(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
      '&hourly=temperature_2m&timezone=auto',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la récupération des températures horaires");
    }

    final data = jsonDecode(response.body);
    final List times = data['hourly']['time'];
    final List temps = data['hourly']['temperature_2m'];

    final Map<String, double> hourlyData = {};
    for (int i = 0; i < times.length; i++) {
      final hour = times[i].substring(11, 16); // "HH:mm"
      hourlyData[hour] = temps[i].toDouble();
    }

    return hourlyData;
  }
}