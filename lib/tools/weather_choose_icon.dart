// lib/utils/weather_icon_helper.dart

String chooseMeteoIcon({
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