import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_cities';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_key) ?? [];
    if (!favorites.contains(cityName)) {
      favorites.add(cityName);
      await prefs.setStringList(_key, favorites);
    }
  }

  Future<void> removeFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_key) ?? [];
    favorites.remove(cityName);
    await prefs.setStringList(_key, favorites);
  }

  Future<bool> isFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_key) ?? [];
    return favorites.contains(cityName);
  }

  Future<List<String>> getAll() async {
    return await getFavorites();
  }
}