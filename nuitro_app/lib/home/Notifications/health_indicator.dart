import 'package:flutter/material.dart';

class HealthIndicator extends StatelessWidget {
  final String ingredientName;
  final double healthPercentage; // 0 to 100

  const HealthIndicator({
    Key? key,
    required this.ingredientName,
    required this.healthPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Clamp percentage between 0 and 100
    final double clampedPercentage = healthPercentage.clamp(0, 100);
    final double trianglePosition = clampedPercentage / 100;

    return Padding(padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredient name + % Healthy
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ingredientName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${clampedPercentage.toStringAsFixed(1)}% Healthy",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Triangle indicator
            // Triangle indicator row
            LayoutBuilder(
              builder: (context, constraints) {
                double triangleX = constraints.maxWidth * trianglePosition;
                return SizedBox(
                  height: 12, // <-- give fixed height
                  child: Stack(
                    children: [
                      Positioned(
                        left: triangleX - 6, // center align triangle
                        child: CustomPaint(
                          size: const Size(12, 8),
                          painter: TrianglePainter(color: Colors.deepOrange),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Colored segmented bar
            Row(
              children: [
                Expanded(child: _buildBarSegment(Colors.red, 0.2)),
                SizedBox(width: 2,), Expanded(child: _buildBarSegment(Colors.orange, 0.2)),
                SizedBox(width: 2,),Expanded(child: _buildBarSegment(Colors.lightGreenAccent, 0.2)),
                SizedBox(width: 2,), Expanded(child: _buildBarSegment(Colors.greenAccent, 0.2)),
                SizedBox(width: 2,), Expanded(child: _buildBarSegment(Colors.green, 0.2)),
              ],
            ),
            const SizedBox(height: 8),

            // Labels under bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("10",style: TextStyle(color: Colors.grey),),

                Text("20",style: TextStyle(color: Colors.grey),),
                Text("40",style: TextStyle(color: Colors.grey),),
                Text("60",style: TextStyle(color: Colors.grey),),
                Text("80",style: TextStyle(color: Colors.grey),),
                Text("100",style: TextStyle(color: Colors.grey),),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBarSegment(Color color, double flex) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    // Inverted triangle
    path.moveTo(0, 0);                // top-left
    path.lineTo(size.width, 0);       // top-right
    path.lineTo(size.width / 2, size.height); // bottom (apex)
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
