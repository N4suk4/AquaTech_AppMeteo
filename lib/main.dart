import 'package:aquatech_meteo/models/weather_model.dart';
import 'package:aquatech_meteo/services/weather_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo App',
      home: TestScreen(), // ← Ton TestScreen ici !
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Weather Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:() async{
                String cityName = _cityController.text;

                WeatherService weatherService = WeatherService();
                WeatherModel weather = await weatherService.getWeatherByCity(cityName);

                print('Weather in $cityName: ${weather.temperature}°C, '
                      '${weather.apparentTemperature}°C apparent, '
                      '${weather.relativeHumidity}% humidity, '
                      '${weather.windSpeed} m/s wind, '
                      '${weather.precipitation} mm precipitation, '
                      '${weather.cloudCover}% cloud cover'
                      );
              },
              child: Text('Get Weather'),
            )
          ],
        ),
      )
    );
  }
}

