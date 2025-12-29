import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealSummaryCard extends StatelessWidget {
  final String mealName;
  final int calories;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final double calorieGoal;

  const MealSummaryCard({
    Key? key,
    required this.mealName,
    required this.calories,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    this.calorieGoal = 2000,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double effectiveGoal = calorieGoal > 0
        ? calorieGoal
        : (calories > 0 ? calories.toDouble() : 1);
    final double calorieProgress =
        (calories / effectiveGoal).clamp(0.0, 1.0);
    final String caloriePercentLabel =
        "${(calorieProgress * 100).toStringAsFixed(1)}%";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealName,
          style: GoogleFonts.manrope(
            fontSize:20 ,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        /// Grid layout for nutrients
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            _buildInfoBox(
              title: "Calories",
              value: "$calories kcal",
              color: Color.fromRGBO(226, 242, 255, 1),
              showvalue: true,
              showProgress: false,
              progress: calorieProgress,
              progressLabel: caloriePercentLabel,
            ),
            _buildInfoBox(
              title: "Protein",
              value: "${(proteinPercent * 100).toStringAsFixed(1)}%",
              color: Color.fromRGBO(69, 197, 136, 1),
              progress: proteinPercent,
            ),
            _buildInfoBox(
              title: "Carbs",
              value: "${(carbsPercent * 100).toStringAsFixed(1)}%",
              color: Color.fromRGBO(245, 243, 120, 1),
              progress: carbsPercent,
            ),
            _buildInfoBox(
              title: "Fat",
              value: "${(fatPercent * 100).toStringAsFixed(1)}%",
              color: Color.fromRGBO(225, 182, 182, 1),
              progress: fatPercent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String value,
    required Color color,
    bool showProgress = true,
    bool showvalue=false,
    double progress = 0.0,
    String? progressLabel,
  }) {
    return Container(height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            style:GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
         if (showvalue) Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
          if (showProgress) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.4),
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(progressLabel ?? value, style: GoogleFonts.manrope(fontSize: 13)),
                Text("100%", style: GoogleFonts.manrope(fontSize: 13)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Example usage with backend values:

