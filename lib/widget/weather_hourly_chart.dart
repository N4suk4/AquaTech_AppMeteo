import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeatherHourlyChart extends StatelessWidget {
  final Map<String, double> hourlyTemps;

  const WeatherHourlyChart({
    super.key,
    required this.hourlyTemps,
  });

  @override
  Widget build(BuildContext context) {
    final hours = hourlyTemps.keys.toList();
    final temps = hourlyTemps.values.toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index % 2 != 0 && index >= hours.length) return Container();
                  return Text(hours[index], style: TextStyle(fontSize: 10));
                },
                reservedSize: 20,
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
      ),
    );
  }
}