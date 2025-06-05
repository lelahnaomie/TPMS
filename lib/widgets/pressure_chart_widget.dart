import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PressureChartWidget extends StatelessWidget {
  final double minPressure;
  final double maxPressure;
  final List<FlSpot> pressureData;

  const PressureChartWidget({
    Key? key,
    required this.minPressure,
    required this.maxPressure,
    required this.pressureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
