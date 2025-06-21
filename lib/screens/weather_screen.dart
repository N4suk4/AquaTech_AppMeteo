import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/weather_forecast_service.dart';
import '../services/favorite_service.dart';

class WeatherScreen extends StatefulWidget {
  final WeatherModel weather;
  final String cityName;
  final VoidCallback? onFavoritesChanged; // ✅ Ici on ajoute la fonction optionnelle

  const WeatherScreen({
    super.key,
    required this.weather,
    required this.cityName,
    this.onFavoritesChanged, // ✅ Et on la prend en paramètre
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherForecastModel> _forecastFuture;
  bool _isFavorite = false;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _forecastFuture = WeatherForecastService().getForecastByCity(widget.cityName);
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    final isFav = await _favoriteService.isFavorite(widget.cityName);
    setState(() {
      _isFavorite = isFav;
    });
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.cityName);
    } else {
      await _favoriteService.addFavorite(widget.cityName);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // ✅ Appelle la fonction passée depuis TestScreen s'il y en a une
    widget.onFavoritesChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final String animationPath = _chooseMeteoIcon(
      cloudCover: widget.weather.cloudCover,
      precipitation: widget.weather.precipitation,
    );

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('🌦️ Météo à ${widget.cityName}'),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Colors.yellow[700],
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('HH:mm').format(DateTime.now()),
                      style: TextStyle(fontSize: 14),
                    ),
                    Lottie.asset(animationPath, width: 120, height: 120),
                    SizedBox(height: 10),
                    Text(
                      widget.cityName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.weather.temperature}°C',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    Text('Ressentie : ${widget.weather.apparentTemperature}°C'),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _weatherInfo(Icons.water_drop, 'Humidité', '${widget.weather.relativeHumidity}%'),
                        _weatherInfo(Icons.air, 'Vent', '${widget.weather.windSpeed} m/s'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _weatherInfo(Icons.grain, 'Pluie', '${widget.weather.precipitation} mm'),
                        _weatherInfo(Icons.cloud, 'Nuages', '${widget.weather.cloudCover}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Prévisions sur la semaine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: FutureBuilder<WeatherForecastModel>(
                future: _forecastFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Text("Erreur : ${snapshot.error}");

                  final forecast = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecast.dates.length,
                    itemBuilder: (context, index) {
                      final date = DateFormat('E d MMM', 'fr_FR').format(DateTime.parse(forecast.dates[index]));
                      final iconPath = _chooseMeteoIcon(
                        cloudCover: forecast.cloudCover[index],
                        precipitation: forecast.precipitation[index],
                      );

                      return Container(
                        width: 140,
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(date, style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Lottie.asset(iconPath, width: 60, height: 60),
                                SizedBox(height: 8),
                                Text('Min: ${forecast.tempMin[index]}°C'),
                                Text('Max: ${forecast.tempMax[index]}°C'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.lightBlue),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  String _chooseMeteoIcon({
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