import 'package:flutter/material.dart';


class FitnessPage extends StatelessWidget {
  const FitnessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
         
          const Center(
            child: Text(
              '1200',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const Center(
            child: Text(
              'Kcal',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomPaint(
                painter: FitnessGraphPainter(),
                child: Container(), // CustomPaint needs a child or a defined size
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Sat', style: TextStyle(color: Colors.grey)),
                Text('Sun', style: TextStyle(color: Colors.grey)),
                Text('Mon', style: TextStyle(color: Colors.grey)),
                Text('Tue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                Text('Wed', style: TextStyle(color: Colors.grey)),
                Text('Thr', style: TextStyle(color: Colors.grey)),
                Text('Fri', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20), // Add some space at the bottom
        ],
      )
    ;
  }
}

class FitnessGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF6B8E23) // A darker green for the active part
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintGreyLine = Paint()
      ..color = Colors.grey.shade300 // Lighter grey for the inactive parts
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paintCircleBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paintOuterCircle = Paint()
      ..color = Colors.grey.shade400.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Define the data points for the graph (relative to the height)
    // These are percentages of the graph height, inverted so 0 is top.
    // X values are evenly distributed across the width.
    final List<double> dataPoints = [
      0.6, // Sat (lower)
      0.7, // Sun (even lower)
      0.4, // Mon (medium)
      0.2, // Tue (peak)
      0.45, // Wed (medium-low)
      0.55, // Thr (medium)
      0.75, // Fri (low)
    ];

    final path = Path();
    final double xStep = size.width / (dataPoints.length - 1);

    // Start drawing the path
    path.moveTo(0, dataPoints[0] * size.height);
    for (int i = 1; i < dataPoints.length; i++) {
      final double x = i * xStep;
      final double y = dataPoints[i] * size.height;

      // Use cubic Bezier curves for a smooth, wavy effect like in the image
      // Control points are key for the curve shape. This is an approximation.
      final double previousX = (i - 1) * xStep;
      final double previousY = dataPoints[i - 1] * size.height;

      // Experiment with control points to match the curve
      final double controlPoint1X = previousX + xStep * 0.3;
      final double controlPoint1Y = previousY;
      final double controlPoint2X = x - xStep * 0.3;
      final double controlPoint2Y = y;

      path.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y, x, y);
    }

    // Determine the 'active' segment based on the highlighted 'Tue'
    // 'Tue' is the 4th point (index 3). The active line goes up to this point.
    final Path activePath = Path();
    activePath.moveTo(0, dataPoints[0] * size.height);
    for (int i = 1; i <= 3; i++) { // Draw up to and including 'Tue'
      final double x = i * xStep;
      final double y = dataPoints[i] * size.height;

      final double previousX = (i - 1) * xStep;
      final double previousY = dataPoints[i - 1] * size.height;

      final double controlPoint1X = previousX + xStep * 0.3;
      final double controlPoint1Y = previousY;
      final double controlPoint2X = x - xStep * 0.3;
      final double controlPoint2Y = y;

      activePath.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y, x, y);
    }
    canvas.drawPath(activePath, paintLine);

    // Draw the rest of the path in grey
    final Path inactivePath = Path();
    inactivePath.moveTo(3 * xStep, dataPoints[3] * size.height); // Start from 'Tue'
    for (int i = 4; i < dataPoints.length; i++) {
      final double x = i * xStep;
      final double y = dataPoints[i] * size.height;

      final double previousX = (i - 1) * xStep;
      final double previousY = dataPoints[i - 1] * size.height;

      final double controlPoint1X = previousX + xStep * 0.3;
      final double controlPoint1Y = previousY;
      final double controlPoint2X = x - xStep * 0.3;
      final double controlPoint2Y = y;

      inactivePath.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y, x, y);
    }
    canvas.drawPath(inactivePath, paintGreyLine);


    // Draw the highlighted circle for 'Tue'
    final double activeCircleX = 3 * xStep; // 'Tue' is the 4th point (index 3)
    final double activeCircleY = dataPoints[3] * size.height;

    // Outer faint circle
    canvas.drawCircle(Offset(activeCircleX, activeCircleY), 10, paintOuterCircle);
    // Inner white circle
    canvas.drawCircle(Offset(activeCircleX, activeCircleY), 7, paintCircle);
    // Black border circle
    canvas.drawCircle(Offset(activeCircleX, activeCircleY), 7, paintCircleBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}