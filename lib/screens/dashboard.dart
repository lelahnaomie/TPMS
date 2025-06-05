import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetireapp/widgets/pressure_thresholds_card.dart';
import 'package:safetireapp/widgets/sensor_readings_card.dart';
import 'package:safetireapp/widgets/system_monitoring_card.dart';
import 'package:safetireapp/widgets/historical_data_card.dart';
import 'package:safetireapp/widgets/ml_analysis_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
      if (mounted) {
        setState(() {
          isBluetoothConnected = state == BluetoothState.STATE_ON;
        });
      }
    });

    // Listen for Bluetooth state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (mounted) {
        setState(() {
          isBluetoothConnected = state == BluetoothState.STATE_ON;
        });
      }
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
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            minPressure = data['min_pressure']?.toDouble() ?? 28.0;
            maxPressure = data['max_pressure']?.toDouble() ?? 36.0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading pressure thresholds: $e');
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pressure thresholds saved successfully'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      debugPrint('Error saving pressure thresholds: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save pressure thresholds'),
          backgroundColor: Colors.red,
        ));
      }
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Please enter a valid pressure value between 0 and ${maxPressure.toStringAsFixed(1)} PSI'),
                    backgroundColor: Colors.red,
                  ));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Please enter a valid pressure value between ${minPressure.toStringAsFixed(1)} and 100 PSI'),
                    backgroundColor: Colors.red,
                  ));
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

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Connected to Arduino TPMS'),
                  backgroundColor: Colors.green,
                ));
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  void _onExportData() {
    // Implement data export logic here
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data export started'),
      backgroundColor: Colors.blue,
    ));
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

            // Sensor Readings Card
            SensorReadingsCard(
              isBluetoothConnected: isBluetoothConnected,
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
                    minPressure: minPressure,
                    maxPressure: maxPressure,
                    pressureData: pressureData,
                    onSetMinPressure: _showMinPressureDialog,
                    onSetMaxPressure: _showMaxPressureDialog,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: HistoricalDataCard(
                    minPressure: minPressure,
                    maxPressure: maxPressure,
                    onExportData: _onExportData,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Set pressure buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _showMinPressureDialog,
                  child: const Text('Set Min Pressure'),
                ),
                ElevatedButton(
                  onPressed: _showMaxPressureDialog,
                  child: const Text('Set Max Pressure'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ML Analysis Card
            MLAnalysisCard(
              isBluetoothConnected: isBluetoothConnected,
              onRefresh: _onRefreshMLAnalysis,
            ),
          ],
        ),
      ),
    );
  }

  void _onRefreshMLAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('ML Analysis refreshed'),
      backgroundColor: Colors.blue,
    ));
  }
}
