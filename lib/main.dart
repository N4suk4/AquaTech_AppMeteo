import 'package:aquatech_meteo/models/weather_model.dart';
import 'package:aquatech_meteo/services/weather_service.dart';
import 'package:aquatech_meteo/services/favorite_service.dart';
import 'package:aquatech_meteo/screens/weather_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
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
  List<String> favoriteCities = [];
  String? _selectedFavorite;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoriteService().getAll();
    setState(() {
      favoriteCities = favs;
      if (!favs.contains(_selectedFavorite)) {
        _selectedFavorite = null;
      }
    });
  }

  void _refreshFavorites() {
    _loadFavorites();
  }

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
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text(favoriteCities.isEmpty
                          ? 'Aucune ville en favoris'
                          : 'Vos villes favorites'),
                      value: favoriteCities.contains(_selectedFavorite)
                          ? _selectedFavorite
                          : null,
                      items: favoriteCities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: favoriteCities.isEmpty
                      ? null
                      : (selected) async {
                        if (selected != null) {
                          setState(() {
                            _selectedFavorite = selected;
                          });
                          WeatherModel weather =
                            await WeatherService().getWeatherByCity(selected);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeatherScreen(
                                weather: weather,
                                cityName: selected,
                                onFavoritesChanged: _refreshFavorites,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              /// Champ de recherche manuelle
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

              /// Bouton de recherche météo
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

                  WeatherModel weather = await WeatherService().getWeatherByCity(cityName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherScreen(
                        weather: weather,
                        cityName: cityName,
                        onFavoritesChanged: _refreshFavorites,
                      ),
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