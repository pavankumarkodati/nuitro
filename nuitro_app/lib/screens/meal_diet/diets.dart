import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/screens/meal_diet/all_diets.dart';
import 'package:nuitro/screens/meal_diet/my_diets.dart';
import 'package:nuitro/screens/meal_diet/pop_up_menu.dart';
import 'package:nuitro/services/api_helper.dart';
// 👈 import the new menu widget

class Meal {
  final String name;
  final String imagePath;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  Meal({
    required this.name,
    required this.imagePath,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}


class Diets extends StatefulWidget {
  const Diets({super.key});



  @override
  State<Diets> createState() => _DietsState();
}

class _DietsState extends State<Diets> {
  bool AllDiets = true;
  final green = const Color.fromRGBO(220, 250, 157, 1);

  final List<Meal> allDiets = [
    Meal(
      name: "Mediterranean Lifestyle",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 180,
      carbs: 150,
      fat: 80,
    ),
    Meal(
      name: "Keto Kickstart",
      imagePath: "assets/images/Food.png",
      calories: 1800,
      protein: 100,
      carbs: 225,
      fat: 45,
    ),
  ];

  final List<Meal> myDiets = [
    Meal(
      name: "Mediterranean Lifestyle",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 180,
      carbs: 150,
      fat: 80,
    ),
    Meal(
      name: "Keto Kickstart",
      imagePath: "assets/images/Food.png",
      calories: 1800,
      protein: 100,
      carbs: 225,
      fat: 45,
    ),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<UserProvider>().ensureInitialized();
      await ApiHelper.ensureFreshAccessToken();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Diets',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        DietPopupMenu(), // 👈 reusable menu
                      ],
                    ),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => AllDiets = true),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AllDiets ? green : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "All Diets",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => AllDiets = false),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: !AllDiets ? green : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "My Diets",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                          AllDiets
                              ? const AllDietsPage(useScaffold: false)
                              : const MyDietsPage(useScaffold: false),
                        ],
                    ),
                ),
            ),
        ),
    );
  }
}