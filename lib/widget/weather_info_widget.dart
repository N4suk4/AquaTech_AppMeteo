import 'package:flutter/material.dart';

class WeatherInfoWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherInfoWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.lightBlue),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}