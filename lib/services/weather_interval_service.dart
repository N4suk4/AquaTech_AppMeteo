import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherHourService {
  Future<List<Map<String, dynamic>>> getHourlyData({
    required double latitude,
    required double longitude,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final startDate = start ?? now;
    final endDate = end ?? now.add(Duration(days: 1));

    final startStr = startDate.toIso8601String().split('T').first;
    final endStr = endDate.toIso8601String().split('T').first;

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
      '&hourly=temperature_2m,apparent_temperature,precipitation,cloud_cover,relative_humidity_2m,wind_speed_10m'
      '&start_date=$startStr&end_date=$endStr&timezone=auto',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la récupération des données horaires');
    }

    final data = jsonDecode(response.body);
    final hourly = data['hourly'];
    final timeList = List<String>.from(hourly['time']);
    final tempList = List<double>.from(hourly['temperature_2m'].map((e) => e?.toDouble() ?? 0.0));
    final apparentTempList = List<double>.from(hourly['apparent_temperature'].map((e) => e?.toDouble() ?? 0.0));
    final rainList = List<double>.from(hourly['precipitation'].map((e) => e?.toDouble() ?? 0.0));
    final cloudList = List<double>.from(hourly['cloud_cover'].map((e) => e?.toDouble() ?? 0.0));
    final humidityList = List<double>.from(hourly['relative_humidity_2m'].map((e) => e?.toDouble() ?? 0.0));
    final windList = List<double>.from(hourly['wind_speed_10m'].map((e) => e?.toDouble() ?? 0.0));

    List<Map<String, dynamic>> hourlyData = [];
    for (int i = 0; i < timeList.length; i++) {
      hourlyData.add({
        'time': timeList[i],
        'temperature': tempList[i],
        'apparent': apparentTempList[i],
        'rain': rainList[i],
        'cloud': cloudList[i],
        'humidity': humidityList[i],
        'wind': windList[i],
      });
    }

    return hourlyData;
  }
}