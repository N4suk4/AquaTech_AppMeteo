import 'package:aquatech_meteo/models/weather_model.dart';
import 'package:aquatech_meteo/services/weather_service.dart';
import 'package:aquatech_meteo/screens/weather_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo App',
      home: TestScreen(), 
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
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('🌤️ AquaTech Météo'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.cloud, size: 100, color: Colors.lightBlueAccent),
              SizedBox(height: 20),
              Text(
                'Bienvenue !',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Entre le nom d\'une ville pour voir la météo actuelle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Ex: Montpellier',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.search),
                label: Text('Voir la météo'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  String cityName = _cityController.text.trim();

                  if (cityName.isEmpty) return;

                  WeatherService weatherService = WeatherService();
                  WeatherModel weather = await weatherService.getWeatherByCity(cityName);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherScreen(weather: weather, cityName: cityName),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}