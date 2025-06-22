// Importations des packages nécessaires
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Importation des modèles et services
import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/weather_forecast_service.dart';
import '../services/favorite_service.dart';
import '../services/weather_hour_service.dart';

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
  // Futures pour récupérer les prévisions journalières et horaires
  late Future<WeatherForecastModel> _forecastFuture;
  late Future<Map<String, double>> _hourlyTempsFuture;

  // Variable pour savoir si la ville est en favoris
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

  // Vérifie si la ville est déjà en favoris
  void _checkIfFavorite() async {
    final isFav = await _favoriteService.isFavorite(widget.cityName);
    setState(() {
      _isFavorite = isFav;
    });
  }

  // Ajoute ou supprime la ville des favoris
  void _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.cityName);
    } else {
      await _favoriteService.addFavorite(widget.cityName);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    widget.onFavoritesChanged?.call(); // Notifie le parent que les favoris ont changé
  }

  @override
  Widget build(BuildContext context) {

    // Convertit l'heure UTC en heure locale
    final utcNow = DateTime.now().toUtc();
    final localDateTime = utcNow.add(Duration(seconds: widget.weather.utcOffsetSeconds));

    // Choisit l'animation Lottie selon la météo
    final String animationPath = _chooseMeteoIcon(
      cloudCover: widget.weather.cloudCover,
      precipitation: widget.weather.precipitation,
      utcOffsetSeconds: widget.weather.utcOffsetSeconds,
    );

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('Météo à ${widget.cityName}'),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        actions: [

          // Bouton étoile pour les favoris
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

              // Carte avec les infos météo principales
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Date + heure actuelle
                      Text(
                        DateFormat('EEEE d MMMM', 'fr_FR').format(localDateTime),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('HH:mm').format(localDateTime),
                        style: TextStyle(fontSize: 14),
                      ),
                      Lottie.asset(animationPath, width: 120, height: 120), // Animation météo
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

              SizedBox(height: 30),


              // Graphique des températures horaires
              Text('Température sur 24h', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: FutureBuilder<Map<String, double>>(
                  future: _hourlyTempsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

                    final data = snapshot.data!;
                    final hours = data.keys.toList();
                    final temps = data.values.toList();

                    return LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index % 3 != 0 || index >= hours.length) return Container();
                                return Text(hours[index], style: TextStyle(fontSize: 10));
                              },
                              reservedSize: 32,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}°C',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        minY: temps.reduce((a, b) => a < b ? a : b) - 5,
                        maxY: temps.reduce((a, b) => a > b ? a : b) + 5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(temps.length, (index) => FlSpot(index.toDouble(), temps[index])),
                            isCurved: true,
                            color: const Color.fromARGB(255, 255, 156, 64),
                            barWidth: 3,
                            belowBarData: BarAreaData(show: true, color: Colors.orangeAccent.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),


              // Liste horizontale des prévisions à 7 jours
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
                          utcOffsetSeconds: widget.weather.utcOffsetSeconds,
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
      ),
    );
  }


  // Widget pour afficher une info météo avec une icône
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



  // Fonction qui choisit l’animation météo selon heure, pluie et nuages

  String _chooseMeteoIcon({
    required double cloudCover,
    required double precipitation,
    required int utcOffsetSeconds,
  }) {
    final utcNow = DateTime.now().toUtc();
    final localNow = utcNow.add(Duration(seconds: utcOffsetSeconds));
    final hour = localNow.hour;
    final isNight = hour < 6 || hour >= 20;

    if (isNight) {
      if (cloudCover < 20.0 && precipitation < 1.0) {
        return 'assets/animations/moon.json';
      } else if (cloudCover < 70.0 && precipitation < 3.0) {
        return 'assets/animations/moon_partly_cloudy.json';
      } else if (cloudCover >= 70.0 && precipitation > 3.0) {
        return 'assets/animations/night_rainy.json';
      } else {
        return 'assets/animations/cloudy.json';
      }
    } else {
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
}