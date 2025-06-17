class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final double relativeHumidity;
  final double windSpeed;
  final double precipitation;
  final double cloudCover;

  WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitation,
    required this.cloudCover,
  });
}