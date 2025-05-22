import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isBluetoothConnected = false;

  // Sample pressure data points for the chart
  final List<FlSpot> pressureData = [
    const FlSpot(0, 32.0),
    const FlSpot(1, 32.2),
    const FlSpot(2, 31.8),
    const FlSpot(3, 31.5),
    const FlSpot(4, 30.8),
    const FlSpot(5, 30.2),
    const FlSpot(6, 29.8),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Bluetooth state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {});
    });

    // Listen for Bluetooth state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {});
    });
  }

  void _connectToDevice() {
    // Show a dialog to connect to a Bluetooth device
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect to Arduino'),
          content: const Text('Scanning for TPMS Arduino devices...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isBluetoothConnected = true;
                });
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connected to Arduino TPMS'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tire Pressure Monitoring Sensor',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Bluetooth connection indicator and button
          IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: isBluetoothConnected ? Colors.blue : Colors.grey,
              size: 28,
            ),
            onPressed: _connectToDevice,
            tooltip: isBluetoothConnected
                ? 'Connected to Arduino'
                : 'Connect to Arduino',
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0078D4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Calibrate Sensors'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text('Export Data'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorReadingsCard(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildSystemMonitoringCard(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildHistoricalDataCard(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMLAnalysisCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorReadingsCard() {
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
                    status: 'Normal',
                    sensorId: 'FL001',
                    isWarning: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Front Right',
                    pressure: 29.8,
                    status: 'Warning',
                    sensorId: 'FR001',
                    isWarning: true,
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
                    pressure: 32.0,
                    status: 'Normal',
                    sensorId: 'RL001',
                    isWarning: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Rear Right',
                    pressure: 31.5,
                    status: 'Normal',
                    sensorId: 'RR001',
                    isWarning: false,
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
    Color statusColor = isWarning ? Colors.orange : Colors.green;

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
            style: const TextStyle(
              fontSize: 14,
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

  Widget _buildSystemMonitoringCard() {
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
                      'Alert: Front Right tire pressure below threshold',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Set Min pressure'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Set Max Pressure'),
                  ),
                ),
              ],
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
              child: _buildPressureChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}m',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()} PSI',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 42,
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        minX: 0,
        maxX: 6,
        minY: 28,
        maxY: 34,
        lineBarsData: [
          LineChartBarData(
            spots: pressureData,
            isCurved: true,
            color: const Color(0xFF0078D4),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF0078D4).withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalDataCard() {
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
                  status: 'Warning',
                  isWarning: true,
                ),
                _buildHistoricalDataRow(
                  time: '14:30:20',
                  sensor: 'FL001',
                  pressure: 32.5,
                  status: 'Normal',
                  isWarning: false,
                ),
                _buildHistoricalDataRow(
                  time: '14:30:18',
                  sensor: 'RR001',
                  pressure: 31.5,
                  status: 'Normal',
                  isWarning: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHistoricalDataRow({
    required String time,
    required String sensor,
    required double pressure,
    required String status,
    required bool isWarning,
  }) {
    Color statusColor = isWarning ? Colors.orange : Colors.green;

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
            style: TextStyle(color: statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildMLAnalysisCard() {
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
                  'ML Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBluetoothConnected
                        ? Colors.green[100]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBluetoothConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        size: 16,
                        color: isBluetoothConnected
                            ? Colors.green[800]
                            : Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBluetoothConnected
                            ? 'Data Stream Active'
                            : 'No Live Data',
                        style: TextStyle(
                          color: isBluetoothConnected
                              ? Colors.green[800]
                              : Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Predictions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Based on current trends:'),
                  const SizedBox(height: 4),
                  Text(
                    'Front Right tire may need attention within 48 hours',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anomaly Detection',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Unusual pressure fluctuation detected in:'),
                  const SizedBox(height: 4),
                  Text(
                    'Front Right Sensor (FR001)',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
