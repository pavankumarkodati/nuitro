import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/Weight/weight_widgets/personal_reward.dart';

import '../../Progress/progress_widgets/challenges.dart';





class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double consumedCalories = 2300;
    final double totalCalories = 3600;

    double progress = consumedCalories / totalCalories;

    return Scaffold(backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAchievementsHeader(context),
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(38, 50, 56, 1),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),

                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Cal Progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: 5),


                        Stack(
                          alignment: Alignment.center,
                          children: [ Center(
                            child: CustomPaint(
                              size: const Size(220, 120),
                              painter: ArcPainter(progress),
                            ),),
                            Column( mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [SizedBox(height: 30,),
                                const Icon(Icons.local_fire_department_outlined,
                                    color: Color(0xFF9EE37D)),
                                const Text("Calories",
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF9EE37D))),
                                Text(
                                  "1739",
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text("You are doing excellent",
                                    style: TextStyle(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                          ],
                        )

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Overview',
                  style: TextStyle(fontSize: 18,fontWeight:FontWeight.w600 )  ),
                const SizedBox(height: 20),
                _buildCardsGrid(),

                const SizedBox(height: 20),
            Container(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenges Title
                    Text(
                      "Challenges",
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Challenges Cards (Horizontal)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _ChallengeCard(
                            icon: Icons.directions_run,
                            title: "7 days Streak Fitness",
                            subtitle: "2 Activities Left",
                            calories: "-545 kcal burnt",
                          ),
                          const SizedBox(width: 12),
                          _ChallengeCard(
                            icon: Icons.local_drink,
                            title: "5 Glass Water",
                            subtitle: "2 Left",
                            calories: "",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Protein Boost Tip Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(226, 242, 255, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                "Protein Boost Tip:",
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bulletText("Great job! You’re down 1kg this month. Try adding 10g protein daily to maintain muscle."),
                          ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Activity Title
                    _BottomInfoCard(title: 'Start protein challenge', subtitle: 'Log 2 protein meal to mark 1 day',),

                    const SizedBox(height: 10),

                    // Activity Card

                  ],
                ),
              ),
            ),
            GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RewardsPage()),
                );


              },
              child: Container(
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Left side - Icon/Badge
                    Column(
                      children: [
                        const Text(
                          "Lvl-1",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 60,

                          child: Image.asset('assets/images/badge.png')
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    /// Right side - Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Congratulations!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Text(
                                "Crushed it!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "— Logged first meal",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF2C2C2C),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () {
              // Handle back button press
            },
          ),
        ),
        Text(
          'ACHIEVEMENTS',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF6CBB3C), // Greenish background
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              const SizedBox(width: 5),
              Text(
                '12 days',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildDot(bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF6CBB3C) : Colors.grey.shade700,
          shape: BoxShape.circle,
        ),
      ),
    );
  }



  Widget _buildInfoCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onPressed, {
        bool isProgress = false,
      }) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: isProgress ? Color(0xFF6CBB3C) : Colors.white70, // Green for progress
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    icon,
                    color: isProgress ? Color(0xFF6CBB3C) : Colors.white70, // Green for progress icon
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the circular progress gauge
class GaugePainter extends CustomPainter {
  final double progress; // Progress from 0.0 to 1.0

  GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 25.0; // Thickness of the arc
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc (dark gray)
    final backgroundPaint = Paint()
      ..color = Colors.grey
          .shade800 // Or a darker shade of your scaffold background
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Progress arc (green)
    final progressPaint = Paint()
      ..color = Color(0xFF6CBB3C) // Your green color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    // Start slightly after 180 degrees (PI) to leave space for the gap at the top
    // Sweep for almost a full circle, leaving a gap
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.2 * 3.14159, // Start angle (slightly after PI, adjusted for visual)
      1.6 * 3.14159, // Sweep angle (e.g., 1.6 * PI for a large arc)
      false,
      backgroundPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.2 * 3.14159, // Same start angle as background
      1.6 * 3.14159 * progress, // Progressed sweep angle
      false,
      progressPaint,
    );

    // Draw the flame icon in the center if needed, or overlay it with a Stack
    // For simplicity, the flame icon is part of the Stack in the _buildCalProgressSection
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }}

class ArcPainter extends CustomPainter {
  final double progress;

  ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    const double startAngle = pi;
    const double sweepAngle = pi;

    /// ---- Background Arc (grey) ----
    final Paint bgPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    /// ---- Border Paint (thicker) ----
    final Paint borderPaint = Paint()
      ..color = Color.fromRGBO(173, 253, 5, 1) // <-- border color
      ..strokeWidth = 20 // slightly larger than progress arc
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, borderPaint);

    /// ---- Foreground Arc (main progress) ----
    final Paint fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi,
        endAngle: 2 * pi,
        colors: [
          const Color.fromRGBO(173, 253, 5, 1),
          const Color.fromRGBO(173, 253, 5, 1),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: 100,
      ))
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
































































  /// Builds the 2x2 grid of cards.
  Widget _buildCardsGrid() {
    return Column(
      children: [
        // First row of cards
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'Log Food',
                details: '3 Meal per Day',
                icon: Icons.arrow_forward,
              ),
            ),
            const SizedBox(width: 16.0), // Spacing between cards in a row
            Expanded(
              child: _buildInfoCard(
                title: 'Water Log',
                details: '2052ml per Day',
                icon: Icons.arrow_forward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0), // Spacing between rows of cards
        // Second row of cards
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'Excercise', // Note: "Excercise" is used as in the image (typo)
                details: '2 Activities per day',
                icon: Icons.arrow_forward,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildProgressCard(
                title: 'Progress',
                percentage: 63,
                change: 5,
                icon: Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a generic information card (Log Food, Water Log, Excercise).
  Widget _buildInfoCard({
    required String title,
    required String details,
    required IconData icon,
  }) {
    return Card(
      elevation: 0, // No shadow for the cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
      ),
      color: Color.fromRGBO(226, 242, 255, 0.99), // A light blueish background color for the cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(icon, color: Colors.black54, size: 20),
              ],
            ),
            const SizedBox(height: 8.0), // Spacing between title row and details
            Text(
              details,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the specific "Progress" card with percentage and change.
  Widget _buildProgressCard({
    required String title,
    required int percentage,
    required int change,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: const Color(0xFFE0F2F7), // Same light blueish background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(icon, color: Colors.black54, size: 20),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              // Align the baseline of the percentage and change text
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 28, // Larger font size for the percentage
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4), // Small space between percentage and arrow
                Icon(
                  Icons.arrow_upward, // Up arrow icon for positive change
                  color: Colors.green[600], // Green color for positive change
                  size: 18,
                ),
                Text(
                  '+$change',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600], // Green color for positive change
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
class _ChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String calories;

  const _ChallengeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center,
      width: 306,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.grey.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),

                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(children: [ Text(
                    subtitle,

                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                    if (calories.isNotEmpty)
                      Flexible(
                        child: Text(
                          calories,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),],),
                )
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}
Widget _bulletText(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 16)),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BottomInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onStart;

  const _BottomInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // card look
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // left: small icon + title/subtitle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department_outlined, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 14)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),

          // Start button
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(220, 250, 157, 1) , // pale green like design
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
