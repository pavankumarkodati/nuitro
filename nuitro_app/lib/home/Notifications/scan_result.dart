import 'package:flutter/material.dart';
import 'package:nuitro/home/Notifications/update_log.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';

import 'food_detail_header.dart';
import 'meal_summary.dart';
import 'nutrition_card.dart';

class ScanResult extends StatefulWidget {
  final Map<String, dynamic> responseDataRaw;
  final String? capturedImagePath;

  const ScanResult({Key? key, required this.responseDataRaw, this.capturedImagePath}) : super(key: key);

  @override
  State<ScanResult> createState() => _ScanResultState();
}

class _ScanResultState extends State<ScanResult> {
  late Map<String, dynamic> _responsePayload;
  late Map<String, dynamic> _nutritionData;
  late Map<String, dynamic> _mealInfo;

  @override
  void initState() {
    super.initState();
    _initializePayload(widget.responseDataRaw);
  }

  void _initializePayload(Map<String, dynamic> rawResponse) {
    final payload = Map<String, dynamic>.from(
      rawResponse["data"] ?? <String, dynamic>{},
    );
    final inferredMeal = _inferMealType(DateTime.now());
    final mealInfo = _buildMealInfo(
      payload["meal_info"],
      inferredMeal,
    );
    final nutritionData = _buildNutritionData(
      payload["nutrition_data"],
      mealInfo["meal"] as String,
    );

    payload["meal_info"] = mealInfo;
    payload["nutrition_data"] = nutritionData;

    _responsePayload = payload;
    _mealInfo = mealInfo;
    _nutritionData = nutritionData;
  }

  Future<void> _handleEdit() async {
    final updatedData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateLog(
          initialData: Map<String, dynamic>.from(_responsePayload),
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _initializePayload({"data": updatedData});
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan result updated'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodName = _responsePayload["food_name"] as String? ?? "Unknown Food";
    final servingSize = _responsePayload["serving_size"]?.toString() ?? "0 g";
    final imageUrl = _responsePayload["image_url"]?.toString();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              FoodDetailHeader(
                foodName: foodName,
                servingSize: servingSize,
                imageUrl: imageUrl ?? "assets/images/Food.png",
                capturedImagePath: widget.capturedImagePath,
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
                        mealName: _mealInfo["meal"] as String,
                        calories: _mealInfo["calories"] as int,
                        proteinPercent: _mealInfo["protein"] as double,
                        carbsPercent: _mealInfo["carbs"] as double,
                        fatPercent: _mealInfo["fat"] as double,
                      ),
                    ),
                  ),
                  Center(
                    child: NutritionCard(
                      editDeleteEnable: true,
                      nutritionData: _nutritionData,
                      onDelete: () {
                        debugPrint("Delete pressed");
                      },
                      onEdit: _handleEdit,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
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
                            "data": _responsePayload,
                          };

                          final ApiResponse response =
                              await ApiServices.logFood(requestBody);

                          if (!mounted) {
                            return;
                          }

                          if (response.status) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                              ),
                            );
                            Navigator.of(context).pop(true);
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
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
            ],
        ),
      ),
    ),
    );
  }

  String _inferMealType(DateTime timestamp) {
    final hour = timestamp.hour;
    if (hour >= 5 && hour < 11) {
      return "Breakfast";
    }
    if (hour >= 11 && hour < 16) {
      return "Lunch";
    }
    if (hour >= 20 && hour < 23) {
      return "Dinner";
    }
    return "Snack";
  }

  Map<String, dynamic> _buildMealInfo(dynamic raw, String inferredMeal) {
    final source = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    final mealName = (source["meal"]?.toString().isNotEmpty ?? false)
        ? source["meal"].toString()
        : inferredMeal;

    return {
      "meal": mealName,
      "calories": _asInt(source["calories"]),
      "protein": _asFraction(source["protein"]),
      "carbs": _asFraction(source["carbs"]),
      "fat": _asFraction(source["fat"]),
    };
  }

  Map<String, dynamic> _buildNutritionData(dynamic raw, String mealForDisplay) {
    final source = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    double _resolveDouble(String primaryKey, [String? secondaryKey]) {
      final primaryValue = source[primaryKey];
      if (primaryValue != null) {
        return _asDouble(primaryValue);
      }
      if (secondaryKey != null && source.containsKey(secondaryKey)) {
        return _asDouble(source[secondaryKey]);
      }
      return 0;
    }

    double _resolveCholesterol() {
      final cholestrol = source.containsKey("cholestrol")
          ? source["cholestrol"]
          : source["cholesterol"];
      return _asDouble(cholestrol);
    }

    return {
      "meal": mealForDisplay,
      "energy": _asInt(source["energy"] ?? source["calories"]),
      "fat": _resolveDouble("fat"),
      "saturatedFat": _resolveDouble("saturated_fat", "saturatedFat"),
      "polyFat": _resolveDouble("poly_fat", "polyFat"),
      "monoFat": _resolveDouble("mono_fat", "monoFat"),
      "cholestrol": _resolveCholesterol(),
      "fiber": _resolveDouble("fiber"),
      "sugar": _resolveDouble("sugar"),
      "sodium": _resolveDouble("sodium"),
      "potassium": _resolveDouble("potassium"),
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
