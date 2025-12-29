import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class WeightChartScreen2 extends StatelessWidget {
  const WeightChartScreen2({super.key});



  @override
  Widget build(BuildContext context) {
    return Padding(


        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Weight Chart',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 18),),
         Container(
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.white),
        onPressed: () {},
      ),
    ), ],),

            SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '-8 kg',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '10582 cals gained',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-3251 cals burnt',
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: LineChart(
                      mainData(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 32, // just enough for dates only
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              );

              switch (value.toInt()) {
                case 0:
                  return Text('1 Mar 2022', style: style);
                case 3:
                  return Text('Today', style: style);
                case 5:
                  return Text('18 Jul 2022', style: style);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      lineTouchData: LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 60),
            FlSpot(1, 62),
            FlSpot(2, 60),
            FlSpot(3, 65), // "Today" spot
            FlSpot(4, 68.5), // Intermediate spot for the dotted line
            FlSpot(5, 72),  // "18 July 2022" spot
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.purpleAccent,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              if (index == 0) { // 60kg spot
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: Colors.black,
                );
              } else if (index == 3) { // 65kg spot
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: Colors.black,
                );
              } else if (index == 5) { // 72kg spot
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.orange,
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                );
              }
              return FlDotCirclePainter(
                radius: 0, // Hide other dots
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.withOpacity(0.3),
                Colors.purpleAccent.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Dotted line for future projection
        LineChartBarData(
          spots: const [
            FlSpot(3, 65),
            FlSpot(5, 72),
          ],
          isCurved: false,
          color: Colors.orange,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              if (index == 0) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.orange.withOpacity(0.5),
                  strokeWidth: 0,
                );
              }
              return FlDotCirclePainter(
                radius: 0,
              );
            },
          ),
          dashArray: [5, 5], // Creates the dotted effect
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.3),
                Colors.orange.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      minX: 0,
      maxX: 5,
      minY: 55,
      maxY: 75,
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    String dateText = '';
    Widget? dotLabel;

    switch (value.toInt()) {
      case 0:
        dateText = '1 Mar 2022';
        dotLabel = _buildDotLabel('60 kg');
        break;
      case 3:
        dateText = 'Today';
        dotLabel = _buildDotLabel('65 kg');
        break;
      case 5:
        dateText = '18 Jul 2022';
        dotLabel = _buildDotLabel('72 kg');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotLabel != null && value.toInt() != 5) ...[
            dotLabel,
            const SizedBox(height: 4),
          ],
          Text(dateText, style: style),
          if (dotLabel != null && value.toInt() == 5) ...[
            const SizedBox(height: 4),
            dotLabel,
          ],
        ],
      ),
    );
  }

  Widget _buildDotLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

}