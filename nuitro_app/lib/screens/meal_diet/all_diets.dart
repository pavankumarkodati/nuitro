import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/diet_provider.dart';
import 'package:nuitro/screens/meal_diet/diet_details.dart';
class Meal {
  final String name;
  final String imagePath;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String goal;
  final String description;
  final int fiber; // grams
  final double waterLiters; // liters
  final String? intakeText; // e.g., "2000 kcal (1800–2200)"

  Meal({
    required this.name,
    required this.imagePath,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.goal,
    required this.description,
    required this.fiber,
    required this.waterLiters,
    this.intakeText,
  });
}
class AllDietsPage extends StatefulWidget {
  const AllDietsPage({super.key, this.useScaffold = true});

  final bool useScaffold;

  @override
  State<AllDietsPage> createState() => _AllDietsState();
}

class _AllDietsState extends State<AllDietsPage> {
  final List<Meal> allDiets = [
    Meal(
      name: "Balanced Diet",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 100,
      carbs: 250,
      fat: 67,
      goal: "Maintain overall health and steady energy.",
      description:
          "A balanced diet provides all essential nutrients in the right proportions. It includes whole grains, lean proteins, healthy fats, fruits, and vegetables. Ideal for maintaining weight, improving immunity, and ensuring long-term wellness.",
      fiber: 25,
      waterLiters: 2.5,
      intakeText: "Total Daily Intake: 2000 kcal (1800–2200)",
    ),
    Meal(
      name: "Low-Carb Diet",
      imagePath: "assets/images/Food.png",
      calories: 1600,
      protein: 130,
      carbs: 100,
      fat: 80,
      goal: "Weight loss and blood sugar stability.",
      description:
          "This plan limits carbs to reduce insulin spikes and promote fat metabolism. Meals focus on lean meats, eggs, green vegetables, and healthy oils. Perfect for those managing diabetes or aiming for gradual fat loss.",
      fiber: 20,
      waterLiters: 2.8,
      intakeText: "Total Daily Intake: 1600 kcal (1500–1800)",
    ),
    Meal(
      name: "Ketogenic (Keto) Diet",
      imagePath: "assets/images/Food.png",
      calories: 1700,
      protein: 100,
      carbs: 30,
      fat: 130,
      goal: "Rapid fat burning and metabolic efficiency.",
      description:
          "Keto drastically cuts carbs and raises fat intake, pushing your body into ketosis. In this state, fat becomes the primary fuel source, improving focus and stamina. Works best for quick weight loss or managing metabolic disorders.",
      fiber: 15,
      waterLiters: 3.0,
      intakeText: "Total Daily Intake: 1700 kcal (1500–1900)",
    ),
    Meal(
      name: "Mediterranean Diet",
      imagePath: "assets/images/Food.png",
      calories: 2100,
      protein: 100,
      carbs: 220,
      fat: 80,
      goal: "Heart health and longevity.",
      description:
          "Inspired by coastal eating habits, this plan centers around olive oil, fish, fruits, and nuts. It’s rich in antioxidants, omega-3s, and plant-based nutrients. Known for lowering heart disease risk and promoting graceful aging.",
      fiber: 30,
      waterLiters: 2.5,
      intakeText: "Total Daily Intake: 2100 kcal (1900–2300)",
    ),
    Meal(
      name: "Paleo Diet",
      imagePath: "assets/images/Food.png",
      calories: 1900,
      protein: 120,
      carbs: 150,
      fat: 80,
      goal: "Natural eating and inflammation control.",
      description:
          "The Paleo diet mimics ancestral eating — meat, fish, vegetables, and nuts. It excludes grains, dairy, and processed foods for better gut health. Ideal for those seeking cleaner nutrition and higher energy levels.",
      fiber: 25,
      waterLiters: 2.8,
      intakeText: "Total Daily Intake: 1900 kcal (1700–2100)",
    ),
    Meal(
      name: "Vegan Diet",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 90,
      carbs: 260,
      fat: 67,
      goal: "Ethical, eco-friendly nourishment.",
      description:
          "A 100% plant-based plan focusing on vegetables, grains, beans, and fruits. It supports heart health, reduces carbon footprint, and boosts digestion. Requires planning to ensure enough protein and vitamin B12 intake.",
      fiber: 35,
      waterLiters: 2.6,
      intakeText: "Total Daily Intake: 2000 kcal (1800–2200)",
    ),
    Meal(
      name: "Vegetarian Diet",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 95,
      carbs: 240,
      fat: 70,
      goal: "Balanced nutrition without meat.",
      description:
          "This plan includes dairy, eggs, grains, and legumes, avoiding meat and fish. It provides balanced protein sources while keeping cholesterol low. Ideal for those transitioning away from meat-based eating.",
      fiber: 30,
      waterLiters: 2.5,
      intakeText: "Total Daily Intake: 2000 kcal (1800–2200)",
    ),
    Meal(
      name: "High-Protein Diet",
      imagePath: "assets/images/Food.png",
      calories: 2200,
      protein: 160,
      carbs: 180,
      fat: 70,
      goal: "Muscle growth and recovery.",
      description:
          "Focuses on protein-rich foods like eggs, chicken, fish, and legumes. Supports muscle building, metabolism, and hunger control. Favored by athletes and fitness enthusiasts for body recomposition.",
      fiber: 25,
      waterLiters: 3.0,
      intakeText: "Total Daily Intake: 2200 kcal (2000–2400)",
    ),
    Meal(
      name: "Intermittent Fasting (IF)",
      imagePath: "assets/images/Food.png",
      calories: 1800,
      protein: 110,
      carbs: 180,
      fat: 70,
      goal: "Fat loss and metabolic reset.",
      description:
          "Involves fasting for fixed hours (e.g., 16:8) and eating during limited windows. Supports natural fat burning, insulin sensitivity, and cellular repair. Easy to adapt without restricting specific foods.",
      fiber: 25,
      waterLiters: 3.0,
      intakeText: "Total Daily Intake: 1800 kcal (1600–2000)",
    ),
    Meal(
      name: "DASH Diet",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 90,
      carbs: 250,
      fat: 65,
      goal: "Blood pressure and heart control.",
      description:
          "DASH emphasizes fruits, veggies, lean proteins, and low-sodium foods. It’s scientifically proven to lower hypertension and improve circulation. Best for maintaining long-term cardiovascular health.",
      fiber: 30,
      waterLiters: 2.5,
      intakeText: "Total Daily Intake: 2000 kcal (1800–2200)",
    ),
  ];
  Widget _buildContent({required bool scrollable}) {
    final outerPadding = scrollable
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
        : EdgeInsets.zero;

    final content = Padding(
      padding: outerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!scrollable) const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color.fromRGBO(221, 192, 255, 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore Diet Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  'Personalized plans to match your goals and lifestyle.',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Recommended Plans',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: allDiets.length,
            itemBuilder: (context, index) {
              final meal = allDiets[index];
              return GestureDetector(
                onTap: () {
                  final dietProvider = context.read<DietProvider>();
                  dietProvider.refreshMyDiets().whenComplete(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DietDetails(
                          name: meal.name
                              .replaceAll(RegExp(r'[0-9]'), '')
                              .replaceAll(RegExp(r'[^\x00-\x7F]+'), ''),
                          imagePath: meal.imagePath,
                          goal: meal.goal,
                          description: meal.description,
                          calories: meal.calories,
                          protein: meal.protein,
                          carbs: meal.carbs,
                          fat: meal.fat,
                          fiber: meal.fiber,
                          waterLiters: meal.waterLiters,
                          intakeText: meal.intakeText,
                        ),
                      ),
                    );
                  });
                },
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          meal.imagePath,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.name
                                  .replaceAll(RegExp(r'[0-9]'), '')
                                  .replaceAll(RegExp(r'[^\x00-\x7F]+'), ''),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 1,
                              children: [
                                Text(
                                  "${meal.calories} kcal | Protein:${meal.protein}g | Carbs:${meal.carbs}g | Fat:${meal.fat}g",
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
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
              );
            },
          ),
        ],
      ),
    );

    if (scrollable) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildContent(scrollable: widget.useScaffold);

    if (!widget.useScaffold) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Diets'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(child: body),
    );
  }
}
