import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:lottie/lottie.dart';

class WeatherScreen extends StatelessWidget {
  final WeatherModel weather;
  final String cityName;

  const WeatherScreen({required this.weather, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final String animationPath = _getAnimationForCloudCover(
      cloudCover: weather.cloudCover,
      precipitation: weather.precipitation,
    );

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('🌦️ Météo à $cityName'),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    animationPath,
                    width: 150,
                    height: 150,
                    repeat: true,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$cityName',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${weather.temperature}°C',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  Text(
                    'Ressentie : ${weather.apparentTemperature}°C',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(height: 30, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _weatherInfo(Icons.water_drop, 'Humidité', '${weather.relativeHumidity}%'),
                      _weatherInfo(Icons.air, 'Vent', '${weather.windSpeed} m/s'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _weatherInfo(Icons.grain, 'Pluie', '${weather.precipitation} mm'),
                      _weatherInfo(Icons.cloud, 'Nuages', '${weather.cloudCover}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _weatherInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.lightBlue),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  String _getAnimationForCloudCover({
    required double cloudCover,
    required double precipitation,
  }) {
    if (cloudCover < 20.0 && precipitation < 1.0) {
      return 'assets/animations/sunny.json';
    } else if (cloudCover < 70.0 && precipitation < 3.0) {
      return 'assets/animations/partly_cloudy.json';
    } else if (cloudCover < 70.0 && precipitation > 3.0) {
      return 'assets/animations/sunny_rainy.json';
    } else if (cloudCover >= 70.0 && precipitation < 3.0) {
      return 'assets/animations/cloudy.json';
    } else if (cloudCover >= 70.0 && precipitation > 3.0) {
      return 'assets/animations/rainy.json';
    } else {
      return 'assets/animations/partly_cloudy.json';
    }
  }
}