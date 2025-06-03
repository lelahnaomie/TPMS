import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isBluetoothConnected = false;

  // Pressure thresholds
  double minPressure = 28.0; // Default minimum pressure
  double maxPressure = 36.0; // Default maximum pressure

  // Controllers for input dialogs
  final TextEditingController _minPressureController = TextEditingController();
  final TextEditingController _maxPressureController = TextEditingController();

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _loadPressureThresholds();

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

  @override
  void dispose() {
    _minPressureController.dispose();
    _maxPressureController.dispose();
    super.dispose();
  }

  // Load pressure thresholds from Firebase
  Future<void> _loadPressureThresholds() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('tpms_settings')
          .doc('pressure_thresholds')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          minPressure = data['min_pressure']?.toDouble() ?? 28.0;
          maxPressure = data['max_pressure']?.toDouble() ?? 36.0;
        });
      }
    } catch (e) {
      print('Error loading pressure thresholds: $e');
      // Use default values if loading fails
    }
  }

  // Save pressure thresholds to Firebase
  Future<void> _savePressureThresholds() async {
    try {
      await _firestore
          .collection('tpms_settings')
          .doc('pressure_thresholds')
          .set({
        'min_pressure': minPressure,
        'max_pressure': maxPressure,
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pressure thresholds saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving pressure thresholds: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save pressure thresholds'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show dialog to set minimum pressure
  void _showMinPressureDialog() {
    _minPressureController.text = minPressure.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Minimum Pressure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _minPressureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Pressure (PSI)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Current: ${minPressure.toStringAsFixed(1)} PSI',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? newValue = double.tryParse(_minPressureController.text);
                if (newValue != null &&
                    newValue > 0 &&
                    newValue < maxPressure) {
                  setState(() {
                    minPressure = newValue;
                  });
                  _savePressureThresholds();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please enter a valid pressure value between 0 and ${maxPressure.toStringAsFixed(1)} PSI'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to set maximum pressure
  void _showMaxPressureDialog() {
    _maxPressureController.text = maxPressure.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Maximum Pressure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _maxPressureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximum Pressure (PSI)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Current: ${maxPressure.toStringAsFixed(1)} PSI',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? newValue = double.tryParse(_maxPressureController.text);
                if (newValue != null &&
                    newValue > minPressure &&
                    newValue < 100) {
                  setState(() {
                    maxPressure = newValue;
                  });
                  _savePressureThresholds();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please enter a valid pressure value between ${minPressure.toStringAsFixed(1)} and 100 PSI'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
            // Pressure Thresholds Display Card
            _buildPressureThresholdsCard(),
            const SizedBox(height: 16),
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

  // New widget to display pressure thresholds
  Widget _buildPressureThresholdsCard() {
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
              'Pressure Thresholds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Minimum Pressure',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Icon(Icons.arrow_downward,
                                color: Colors.blue[700], size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${minPressure.toStringAsFixed(1)} PSI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Maximum Pressure',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Icon(Icons.arrow_upward,
                                color: Colors.green[700], size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${maxPressure.toStringAsFixed(1)} PSI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Optimal Range: ${minPressure.toStringAsFixed(1)} - ${maxPressure.toStringAsFixed(1)} PSI',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
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
                    status: _getPressureStatus(32.5),
                    sensorId: 'FL001',
                    isWarning: !_isPressureNormal(32.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
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
                  child: _buildTirePressureCard(
                    position: 'Rear Left',
                    pressure: 31.5,
                    status: _getPressureStatus(31.5),
                    sensorId: 'RL001',
                    isWarning: !_isPressureNormal(31.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTirePressureCard(
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
                      'Alert: Front Right tire pressure below minimum threshold',
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
                    onPressed: _showMinPressureDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Set Min Pressure'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showMaxPressureDialog,
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
        minY: minPressure - 2,
        maxY: maxPressure + 2,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: minPressure,
              color: Colors.red,
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) =>
                    'Min: ${minPressure.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            HorizontalLine(
              y: maxPressure,
              color: Colors.green,
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) =>
                    'Max: ${maxPressure.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.green, fontSize: 10),
              ),
            ),
          ],
        ),
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
