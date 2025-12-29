import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';



class MoodTrendScreen extends StatelessWidget {
  const MoodTrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Mood Trend',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E0FF), // Light purple background
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200, // Height of the chart
                        child: LineChart(
                          _mainData(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Your high-protein lunch may be boosting your energy!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0x33924AEF), // Faint purple grid line
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('Mon', style: style);
                  break;
                case 1:
                  text = const Text('Tue', style: style);
                  break;
                case 2:
                  text = const Text('Wed', style: style);
                  break;
                case 3:
                  text = const Text('Thu', style: style);
                  break;
                case 4:
                  text = const Text('Fri', style: style);
                  break;
                case 5:
                  text = const Text('Sat', style: style);
                  break;
                case 6:
                  text = const Text('Sun', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 100:
                  text = '100';
                  break;
                case 200:
                  text = '200';
                  break;
                case 300:
                  text = '300';
                  break;
                case 400:
                  text = '400';
                  break;
                default:
                  return Container();
              }
              return Text(text, style: style, textAlign: TextAlign.left);
            },
            interval: 100, // Adjust interval to match the image
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false, // No border around the chart itself
      ),
      minX: 0,
      maxX: 6,
      minY: 0, // Start y-axis from 0
      maxY: 450, // Max y-axis value, slightly above 400
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 260), // Mon
            FlSpot(1, 220), // Tue
            FlSpot(2, 300), // Wed
            FlSpot(3, 190), // Thu
            FlSpot(4, 260), // Fri
            FlSpot(5, 170), // Sat
            FlSpot(6, 220), // Sun
          ],
          isCurved: true,
          color: Colors.black87,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 120), // Mon
            FlSpot(1, 200), // Tue
            FlSpot(2, 180), // Wed
            FlSpot(3, 420), // Thu
            FlSpot(4, 300), // Fri
            FlSpot(5, 330), // Sat
            FlSpot(6, 160), // Sun
          ],
          isCurved: true,
          color: Colors.deepOrange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
    );
  }
}