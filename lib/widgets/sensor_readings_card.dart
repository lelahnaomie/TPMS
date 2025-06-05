import 'package:flutter/material.dart';

class SensorReadingsCard extends StatelessWidget {
  final bool isBluetoothConnected;
  final String Function(double) getPressureStatus;
  final bool Function(double) isPressureNormal;
  final double minPressure;
  final double maxPressure;

  const SensorReadingsCard({
    Key? key,
    required this.isBluetoothConnected,
    required this.getPressureStatus,
    required this.isPressureNormal,
    required this.minPressure,
    required this.maxPressure,
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
                  child: _buildTirePressureCard(
                    position: 'Front Left',
                    pressure: 32.5,
                    status: getPressureStatus(32.5),
                    sensorId: 'FL001',
                    isWarning: !isPressureNormal(32.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Front Right',
                    pressure: 29.8,
                    status: getPressureStatus(29.8),
                    sensorId: 'FR001',
                    isWarning: !isPressureNormal(29.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Rear Left',
                    pressure: 31.5,
                    status: getPressureStatus(31.5),
                    sensorId: 'RL001',
                    isWarning: !isPressureNormal(31.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Rear Right',
                    pressure: 33.2,
                    status: getPressureStatus(33.2),
                    sensorId: 'RR001',
                    isWarning: !isPressureNormal(33.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTirePressureCard({
    required String position,
    required double pressure,
    required String status,
    required String sensorId,
    required bool isWarning,
  }) {
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
