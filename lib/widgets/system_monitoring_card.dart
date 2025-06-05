import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pressure_chart_widget.dart';

class SystemMonitoringCard extends StatelessWidget {
  final double minPressure;
  final double maxPressure;
  final VoidCallback onSetMinPressure;
  final VoidCallback onSetMaxPressure;
  final List<FlSpot> pressureData;

  const SystemMonitoringCard({
    Key? key,
    required this.minPressure,
    required this.maxPressure,
    required this.onSetMinPressure,
    required this.onSetMaxPressure,
    required this.pressureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Monitoring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alert: Front Right tire pressure below minimum threshold',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(8),
              child: PressureChartWidget(
                minPressure: minPressure,
                maxPressure: maxPressure,
                pressureData: pressureData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
