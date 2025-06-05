import 'package:flutter/material.dart';

class TirePressureCard extends StatelessWidget {
  final String position;
  final double pressure;
  final String status;
  final String sensorId;
  final bool isWarning;

  const TirePressureCard({
    Key? key,
    required this.position,
    required this.pressure,
    required this.status,
    required this.sensorId,
    required this.isWarning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status == 'Low') {
      statusColor = Colors.red;
    } else if (status == 'High') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            position,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${pressure.toStringAsFixed(1)} PSI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: $status',
            style: TextStyle(
              fontSize: 14,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Sensor ID: $sensorId',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
