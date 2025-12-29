import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';
import 'barcode_detail_header.dart';
import 'health_indicator.dart';
import 'meal_summary.dart';
import 'nutrition_card.dart';

class BarcodeScanResult extends StatelessWidget {
  final Map<String, dynamic> responseDataRaw;

  const BarcodeScanResult({Key? key, required this.responseDataRaw})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final responseData = Map<String, dynamic>.from(
      responseDataRaw["data"] ?? <String, dynamic>{},
    );
    // Extract API values safely
    final foodName = responseData["food_name"]?.toString() ?? "Unknown Food";
    final servingSize = responseData["serving_size"]?.toString() ?? "N/A";

    final rawNutrition = responseData["nutrition_data"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(responseData["nutrition_data"] as Map<String, dynamic>)
        : <String, dynamic>{};

    final rawIndicators = responseData["health_indicators"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(responseData["health_indicators"] as Map<String, dynamic>)
        : <String, dynamic>{};
    debugPrint('barcode_scan_result payload:');
    debugPrint('food_name=${responseData["food_name"]}');
    debugPrint('serving_size=${responseData["serving_size"]}');
    debugPrint('nutrition_keys=${rawNutrition.keys.toList()}');
    debugPrint('indicator_keys=${rawIndicators.keys.toList()}');
    print(responseData["health_indicators"]);
    print(responseData);
    print("==================================");


    // Normalize to camelCase for NutritionCard
    final nutritionData = {
      "energy": _asInt(rawNutrition["energy"] ?? rawNutrition["calories"]),
      "fat": _asDouble(rawNutrition["fat"]),
      "saturatedFat": _asDouble(rawNutrition["saturated_fat"]),
      "polyFat": _asDouble(rawNutrition["poly_fat"]),
      "monoFat": _asDouble(rawNutrition["mono_fat"]),
      "cholestrol": _asDouble(rawNutrition["cholestrol"]),
      "fiber": _asDouble(rawNutrition["fiber"]),
      "sugar": _asDouble(rawNutrition["sugar"]),
      "sodium": _asDouble(rawNutrition["sodium"]),
      "potassium": _asDouble(rawNutrition["potassium"]),
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Food header
              BarcodeDetailHeader(
                foodName: foodName,
                servingSize: servingSize,
                onBack: () => Navigator.pop(context),
                onFavorite: () => debugPrint("Favorite clicked"),
              ),

              /// Health indicator (only show if exists)

                HealthIndicator(
                  ingredientName: rawIndicators["ingredient_name"] ?? "Unknown",
                  healthPercentage:((rawIndicators["health_percentage"] ?? 0) as num).toDouble(),
                ),

              /// Meal summary card
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MealSummaryCard(
                    mealName: "Barcode Scan",
                    calories: _asInt(rawNutrition["calories"] ?? rawNutrition["energy"]),
                    proteinPercent: _asFraction(rawNutrition["protein"]),
                    carbsPercent: _asFraction(rawNutrition["carbs"]),
                    fatPercent: _asFraction(rawNutrition["fat"]),
                  ),
                ),
              ),

              /// Nutrition card
              Center(
                child: NutritionCard(
                  nutritionData: nutritionData,
                  onDelete: () => debugPrint("Delete pressed"),
                  onEdit: () => debugPrint("Edit pressed"),
                ),
              ),

              const SizedBox(height: 10),

              /// Suggestion box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromRGBO(226, 242, 255, 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Image.asset('assets/images/Vector.png', scale: 0.8),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              'Optional healthier alternative:',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Try a granola bar with no added sugar',
                              softWrap: true,
                              style: GoogleFonts.manrope(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// Save log button
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromRGBO(220, 250, 157, 1),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final Map<String, dynamic> requestBody = {
                        "data": responseData,
                      };

                      final ApiResponse response =
                          await ApiServices.logFood(requestBody);

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(response.message),
                          backgroundColor: response.status ? null : Colors.red,
                        ),
                      );

                      if (response.status) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text(
                      'Save Log',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed.round();
      }
    }
    return 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _asFraction(dynamic value) {
    if (value is num) {
      final doubleValue = value.toDouble();
      if (doubleValue <= 1.0) {
        return doubleValue.clamp(0.0, 1.0);
      }
      return (doubleValue / 100).clamp(0.0, 1.0);
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        if (parsed <= 1.0) {
          return parsed.clamp(0.0, 1.0);
        }
        return (parsed / 100).clamp(0.0, 1.0);
      }
    }
    return 0;
  }
}
