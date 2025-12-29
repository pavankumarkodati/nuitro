import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/weight_models.dart';
import 'package:nuitro/providers/weight_provider.dart';

class WeightChartScreen extends StatefulWidget {
  const WeightChartScreen({super.key});

  @override
  State<WeightChartScreen> createState() => _WeightChartScreenState();
}

class _WeightChartScreenState extends State<WeightChartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WeightProvider>();
      if (!provider.hasLoadedOnce) {
        provider.fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Consumer<WeightProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasLoadedOnce) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.errorMessage != null && provider.errorMessage!.isNotEmpty) {
            return Column(
              children: [
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: provider.refreshDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            );
          }

          final WeightDashboardData data = provider.dashboard;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight Chart',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: provider.refreshDashboard,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: data.trend.isEmpty
                    ? const Center(child: Text('No weight data available'))
                    : _WeightChart(trend: data.trend),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _WeightInfoCard(
                      label: 'Goal Weight',
                      value: data.goalWeight.toStringAsFixed(1),
                      unit: 'kg',
                      progressText: _goalDateText(data.projectedGoalDate),
                      progress: data.progressPercent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _WeightInfoCard(
                      label: 'Current weight',
                      value: data.currentWeight.toStringAsFixed(1),
                      unit: 'kg',
                      progressText: '${(data.progressPercent * 100).round()}%',
                      progress: data.progressPercent,
                      icon: Icons.edit,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String _goalDateText(DateTime? date) {
    if (date == null) {
      return 'Set a goal';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.trend});

  final List<WeightTrendPoint> trend;

  @override
  Widget build(BuildContext context) {
    final labels = trend.map((e) => '${e.date.month}/${e.date.day}').toList();
    final weights = trend.map((e) => e.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final double range = (maxWeight - minWeight).abs().clamp(1.0, double.infinity).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomPaint(
            painter: WeightChartPainter(trend: trend, minWeight: minWeight, range: range),
            child: Container(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels.first,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              labels.last,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeightInfoCard extends StatelessWidget {
  const _WeightInfoCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.progressText,
    required this.progress,
    this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final String progressText;
  final double progress;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              if (icon != null) Icon(icon, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  WeightChartPainter({required this.trend, required this.minWeight, required this.range});

  final List<WeightTrendPoint> trend;
  final double minWeight;
  final double range;

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blueGrey.withOpacity(0.2),
          Colors.blueGrey.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < trend.length; i++) {
      final point = trend[i];
      final dx = (i / (trend.length - 1)) * size.width;
      final dy = size.height - ((point.weightKg - minWeight) / range) * size.height;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    final latest = trend.last;
    final latestDx = size.width;
    final latestDy = size.height - ((latest.weightKg - minWeight) / range) * size.height;
    canvas.drawCircle(Offset(latestDx, latestDy), 6, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(latestDx, latestDy), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.trend != trend ||
        oldDelegate.minWeight != minWeight ||
        oldDelegate.range != range;
  }
}