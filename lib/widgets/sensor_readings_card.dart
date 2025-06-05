import 'package:flutter/material.dart';
import 'tire_pressure_card.dart';

class SensorReadingsCard extends StatelessWidget {
  final bool isBluetoothConnected;
  final double minPressure;
  final double maxPressure;

  const SensorReadingsCard({
    Key? key,
    required this.isBluetoothConnected,
    required this.minPressure,
    required this.maxPressure,
  }) : super(key: key);

  // Helper methods to determine pressure status
  bool _isPressureNormal(double pressure) {
    return pressure >= minPressure && pressure <= maxPressure;
  }

  String _getPressureStatus(double pressure) {
    if (pressure < minPressure) {
      return 'Low';
    } else if (pressure > maxPressure) {
      return 'High';
    } else {
      return 'Normal';
    }
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Real-time Sensor Readings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isBluetoothConnected
                    ? Row(
                        children: [
                          Icon(Icons.bluetooth_connected, color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text('Live Data',
                              style: TextStyle(color: Colors.blue)),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.bluetooth_disabled, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('Offline Mode',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TirePressureCard(
                    position: 'Front Left',
                    pressure: 32.5,
                    status: _getPressureStatus(32.5),
                    sensorId: 'FL001',
                    isWarning: !_isPressureNormal(32.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TirePressureCard(
                    position: 'Front Right',
                    pressure: 29.8,
                    status: _getPressureStatus(29.8),
                    sensorId: 'FR001',
                    isWarning: !_isPressureNormal(29.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TirePressureCard(
                    position: 'Rear Left',
                    pressure: 31.5,
                    status: _getPressureStatus(31.5),
                    sensorId: 'RL001',
                    isWarning: !_isPressureNormal(31.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TirePressureCard(
                    position: 'Rear Right',
                    pressure: 33.2,
                    status: _getPressureStatus(33.2),
                    sensorId: 'RR001',
                    isWarning: !_isPressureNormal(33.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
