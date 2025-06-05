import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the separated widgets
import 'package:safetireapp/widgets/pressure_thresholds_card.dart';
import 'package:safetireapp/widgets/sensor_readings_card.dart';
import 'package:safetireapp/widgets/system_monitoring_card.dart';
import 'package:safetireapp/widgets/historical_data_card.dart';
import 'package:safetireapp/widgets/ml_analysis_card.dart';

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

  void _calibrateSensors() {
    // Handle sensor calibration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calibrating sensors...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportData() {
    // Handle data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting data...'),
        backgroundColor: Colors.blue,
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
          // Min Pressure Button
          ElevatedButton(
            onPressed: _showMinPressureDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0078D4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Min Pressure'),
          ),
          const SizedBox(width: 10),
          // Max Pressure Button
          ElevatedButton(
            onPressed: _showMaxPressureDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0078D4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Max Pressure'),
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
            PressureThresholdsCard(
              minPressure: minPressure,
              maxPressure: maxPressure,
            ),
            const SizedBox(height: 16),
            SensorReadingsCard(
              isBluetoothConnected: isBluetoothConnected,
              getPressureStatus: _getPressureStatus,
              isPressureNormal: _isPressureNormal,
              minPressure: minPressure,
              maxPressure: maxPressure,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SystemMonitoringCard(
                    pressureData: pressureData,
                    minPressure: minPressure,
                    maxPressure: maxPressure,
                    onCalibrateSensors: _calibrateSensors,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: HistoricalDataCard(
                    getPressureStatus: _getPressureStatus,
                    isPressureNormal: _isPressureNormal,
                    onExportData: _exportData,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MLAnalysisCard(
              isBluetoothConnected: isBluetoothConnected,
            ),
          ],
        ),
      ),
    );
  }
}
