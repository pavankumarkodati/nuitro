import 'package:flutter/material.dart';
import 'dart:math';

class HydrationTrackerPage extends StatelessWidget {
  final double goal;
  final double intake;
  final String tip;
  final ValueChanged<double>? onLogWater;

  const HydrationTrackerPage({
    super.key,
    required this.goal,
    required this.intake,
    this.tip = '',
    this.onLogWater,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = goal == 0 ? 0 : (intake / goal).clamp(0.0, 1.0);

    return Column(children: [
      // Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Water",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ],
      ),

      const SizedBox(height: 15),

      // Main Card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDDB6F2), // light purple background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hydration Tip
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.isNotEmpty ? tip : "Keep up the great work!",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Semi-circle Progress with Sphere
            SizedBox(
              height: 180,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sphere background
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [

                          Colors.purple.shade100,
                          Colors.grey,
                        ],
                        center: Alignment.center,
                        radius: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),

                  // Arc painter
                  CustomPaint(
                    size: const Size(180, 180),
                    painter: WaterArcPainter(progress),
                  ),

                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        intake.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "/${goal.toInt()}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  // 0 and 100 labels
                  Positioned(
                    left: 0,
                    bottom: 25,
                    child: const Text("0",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 25,
                    child: const Text("100",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Motivational text
            const Text(
              "Woah! You’re almost there!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Quickly add a portion of water.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // Drink Options
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DrinkCard(label: "450 ml", amount: 450, onTap: onLogWater),
                  DrinkCard(label: "150 ml", amount: 150, onTap: onLogWater),
                  DrinkCard(label: "250 ml", amount: 250, onTap: onLogWater),
                  DrinkCard(label: "Custom", amount: 200, onTap: onLogWater, isAdd: true),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

// Custom painter for semi-circle arc
class WaterArcPainter extends CustomPainter {
  final double progress; // value between 0 and 1
  WaterArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 30;
    double radius = size.width / 1.65;

    Paint bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);

    // Semi-circle background (180°)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      pi, // start from left
      pi, // sweep 180 degrees
      false,
      bgPaint,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      pi,
      pi * progress, // progress mapped to half-circle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Drink Card widget
class DrinkCard extends StatelessWidget {
  final String label;
  final ValueChanged<double>? onTap;
  final double amount;
  final bool isAdd;

  const DrinkCard({
    super.key,
    required this.label,
    required this.amount,
    this.onTap,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(amount),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(235, 235, 235, 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drink',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/waterglass.png', height: 30),
                if (isAdd)
                  const Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.black,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
