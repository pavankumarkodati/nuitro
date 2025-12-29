import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nuitro/home/Notifications/barcode_scan_result.dart';
import 'package:nuitro/home/Notifications/meal_summary.dart';
import 'package:nuitro/home/Notifications/nutrition_card.dart';
import 'package:nuitro/home/Notifications/update_log.dart';

class NutrientCalculator extends StatefulWidget {
  const NutrientCalculator ({Key? key}) : super(key: key);

  @override
  State<NutrientCalculator> createState() => _NutrientCalculatorState();
}

class _NutrientCalculatorState extends State<NutrientCalculator > {
  final TextEditingController _foodNameController = TextEditingController();
  final List<String> ingredients = ["Lettuce", "Olive Oil"];
  final TextEditingController _preparationController = TextEditingController();

  String selectedFoodSize = "100 gm";



  @override
  Widget build(BuildContext context) {
    final nutritionData = {
      "energy": 1271,
      "fat": 9,
      "saturatedFat": 5,
      "polyFat": 4,
      "monoFat": 7,
      "cholestrol": 114,
      "fiber": 0,
      "sugar": 0,
      "sodium": 503,
      "potassium": 272,
    };
    final data = {
      "meal": "Calculated Macro-nutrient:",
      "calories": 2230,
      "protein": 0.85, // 85%
      "carbs": 0.50,   // 50%
      "fat": 0.63,     // 63%
    };
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
        SingleChildScrollView(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [


                    const Text(
                      "Recipe Builder",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(35, 34, 32, 1),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),






              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title

                    SizedBox(height: 10),

                    // Food Name
                    Text("Recipe Name",style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,color: Color.fromRGBO(67, 67, 67, 1))),

                    SizedBox(height: 50,
                      child: TextField(
                        controller: _foodNameController,

                        decoration: InputDecoration(


                          border: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.black,width: 1)
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Ingredients
                    Row( crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text("Enter Ingredients",style: TextStyle(fontSize:15 ,
                          fontWeight:FontWeight.w400 ,color:Color.fromRGBO(67, 67, 67, 1) ),),
                        SizedBox(height: 6),
                        Container(height: 50,width:double.infinity,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ingredients
                                .map((ingredient) => Container(width: 64,height: 19,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color:Color.fromRGBO(220, 250, 157, 1),borderRadius: BorderRadius.circular(14) ),
                      
                              child: Text(ingredient,style: TextStyle(fontSize:12 ,fontWeight:FontWeight.w400 )),
                            ))
                                .toList(),
                          ),
                        ),],),
                    ),SizedBox(width: 15,)
                   ,Expanded(flex: 1,
                     child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
                        Text("Quantity",
                          style: TextStyle(fontSize:15 ,
                              fontWeight:FontWeight.w400 ,color:Color.fromRGBO(67, 67, 67, 1) ),),
                        SizedBox(height: 6),
                        Container(height: 50,width: 180,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: selectedFoodSize,
                            isExpanded: true,
                            underline: SizedBox(),
                            items: [
                              "100 gm",
                              "Half Serving",
                              "Quarter Serving",
                            ]
                                .map((size) => DropdownMenuItem(
                              value: size,
                              child: Text(size,style: TextStyle(fontSize:14 ,fontWeight:FontWeight.w400 ,color:Color.fromRGBO(67, 67, 67, 1) ),),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFoodSize = value!;
                              });
                            },
                          ),
                        ),
                      ],),
                   ),],),

                    SizedBox(height: 16),
                    Text("Preparation",style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,color: Color.fromRGBO(67, 67, 67, 1))),

                    SizedBox(height: 50,width:180 ,
                      child: TextField(
                        controller: _preparationController,

                        decoration: InputDecoration(


                          border: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.black,width: 1)
                          ),
                        ),
                      ),
                    ),


                    IngredientCard(
                      name: "Homade Chicken Stir-Fry",
                      detail: "Chicken: Grilled",
                      quantity: "100g",
                      imagePath: "assets/images/Food.png", // replace with your asset
                      onDelete: () {
                        print("Deleted ingredient");
                      },
                      onAdd: () {
                        print("Add another ingredient");
                      },
                    ),


                    SizedBox(height: 10,),
                    Container( decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),   // round top-left
                        topRight: Radius.circular(20),  // round top-right
                      ),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(.0),
                        child: MealSummaryCard(
                          mealName: data["meal"] as String,
                          calories: data["calories"] as int,
                          proteinPercent: data["protein"] as double,
                          carbsPercent: data["carbs"] as double,
                          fatPercent: data["fat"] as double,

                        ),
                      ),
                    ),
                  ],

                ),


              ), Center(
                child: NutritionCard(
                  nutritionData: nutritionData,
                  onDelete: () {
                    // handle delete
                    debugPrint("Delete pressed");
                  },
                  onEdit: () {
                    // Navigate to Edit Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpdateLog()),
                    );
                  },
                ),
              ),
              SizedBox(height: 13,),
              Padding(padding: EdgeInsets.symmetric(vertical:20,horizontal: 15),
                child: Container(height:50 ,width: double.infinity,decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Color.fromRGBO(145, 199, 136, 1)),
                  child: TextButton(onPressed : () {


                  }, child:Text('Save Log',style: TextStyle(fontWeight: FontWeight.w600,fontSize:18,color: Colors.white ),) ),
                ),
              ),

            ],

          ),
        ),
      ),
    );
  }
}












class IngredientCard extends StatelessWidget {
  final String name;
  final String detail;
  final String quantity;
  final String imagePath;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  const IngredientCard({
    super.key,
    required this.name,
    required this.detail,
    required this.quantity,
    required this.imagePath,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredient Item Card
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F9), // light grey background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Ingredient image
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  imagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Name and detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:  GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          quantity,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete Icon
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        // Add Another Ingredient button
        GestureDetector(
          onTap: onAdd,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "+ Add Another Ingredient",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

