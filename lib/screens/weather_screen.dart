// Importations des packages nécessaires
import 'package:flutter/material.dart';


// Importation des modèles et services
import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/weather_forecast_service.dart';
import '../services/favorite_service.dart';
import '../services/weather_hour_service.dart';

// Importation des composants
import '../widget/weather_card.dart';
import '../widget/weather_hourly_chart.dart';
import '../widget/weather_forecast_list.dart';

// Écran principal pour afficher la météo d'une ville
class WeatherScreen extends StatefulWidget {
  final WeatherModel weather;
  final String cityName;
  final VoidCallback? onFavoritesChanged;

  const WeatherScreen({
    super.key,
    required this.weather,
    required this.cityName,
    this.onFavoritesChanged,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherForecastModel> _forecastFuture;
  late Future<Map<String, double>> _hourlyTempsFuture;

  bool _isFavorite = false;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _forecastFuture = WeatherForecastService().getForecastByCity(widget.cityName);
    _hourlyTempsFuture = WeatherHourService().getHourlyTemperatures(
      widget.weather.latitude,
      widget.weather.longitude,
    );
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

    widget.onFavoritesChanged?.call();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('Météo à ${widget.cityName}'),
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
        child: SingleChildScrollView(
          child: Column(
            children: [

              // Affichage de l'animation météo
              WeatherCard(
                weather: widget.weather,
                cityName: widget.cityName,
              ),

              
              SizedBox(height: 30),
              Text('Température sur 24h', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              // Affichage du graphique des températures horaires
              FutureBuilder<Map<String, double>>(
                future: _hourlyTempsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return WeatherHourlyChart(hourlyTemps: snapshot.data!);
                },
              ),
              SizedBox(height: 20),
              Text('Prévisions sur la semaine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),


              // Affichage de la liste des prévisions météo
              FutureBuilder<WeatherForecastModel>(
                future: _forecastFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return WeatherForecastList(
                    forecast: snapshot.data!,
                    utcOffsetSeconds: widget.weather.utcOffsetSeconds,
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