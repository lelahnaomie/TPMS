import 'package:flutter/material.dart';

class HistoricalDataCard extends StatelessWidget {
  final double minPressure;
  final double maxPressure;
  final VoidCallback onExportData;

  const HistoricalDataCard({
    Key? key,
    required this.minPressure,
    required this.maxPressure,
    required this.onExportData,
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

  TableRow _buildHistoricalDataRow({
    required String time,
    required String sensor,
    required double pressure,
    required String status,
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

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(time),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(sensor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('${pressure.toStringAsFixed(1)} PSI'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
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
            const Text(
              'Historical Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(0.8),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(0.8),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Timestamps',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Sensor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Pressure',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                _buildHistoricalDataRow(
                  time: '14:30:22',
                  sensor: 'FR001',
                  pressure: 29.8,
                  status: _getPressureStatus(29.8),
                  isWarning: !_isPressureNormal(29.8),
                ),
                _buildHistoricalDataRow(
                  time: '14:30:20',
                  sensor: 'FL001',
                  pressure: 32.5,
                  status: _getPressureStatus(32.5),
                  isWarning: !_isPressureNormal(32.5),
                ),
                _buildHistoricalDataRow(
                  time: '14:30:18',
                  sensor: 'RR001',
                  pressure: 31.5,
                  status: _getPressureStatus(31.5),
                  isWarning: !_isPressureNormal(31.5),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Export Data button placed under the table
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onExportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Export Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
