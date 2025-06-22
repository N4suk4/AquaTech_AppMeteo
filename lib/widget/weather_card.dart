import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_model.dart';
import 'weather_info_widget.dart';
import '../tools/weather_choose_icon.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final String cityName;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final utcNow = DateTime.now().toUtc();
    final localDateTime = utcNow.add(Duration(seconds: weather.utcOffsetSeconds));

    final animationPath = chooseMeteoIcon(
      cloudCover: weather.cloudCover,
      precipitation: weather.precipitation,
      utcOffsetSeconds: weather.utcOffsetSeconds,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEEE d MMMM', 'fr_FR').format(localDateTime),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('HH:mm').format(localDateTime),
              style: TextStyle(fontSize: 14),
            ),
            Lottie.asset(animationPath, width: 120, height: 120),
            SizedBox(height: 10),
            Text(
              cityName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${weather.temperature}°C',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            Text('Ressentie : ${weather.apparentTemperature}°C'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherInfoWidget(
                  icon: Icons.water_drop,
                  label: 'Humidité',
                  value: '${weather.relativeHumidity}%',
                ),
                WeatherInfoWidget(
                  icon: Icons.air,
                  label: 'Vent',
                  value: '${weather.windSpeed} m/s',
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherInfoWidget(
                  icon: Icons.grain,
                  label: 'Pluie',
                  value: '${weather.precipitation} mm',
                ),
                WeatherInfoWidget(
                  icon: Icons.cloud,
                  label: 'Nuages',
                  value: '${weather.cloudCover}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}