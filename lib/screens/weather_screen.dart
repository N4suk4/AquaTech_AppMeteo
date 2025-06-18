import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatelessWidget{
  final WeatherModel weather;
  final String cityName;
  
  const WeatherScreen({required this.weather, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Météo à $cityName')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Température : ${weather.temperature}°C'),
            Text('Ressentie : ${weather.apparentTemperature}°C'),
            Text('Humidité : ${weather.relativeHumidity}%'),
            Text('Vent : ${weather.windSpeed} m/s'),
            Text('Précipitations : ${weather.precipitation} mm'),
            Text('Nuages : ${weather.cloudCover}%'),
          ],
        ),
      ),
    );
  }
}