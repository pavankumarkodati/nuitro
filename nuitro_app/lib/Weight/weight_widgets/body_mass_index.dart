import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nuitro/models/weight_models.dart';

class BmiCard extends StatelessWidget {
  const BmiCard({super.key, required this.bmi});

  final WeightBmiInfo bmi;

  static const double _minPointerBmi = 15;
  static const double _maxPointerBmi = 40;

  @override
  Widget build(BuildContext context) {
    final statusText = bmi.status.isEmpty ? 'Unknown' : bmi.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body Mass Index',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.scale, color: Colors.black54, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI score',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          statusText,
                          style: GoogleFonts.manrope(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      bmi.score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final pointer = _pointerOffset(constraints.maxWidth);
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            children: [
                              _bmiRangeBar(3, Colors.orange),
                              _bmiRangeBar(7, Colors.black),
                              _bmiRangeBar(5, Colors.yellow.shade700),
                              _bmiRangeBar(5, Colors.orangeAccent),
                              _bmiRangeBar(5, Colors.redAccent),
                            ],
                          ),
                          Positioned(
                            left: pointer,
                            top: -6,
                            child: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.red,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('15'),
                    Text('18'),
                    Text('25'),
                    Text('30'),
                    Text('35'),
                    Text('40'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _pointerOffset(double availableWidth) {
    if (availableWidth <= 0) return 0;
    final clamped = bmi.score.clamp(_minPointerBmi, _maxPointerBmi);
    final fraction = (clamped - _minPointerBmi) / (_maxPointerBmi - _minPointerBmi);
    final offset = availableWidth * fraction;
    return offset.clamp(0, availableWidth).toDouble();
  }

  Widget _bmiRangeBar(int flex, Color color) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}