import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'barcode_scan_result.dart';
import 'meal_summary.dart';
import 'nutrition_card.dart';

class UpdateLog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const UpdateLog({Key? key, this.initialData}) : super(key: key);

  @override
  State<UpdateLog> createState() => _UpdateLogState();
}

class _UpdateLogState extends State<UpdateLog> {
  late final TextEditingController _foodNameController;
  late List<String> _ingredients;
  late List<String> _foodSizeOptions;
  late String _selectedFoodSize;
  late Map<String, dynamic> _nutritionData;
  late Map<String, dynamic> _mealInfo;
  late Map<String, dynamic> _baseNutritionData;
  late Map<String, dynamic> _baseMealInfo;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData != null
        ? Map<String, dynamic>.from(widget.initialData!)
        : <String, dynamic>{};

    _nutritionData = _buildNutritionData(initial['nutrition_data']);
    _mealInfo = _buildMealInfo(initial['meal_info'], initial);
    _ingredients = _parseIngredients(initial['ingredients']);

    _baseNutritionData = Map<String, dynamic>.from(_nutritionData);
    _baseMealInfo = Map<String, dynamic>.from(_mealInfo);

    _foodSizeOptions = [
      "Full Serving",
      "Half Serving",
      "Quarter Serving",
    ];

    final servingSize = _extractServingSize(initial);
    if (servingSize.isNotEmpty && !_foodSizeOptions.contains(servingSize)) {
      _foodSizeOptions.insert(0, servingSize);
    }

    _selectedFoodSize =
        servingSize.isNotEmpty ? servingSize : _foodSizeOptions.first;

    _foodNameController = TextEditingController(
      text: initial['food_name']?.toString() ?? '',
    );

    _recalculateServing(_selectedFoodSize);

  }

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealName = _extractMealName();
    final calories = _asInt(_mealInfo['calories']);
    final proteinPercent = _asDouble(_mealInfo['protein']);
    final carbsPercent = _asDouble(_mealInfo['carbs']);
    final fatPercent = _asDouble(_mealInfo['fat']);

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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(35, 34, 32, 1),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                        ),
                      ),
                    ),

                     Text(
                      mealName,
                      style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
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
                    Text(
                      mealName,
                      style:GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),

                    // Food Name
                    Text("Enter Food Name",style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w400,color: Color.fromRGBO(67, 67, 67, 1))),

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
                    Text("Enter Ingredients"),
                    SizedBox(height: 6),
                    Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _ingredients.isEmpty
                          ? const Text('No ingredients available')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _ingredients
                                  .map((ingredient) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(220, 250, 157, 1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          ingredient,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                    ),
                    SizedBox(height: 16),

                    // Food Size Dropdown
                    Text("Select Food Size",style: GoogleFonts.manrope(fontSize:17 ,fontWeight:FontWeight.w400 ,color:Color.fromRGBO(67, 67, 67, 1) ),),
                    SizedBox(height: 6),
                    Container(height: 50,width: 180,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFoodSize,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: _foodSizeOptions
                            .map((size) => DropdownMenuItem(
                              value: size,
                              child: Text(
                                size,
                                style: GoogleFonts.manrope(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromRGBO(67, 67, 67, 1),
                                ),
                              ),
                            ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _recalculateServing(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: MealSummaryCard(
                          mealName: mealName,
                          calories: calories,
                          proteinPercent: proteinPercent,
                          carbsPercent: carbsPercent,
                          fatPercent: fatPercent,
                        ),
                      ),
                    ),
                  ],

                ),


              ),
              Center(
                child: NutritionCard(
                  editDeleteEnable: false,
                  nutritionData: _nutritionData,
                  onDelete: () {},
                  onEdit: () {},
                ),
              ),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromRGBO(220, 250, 157, 1),
                  ),
                  child: TextButton(
                    onPressed: _handleSave,
                    child: Text(
                      'Save',
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

  void _handleSave() {
    final updatedPayload = Map<String, dynamic>.from(widget.initialData ?? {});
    updatedPayload["food_name"] = _foodNameController.text.trim();
    updatedPayload["ingredients"] = _ingredients;
    updatedPayload["serving_size"] = _selectedFoodSize;
    updatedPayload["nutrition_data"] = _nutritionData;
    updatedPayload["meal_info"] = _mealInfo;

    Navigator.pop(context, updatedPayload);
  }

  void _recalculateServing(String servingLabel) {
    _selectedFoodSize = servingLabel;
    _nutritionData = _scaledNutritionForServing(servingLabel);
    _mealInfo = _scaledMealInfoForServing(servingLabel);
  }

  Map<String, dynamic> _scaledNutritionForServing(String servingLabel) {
    final multiplier = _servingMultiplier(servingLabel);
    final scaled = <String, dynamic>{};

    _baseNutritionData.forEach((key, value) {
      scaled[key] = _scaleNutritionValue(value, multiplier);
    });

    return scaled;
  }

  Map<String, dynamic> _scaledMealInfoForServing(String servingLabel) {
    final multiplier = _servingMultiplier(servingLabel);
    final scaled = Map<String, dynamic>.from(_baseMealInfo);

    scaled['calories'] = _scaleCalories(_baseMealInfo['calories'], multiplier);
    scaled['protein'] = _scaleMacro(_baseMealInfo['protein'], multiplier);
    scaled['carbs'] = _scaleMacro(_baseMealInfo['carbs'], multiplier);
    scaled['fat'] = _scaleMacro(_baseMealInfo['fat'], multiplier);

    return scaled;
  }

  double _servingMultiplier(String label) {
    final normalized = label.toLowerCase().trim();

    if (normalized.contains('quarter')) {
      return 0.25;
    }
    if (normalized.contains('half')) {
      return 0.5;
    }
    if (normalized.contains('full')) {
      return 1.0;
    }

    final numericMatch = RegExp(r'([0-9]*\.?[0-9]+)').firstMatch(normalized);
    if (numericMatch != null) {
      final parsed = double.tryParse(numericMatch.group(0)!);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }

    return 1.0;
  }

  dynamic _scaleNutritionValue(dynamic originalValue, double multiplier) {
    if (originalValue is num) {
      return originalValue is int
          ? (originalValue * multiplier).round()
          : double.parse((originalValue * multiplier).toStringAsFixed(2));
    }

    final parsed = double.tryParse(originalValue?.toString() ?? '');
    if (parsed == null) {
      return originalValue;
    }

    final scaled = parsed * multiplier;
    return double.parse(scaled.toStringAsFixed(2));
  }

  int _scaleCalories(dynamic originalValue, double multiplier) {
    final base = _asDouble(originalValue);
    return (base * multiplier).round();
  }

  double _scaleMacro(dynamic originalValue, double multiplier) {
    final base = _asDouble(originalValue);
    return double.parse((base * multiplier).toStringAsFixed(2));
  }

  List<String> _parseIngredients(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (raw is String) {
      return raw
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  Map<String, dynamic> _buildNutritionData(dynamic raw) {
    final fallback = <String, dynamic>{
      "energy": 0,
      "fat": 0,
      "saturatedFat": 0,
      "polyFat": 0,
      "monoFat": 0,
      "cholestrol": 0,
      "fiber": 0,
      "sugar": 0,
      "sodium": 0,
      "potassium": 0,
    };

    final sanitized = Map<String, dynamic>.from(fallback);

    if (raw is Map) {
      raw.forEach((key, value) {
        sanitized[key.toString()] = value ?? fallback[key] ?? 0;
      });
    }

    return sanitized;
  }

  Map<String, dynamic> _buildMealInfo(dynamic raw, Map<String, dynamic> base) {
    final fallback = <String, dynamic>{
      "meal": "Calculated Macro-nutrient:",
      "calories": 0,
      "protein": 0.0,
      "carbs": 0.0,
      "fat": 0.0,
    };

    if (raw is Map<String, dynamic>) {
      return {
        "meal": raw['meal']?.toString() ?? fallback['meal'],
        "calories": _asInt(raw['calories']),
        "protein": _asDouble(raw['protein']),
        "carbs": _asDouble(raw['carbs']),
        "fat": _asDouble(raw['fat']),
      };
    }

    final nutrition = base['nutrition_data'];
    if (nutrition is Map<String, dynamic>) {
      return {
        "meal": base['meal']?.toString() ?? fallback['meal'],
        "calories": _asInt(nutrition['calories']),
        "protein": _asDouble(nutrition['protein']),
        "carbs": _asDouble(nutrition['carbs']),
        "fat": _asDouble(nutrition['fat']),
      };
    }

    return fallback;
  }

  String _extractServingSize(Map<String, dynamic> base) {
    final serving = base['serving_size'];
    if (serving == null) {
      return '';
    }
    final servingString = serving.toString().trim();
    return servingString;
  }

  String _extractMealName() {
    final meal = _mealInfo['meal'];
    if (meal is String && meal.trim().isNotEmpty) {
      return meal;
    }
    return 'Meal';
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed.round();
      }
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
