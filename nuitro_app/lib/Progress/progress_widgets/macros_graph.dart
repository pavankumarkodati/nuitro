import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/progress_provider.dart';

class MacrosGraph extends StatelessWidget {
  static const List<String> _defaultWeekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final red=Color.fromRGBO(255, 57, 93, 1);
  final orange=Color.fromRGBO(255, 140, 57, 1);
  final purple=Color.fromRGBO(132, 57, 255, 1);
  MacrosGraph ({super.key});

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
              final data = provider.macros;
              final labels = data.labels.isNotEmpty
                  ? _formatLabelsAsWeekdays(data.labels)
                  : _defaultWeekdayLabels;

              List<double> _seriesOrEmpty(String key) {
                final list = data.series[key] ?? const [];
                if (list.isNotEmpty) return list;
                return List<double>.filled(labels.length, 0);
              }
              final carbs = _seriesOrEmpty('carbs');
              final fat = _seriesOrEmpty('fat');
              final protein = _seriesOrEmpty('protein');

              return Column(
              children: [
                /// Total Calories Header
                Container(width: 388,height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 6)],
                  ),
                  child: Column(
                    children: [



                      const SizedBox(height: 25),

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
                              _buildLine(carbs, const Color.fromRGBO(25, 184, 136, 1)),
                              _buildLine(fat, const Color.fromRGBO(57, 172, 255, 1)),
                              _buildLine(protein, const Color.fromRGBO(132, 57, 255, 1)),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(height: 20,),
                      /// Legends
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Legend(color: red, text: "Carbs"),
                          const SizedBox(width: 12),
                           _Legend(color:orange, text: "Fat"),
                          const SizedBox(width: 12),
                          _Legend(color:purple, text: "Protein"),
                         ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),




                /// Summary Cards
                Container(
                  height: 204,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 240, 240, 1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _SummaryCard(
                        kcal: _sum(carbs).toInt(),
                        label: "Carbohydrate",
                        percent: _percentOf(_sum(carbs) + _sum(fat) + _sum(protein), _sum(carbs)),
                        color: red,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              kcal: _sum(fat).toInt(),
                              label: "Fat",
                              percent: _percentOf(_sum(carbs) + _sum(fat) + _sum(protein), _sum(fat)),
                              color: orange,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              kcal: _sum(protein).toInt(),
                              label: "Protein",
                              percent: _percentOf(_sum(carbs) + _sum(fat) + _sum(protein), _sum(protein)),
                              color: purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )

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
        Text(text, style: GoogleFonts.zenKakuGothicAntique(fontSize: 12,color: Colors.grey.shade600,fontWeight: FontWeight.w500)),
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
                  text: " g",
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

              Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700,color: Colors.grey)),

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
