class WeatherForecastModel {
  final List<String> dates;
  final List<double> tempMax;
  final List<double> tempMin;
  final List<double> precipitation;
  final List<double> cloudCover;

  WeatherForecastModel({
    required this.dates,
    required this.tempMax,
    required this.tempMin,
    required this.precipitation,
    required this.cloudCover,
  });
}