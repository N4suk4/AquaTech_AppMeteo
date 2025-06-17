import 'package:aquatech_meteo/models/weather_model.dart';
import 'package:aquatech_meteo/services/weather_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Testscreen(),
    );
  }
}

class Testscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen'),
      ),
      body: Center(child: ElevatedButton(
        onPressed: () async {
          WeatherService weatherService = WeatherService();
          WeatherModel weather = await weatherService.getWeatherByCity('Paris');
          print('Weather in Paris: ${weather.temperature}°C');
        },
        child: Text("tester paris"),
        )
      )
    );
  }
}