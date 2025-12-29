import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/progress_provider.dart';
import '../../home/Notifications/nutrition_card.dart';
class Nutrients extends StatefulWidget {
  const Nutrients({super.key});

  @override
  State<Nutrients> createState() => _NutrientsState();
}

class _NutrientsState extends State<Nutrients> {
  final red=Color.fromRGBO(255, 57, 93, 1);
  final orange=Color.fromRGBO(255, 140, 57, 1);
  final purple=Color.fromRGBO(132, 57, 255, 1);
  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Consumer<ProgressProvider>(
        builder: (context, provider, _) {
          final nutrients = provider.nutrients;
          final nutritionData = nutrients.toNutritionCardPayload();

        return Column(children: [
        Container(
          height: 204,
          decoration: BoxDecoration(
            color: Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // First row: single card full width
              _SummaryCard(
                kcal: nutrients.highlights.isNotEmpty ? nutrients.highlights.first.amount.toInt() : 0,
                label: nutrients.highlights.isNotEmpty ? nutrients.highlights.first.label : "Carbohydrate",
                percent: nutrients.highlights.isNotEmpty ? nutrients.highlights.first.percent.toInt() : 0,
                color: red,
              ),
              SizedBox(height: 12), // spacing between rows
              // Second row: two cards side by side
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      kcal: nutrients.highlights.length > 1 ? nutrients.highlights[1].amount.toInt() : 0,
                      label: nutrients.highlights.length > 1 ? nutrients.highlights[1].label : "Fat",
                      percent: nutrients.highlights.length > 1 ? nutrients.highlights[1].percent.toInt() : 0,
                      color: orange,
                    ),
                  ),
                  SizedBox(width: 12), // spacing between cards
                  Expanded(
                    child: _SummaryCard(
                      kcal: nutrients.highlights.length > 2 ? nutrients.highlights[2].amount.toInt() : 0,
                      label: nutrients.highlights.length > 2 ? nutrients.highlights[2].label : "Protein",
                      percent: nutrients.highlights.length > 2 ? nutrients.highlights[2].percent.toInt() : 0,
                      color: purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      NutritionCard(
        editDeleteEnable: false,
        nutritionData: nutritionData,
        onDelete: () {},
        onEdit: () {},
      ),

        ],
      );
        },
      ),
    );

  }
}

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
