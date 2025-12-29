import 'package:flutter/material.dart';

class DietSummaryCard extends StatelessWidget {
  final int calories;
  final double? calorieGoal;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  const DietSummaryCard({
    Key? key,
    required this.calories,
    this.calorieGoal,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = calorieGoal != null && calorieGoal! > 0
        ? (calories / calorieGoal!).clamp(0.0, 1.0)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.4,
          children: [
            _buildInfoBox(
              title: "Calories",
              value: "$calories kcal",
              color: const Color.fromRGBO(226, 242, 255, 1),
              showProgress: progress != null,
              showvalue: true,
              progressValue: progress,
              trailingValue: calorieGoal != null
                  ? "${calorieGoal!.toStringAsFixed(0)} kcal"
                  : "Goal",
            ),
            _buildInfoBox(
              title: "Protein",
              value: "${(proteinPercent * 100).toStringAsFixed(1)}%",
              color: const Color.fromRGBO(69, 197, 136, 1),
              progressValue: proteinPercent,
            ),
            _buildInfoBox(
              title: "Carbs",
              value: "${(carbsPercent * 100).toStringAsFixed(1)}%",
              color: const Color.fromRGBO(245, 243, 120, 1),
              progressValue: carbsPercent,
            ),
            _buildInfoBox(
              title: "Fat",
              value: "${(fatPercent * 100).toStringAsFixed(1)}%",
              color: const Color.fromRGBO(225, 182, 182, 1),
              progressValue: fatPercent,
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
    bool showvalue = false,
    double? progressValue,
    String trailingValue = "100%",
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showvalue) ...[
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ],
          if (showProgress && progressValue != null) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.4),
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 12)),
                Text(trailingValue, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Example usage with backend values:

