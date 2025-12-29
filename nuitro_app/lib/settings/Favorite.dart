import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../More/custom_back_button2.dart';

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

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  // Example list (you can later fetch this from backend)
  final List<Meal> favoriteMeals = [
    Meal(
      name: "Paleo Power Plan",
      imagePath: "assets/images/Food.png",
      calories: 2000,
      protein: 180,
      carbs: 150,
      fat: 80,
    ),
    Meal(
      name: "Indian Vegetarian Weight Loss",
      imagePath: "assets/images/Food.png",
      calories: 1800,
      protein: 100,
      carbs: 225,
      fat: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomBackButton2(label: "Favourite"),

              const SizedBox(height: 20),

              favoriteMeals.isEmpty
                  ? Column(
                children: [
                  const SizedBox(height: 100),
                  Container(
                    width: 264,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const Image(
                          image: AssetImage('assets/images/Sign In.png'),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'No Favorites Yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                         Text(
                          'Quick access to your most loved items makes logging even faster!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: favoriteMeals.length,
                itemBuilder: (context, index) {
                  final meal = favoriteMeals[index];
                  return Card(
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
                          child: Stack(
                            children: [
                              Image.asset(
                                meal.imagePath,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8), // subtle background
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset('assets/images/heart fill.png',width: 40,
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 0),



                                  Text(
                                    "${meal.calories} kcal | Protein:${meal.protein}g | Carbs:${meal.carbs}g | Fat:${meal.fat}g",
                                    softWrap:true,style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                  ),


                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
