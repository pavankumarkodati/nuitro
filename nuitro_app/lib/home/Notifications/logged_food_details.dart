import 'package:flutter/material.dart';
import 'package:nuitro/home/Notifications/update_log.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/api_config.dart';
import 'package:nuitro/services/services.dart';

import 'food_detail_header.dart';
import 'meal_summary.dart';
import 'nutrition_card.dart';

class LoggedFoodDetails extends StatelessWidget {
  final Map<String, dynamic> responseDataRaw;

  const LoggedFoodDetails({Key? key, required this.responseDataRaw}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final foodlogRaw = responseDataRaw["foodlog"];
    final responseData = foodlogRaw is Map<String, dynamic>
        ? Map<String, dynamic>.from(foodlogRaw)
        : <String, dynamic>{};

    final nutritionData = _buildNutritionData(responseData["nutrition_data"]);
    final mealInfo = _buildMealInfo(responseData["meal_info"], nutritionData);

    final foodName = responseData["food_name"];
    final servingSize = responseData["serving_size"];
    final imageUrl = ApiConfig.resolveMediaUrl(responseData["image_url"]?.toString());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              FoodDetailHeader(
                foodName: foodName ?? "Unknown Food",
                servingSize: "${servingSize ?? "0 g"}",
                imageUrl: imageUrl.isNotEmpty ? imageUrl : "assets/images/Food.png",
                onBack: () => Navigator.pop(context),
                onFavorite: () => print("Favorite clicked"),
              ),
              Column(
                children: [
                  const SizedBox(height: 247),
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
                        mealName: mealInfo["meal"],
                        calories: mealInfo["calories"],
                        proteinPercent: mealInfo["protein"] * 1.0,
                        carbsPercent: mealInfo["carbs"] * 1.0,
                        fatPercent: mealInfo["fat"] * 1.0,
                      ),
                    ),
                  ),
                  Center(
                    child: NutritionCard(
                      editDeleteEnable: true,
                      nutritionData: nutritionData,
                      onDelete: () {
                        debugPrint("Delete pressed");
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateLog(
                              initialData: Map<String, dynamic>.from(responseData),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _buildMealInfo(
    dynamic rawMealInfo,
    Map<String, dynamic> nutritionData,
  ) {
    final source = rawMealInfo is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawMealInfo)
        : <String, dynamic>{};

    String mealName = source["meal"]?.toString().trim() ?? "";
    if (mealName.isEmpty) {
      mealName = nutritionData["meal"]?.toString().trim() ?? "";
    }
    if (mealName.isEmpty) {
      mealName = "Unknown Meal";
    }

    return {
      "meal": mealName,
      "calories": _asInt(
        source["calories"] ?? nutritionData["calories"] ?? nutritionData["energy"] ?? 0,
      ),
      "protein": _asFraction(
        source["protein"] ?? nutritionData["proteinPercent"] ?? 0,
      ),
      "carbs": _asFraction(
        source["carbs"] ?? nutritionData["carbsPercent"] ?? 0,
      ),
      "fat": _asFraction(
        source["fat"] ?? nutritionData["fatPercent"] ?? 0,
      ),
    };
  }

  Map<String, dynamic> _buildNutritionData(dynamic rawNutrition) {
    final source = rawNutrition is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawNutrition)
        : <String, dynamic>{};

    double resolveDouble(String primaryKey, [String? secondaryKey]) {
      if (source.containsKey(primaryKey)) {
        return _asDouble(source[primaryKey]);
      }
      if (secondaryKey != null && source.containsKey(secondaryKey)) {
        return _asDouble(source[secondaryKey]);
      }
      return 0;
    }

    double resolveCholesterol() {
      final cholestrolValue = source.containsKey("cholestrol")
          ? source["cholestrol"]
          : source["cholesterol"];
      return _asDouble(cholestrolValue);
    }

    return {
      "meal": source["meal"]?.toString() ?? "",
      "calories": _asInt(source["calories"] ?? source["energy"] ?? 0),
      "energy": _asInt(source["energy"] ?? source["calories"] ?? 0),
      "proteinPercent": _asFraction(source["protein"] ?? 0),
      "carbsPercent": _asFraction(source["carbs"] ?? 0),
      "fatPercent": _asFraction(source["fat"] ?? 0),
      "fat": resolveDouble("fat"),
      "saturatedFat": resolveDouble("saturated_fat", "saturatedFat"),
      "polyFat": resolveDouble("poly_fat", "polyFat"),
      "monoFat": resolveDouble("mono_fat", "monoFat"),
      "cholestrol": resolveCholesterol(),
      "fiber": resolveDouble("fiber"),
      "sugar": resolveDouble("sugar"),
      "sodium": resolveDouble("sodium"),
      "potassium": resolveDouble("potassium"),
    };
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
