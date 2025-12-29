import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/progress_models.dart';
import 'package:nuitro/providers/progress_provider.dart';

class CalorieChartScreen extends StatelessWidget {
  static const List<String> _defaultWeekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  CalorieChartScreen({super.key});

  static List<String> _formatLabelsAsWeekdays(List<String> rawLabels) {
    bool converted = false;
    final formatted = <String>[];
    for (final label in rawLabels) {
      final parsed = _tryParseDateLabel(label);
      if (parsed != null) {
        converted = true;
        formatted.add(_defaultWeekdayLabels[(parsed.weekday - 1) % _defaultWeekdayLabels.length]);
      } else {
        formatted.add(label);
      }
    }

    if (!converted) {
      return List<String>.from(rawLabels);
    }
    return formatted;
  }

  static DateTime? _tryParseDateLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final isoParsed = DateTime.tryParse(trimmed);
    if (isoParsed != null) {
      return isoParsed;
    }

    for (final separator in ['/', '-']) {
      if (!trimmed.contains(separator)) continue;

      final parts = trimmed.split(separator).where((part) => part.isNotEmpty).toList();
      if (parts.length != 3) continue;

      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);

      if (first == null || second == null || third == null) {
        continue;
      }

      int year;
      int month;
      int day;

      if (parts[0].length == 4) {
        year = first;
        month = second;
        day = third;
      } else if (parts[2].length == 4) {
        year = third;
        if (first > 12 && second <= 12) {
          day = first;
          month = second;
        } else if (second > 12 && first <= 12) {
          month = first;
          day = second;
        } else {
          month = first;
          day = second;
        }
      } else {
        continue;
      }

      if (month < 1 || month > 12 || day < 1 || day > 31) {
        continue;
      }

      try {
        return DateTime(year, month, day);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Consumer<ProgressProvider>(
            builder: (context, provider, _) {
              final ProgressCaloriesData data = provider.calories;
              final labels = data.labels.isNotEmpty
                  ? _formatLabelsAsWeekdays(data.labels)
                  : _defaultWeekdayLabels;
              // Normalize series keys we expect; fallback to empty lists with correct length
              List<double> _seriesForKeys(List<String> keys) {
                for (final k in keys) {
                  final list = data.series[k];
                  if (list != null && list.isNotEmpty) return list;
                }
                return List<double>.filled(labels.length, 0);
              }
              final breakfast = _seriesForKeys(['breakfast']);
              final lunch = _seriesForKeys(['lunch']);
              final dinner = _seriesForKeys(['dinner']);
              final other = _seriesForKeys(['other', 'snacks']);

              final total = data.summary.total;
              final avg = data.summary.average;
              final goal = data.summary.goal;

              return Column(
              children: [
                /// Total Calories Header
                Container(width: 388,height: 371,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(25,10,25,16 ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(  left: Radius.circular(50),   // round left side
                              right: Radius.circular(50)),  color: Colors.white
                          ,
                        ),
                        child: Text(
                          "${total.toStringAsFixed(0)} kcal",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(height: 10,),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(fontSize: 12, color: Color.fromRGBO(117, 117, 117, 1),fontWeight: FontWeight.w500), // default style
                          children: [
                            TextSpan(
                              text: "${avg.toStringAsFixed(0)} ",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700), // grey label
                            ),
                            TextSpan(
                              text: "Avg cals ",

                            ),
                            TextSpan(
                              text: "  -  ",

                            ),
                            TextSpan(
                              text: "${goal.toStringAsFixed(0)} ",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700), // grey label
                            ),
                            TextSpan(
                              text: "Goal Cals",

                            ),
                          ],
                        ),
                      )
                      ,const SizedBox(height: 16),

                      /// Line Chart
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(

                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles:false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(interval: 1,
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx >= 0 && idx < labels.length) {
                                      return Text(labels[idx],style: GoogleFonts.manrope(fontSize: 13,fontWeight: FontWeight.w400,color: Color.fromRGBO(18, 18, 18, 1)),);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(show: true,

                              drawHorizontalLine: false,
                              drawVerticalLine: true,
                            ),
                            borderData: FlBorderData(show: false),

                            lineBarsData: [
                              _buildLine(breakfast, Colors.black,),
                              _buildLine(lunch, const Color.fromRGBO(25, 184, 136, 1)),
                              _buildLine(dinner, const Color.fromRGBO(57, 172, 255, 1)),
                              _buildLine(other, const Color.fromRGBO(132, 57, 255, 1)),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(height: 5,),
                      /// Legends
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _Legend(color: Colors.black, text: "Breakfast"),
                          SizedBox(width: 12),
                          _Legend(color:Color.fromRGBO(25, 184, 136, 1), text: "Lunch"),
                          SizedBox(width: 12),
                          _Legend(color:Color.fromRGBO(57, 172, 255, 1), text: "Dinner"),
                          SizedBox(width: 12),
                          _Legend(color: Color.fromRGBO(132, 57, 255, 1), text: "Other"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Summary Cards
                Container(height:204,decoration: BoxDecoration(color:Color.fromRGBO(240, 240, 240, 1) ,borderRadius: BorderRadius.circular(25)),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _SummaryCard(
                        kcal: _sum(breakfast).toInt(),
                        label: "Breakfast",
                        percent: _percentOf(total, _sum(breakfast)),
                        color: Colors.green,
                      ),
                      _SummaryCard(
                        kcal: _sum(lunch).toInt(),
                        label: "Lunch",
                        percent: _percentOf(total, _sum(lunch)),
                        color: Colors.blue,
                      ),
                      _SummaryCard(
                        kcal: _sum(dinner).toInt(),
                        label: "Dinner",
                        percent: _percentOf(total, _sum(dinner)),
                        color: Colors.purple,
                      ),
                      _SummaryCard(
                        kcal: _sum(other).toInt(),
                        label: "Other",
                        percent: _percentOf(total, _sum(other)),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            );
            },
          ),
        ),
      );
  }

  /// Builds a line with white circle at end
  LineChartBarData _buildLine(List<double> data, Color color) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
      ],
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (index == data.length - 1) {
            // Only show circle at last point
            return FlDotCirclePainter(
              radius: 3,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: color,
            );
          }
          return FlDotCirclePainter(radius: 0); // invisible
        },
      ),
      belowBarData: BarAreaData(show: true,
        gradient: LinearGradient( // gradient fill
          colors: [
            Colors.blue.withOpacity(0.13),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

      ),

    );
  }

  static double _sum(List<double> values) => values.fold(0.0, (a, b) => a + b);
  static int _percentOf(double total, double part) {
    if (total <= 0) return 0;
    final p = (part / total) * 100;
    return p.isNaN || p.isInfinite ? 0 : p.round();
  }
}

/// Legend Widget
class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 7 ,height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Summary Card Widget
class _SummaryCard extends StatelessWidget {
  final int kcal;
  final String label;
  final int percent;
  final Color color;

  const _SummaryCard({
    required this.kcal,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(16),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 24, color: Colors.black,fontWeight: FontWeight.w700), // default style
              children: [
                TextSpan(
                  text: '$kcal',
                  // grey label
                ),
                TextSpan(
                  text: " kcal",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ), // black bold number
                ),

              ],
            ),
          )
          ,

          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600)),

              const SizedBox(width: 8),
              Text("$percent%", style: const TextStyle(fontSize: 12,color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent / 100,
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight:3 ,

            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
