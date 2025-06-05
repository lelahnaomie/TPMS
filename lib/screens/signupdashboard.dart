import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DashboardSignup extends StatefulWidget {
  const DashboardSignup({Key? key}) : super(key: key);

  @override
  State<DashboardSignup> createState() => _DashboardSignupState();
}

class _DashboardSignupState extends State<DashboardSignup> {
  bool isBluetoothConnected = false;
  double minPressure = 0.0;
  double maxPressure = 0.0;

  final List<FlSpot> pressureData = [];

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {});
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {});
    });
  }

  void _connectToDevice() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect to Arduino'),
          content: const Text('Scanning for TPMS Arduino device'),
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

  void _setPressure(String type) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Set ${type == 'min' ? 'Minimum' : 'Maximum'} Pressure'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter pressure in PSI'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                double? value = double.tryParse(controller.text);
                if (value != null) {
                  setState(() {
                    if (type == 'min') {
                      minPressure = value;
                    } else {
                      maxPressure = value;
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Set'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
            onPressed: () => _setPressure('min'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0078D4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Min Pressure'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _setPressure('max'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0078D4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Max Pressure'),
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
                          const Icon(Icons.bluetooth_connected,
                              color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text('Live Data',
                              style: TextStyle(color: Colors.blue)),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(Icons.bluetooth_disabled,
                              color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('Offline Mode',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 16),
            // First row - Front Left and Front Right
            Row(
              children: [
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Front Left',
                    pressure: 0.0,
                    status: 'Normal',
                    sensorId: 'FL001',
                    isWarning: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Front Right',
                    pressure: 0.0,
                    status: 'Warning',
                    sensorId: 'FR001',
                    isWarning: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Second row - Rear Left and Rear Right
            Row(
              children: [
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Rear Left',
                    pressure: 0.0,
                    status: 'Normal',
                    sensorId: 'RL001',
                    isWarning: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
                    position: 'Rear Right',
                    pressure: 0.0,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
                // No historical data initially
              ],
            ),
          ],
        ),
      ),
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
                            ? 'Data stream Active'
                            : 'No live Data',
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
                    'No predictions available yet.',
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
                  const Text('No anomalies detected.'),
                  const SizedBox(height: 4),
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
