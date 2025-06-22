import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_forecast_model.dart';
import '../tools/weather_choose_icon.dart';

class WeatherForecastList extends StatelessWidget {
  final WeatherForecastModel forecast;
  final int utcOffsetSeconds;

  const WeatherForecastList({
    super.key,
    required this.forecast,
    required this.utcOffsetSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.dates.length,
        itemBuilder: (context, index) {
          final date = DateFormat('E d MMM', 'fr_FR').format(DateTime.parse(forecast.dates[index]));
          final iconPath = chooseMeteoIcon(
            cloudCover: forecast.cloudCover[index],
            precipitation: forecast.precipitation[index],
            utcOffsetSeconds: utcOffsetSeconds,
          );

          return Container(
            width: 140,
            margin: EdgeInsets.symmetric(horizontal: 6),
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8),
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
      ),
    );
  }
}