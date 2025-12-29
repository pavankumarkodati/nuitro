import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/home/Notifications/update_log.dart';
import 'package:nuitro/providers/home_provider.dart';
import 'package:nuitro/providers/scan_workflow_provider.dart';

import 'meal_summary.dart';
import 'nutrition_card.dart';

class ManualLogCard extends StatefulWidget {
  const ManualLogCard ({Key? key}) : super(key: key);

  @override
  State<ManualLogCard > createState() => _ManualLogCardState();
}

class _ManualLogCardState extends State<ManualLogCard > {
  final TextEditingController _foodNamecontroller = TextEditingController();
  bool _initialized = false;
  bool _isSaving = false;
  String? _selectedFoodSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final workflow = context.read<ScanWorkflowProvider>();
    _foodNamecontroller.text = workflow.manualQuery;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ScanWorkflowProvider>();
    final selection = workflow.manualSelection ??
        (workflow.manualResults.isNotEmpty ? workflow.manualResults.first : null);

    if (selection == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No food item selected.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Return to search and pick a food to view its nutrition details.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Search'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Map<String, dynamic>? foodlog = selection['foodlog'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(selection['foodlog'] as Map)
        : null;

    final rawMealInfo = selection['meal_info'] ?? foodlog?['meal_info'];
    final rawNutrition = selection['nutrition_data'] ?? foodlog?['nutrition_data'];
    final providerServingOptions = _extractServingOptions(selection, foodlog);
    final baseMealInfo = _buildMealInfo(
      rawMealInfo,
      selection['meal'] ?? foodlog?['meal'],
      rawNutrition,
    );
    final baseNutritionData = _buildNutritionData(rawNutrition);
    final effectiveServingOptions = _mergeServingOptions(providerServingOptions);

    final selectedServingLabel = _selectedFoodSize ??
        _pickInitialServing(
          selectionServing: selection['serving_size']?.toString(),
          embeddedServing: foodlog?['serving_size']?.toString(),
          defaultOptions: effectiveServingOptions,
        );
    _selectedFoodSize ??= selectedServingLabel;

    final mealInfo = _scaledMealInfoForServing(baseMealInfo, selectedServingLabel);
    final nutritionData = _scaledNutritionForServing(baseNutritionData, selectedServingLabel);
    final mealName = mealInfo['meal'] as String;
    final ingredients = _extractIngredients(selection, foodlog);
    final servingOptions = effectiveServingOptions;

    if (kDebugMode) {
      debugPrint('ManualLogCard selection -> ${jsonEncode(_truncateValue(selection))}');
      if (foodlog != null) {
        debugPrint('ManualLogCard foodlog -> ${jsonEncode(_truncateValue(foodlog))}');
      }
      debugPrint('ManualLogCard rawNutrition -> ${jsonEncode(_truncateValue(rawNutrition))}');
      debugPrint('ManualLogCard mealInfo -> ${jsonEncode(mealInfo)}');
      debugPrint('ManualLogCard nutritionData -> ${jsonEncode(nutritionData)}');
    }

    if (_foodNamecontroller.text.trim().isEmpty) {
      final selectionName = selection['name']?.toString() ?? foodlog?['food_name']?.toString();
      if (selectionName != null && selectionName.trim().isNotEmpty) {
        _foodNamecontroller.text = selectionName;
      }
    }

    final dropdownItems = servingOptions.isNotEmpty
        ? List<String>.from(servingOptions)
        : const ['Full Serving', 'Half Serving', 'Quarter Serving'];
    final selectedServing = dropdownItems.contains(_selectedFoodSize)
        ? _selectedFoodSize!
        : dropdownItems.first;

    final foodDisplayName = (() {
      final name = selection['name']?.toString().trim() ?? foodlog?['food_name']?.toString().trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }
      final query = workflow.manualQuery.trim();
      if (query.isNotEmpty) {
        return query;
      }
      return 'Manual Log';
    })();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
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
                    const SizedBox(width: 15),
                    const Text(
                      'Manual Log',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
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
                    Text(
                      foodDisplayName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Food Name',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(67, 67, 67, 1),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _foodNamecontroller,
                        onChanged: (value) {
                          context.read<ScanWorkflowProvider>().applyManualSelectionQuery(value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ingredients'),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ingredients.isEmpty
                          ? const Text(
                              'No ingredients provided',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ingredients
                                  .map(
                                    (ingredient) => Container(
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
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Serving Size',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(67, 67, 67, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 50,
                      width: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedServing,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: dropdownItems
                            .map(
                              (size) => DropdownMenuItem(
                                value: size,
                                child: Text(
                                  size,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(67, 67, 67, 1),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedFoodSize = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: MealSummaryCard(
                          mealName: mealInfo['meal'] as String,
                          calories: mealInfo['calories'] as int,
                          proteinPercent: mealInfo['protein'] as double,
                          carbsPercent: mealInfo['carbs'] as double,
                          fatPercent: mealInfo['fat'] as double,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: NutritionCard(
                  nutritionData: nutritionData,
                  onDelete: () {
                    // handle delete
                    debugPrint('Delete pressed');
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpdateLog()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(220, 250, 157, 1),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final provider = context.read<ScanWorkflowProvider>();

                            final trimmedName = _foodNamecontroller.text.trim();
                            final currentName = trimmedName.isNotEmpty
                                ? trimmedName
                                : (provider.manualSelection?['name']?.toString() ??
                                    provider.manualQuery.trim());

                            if (currentName.isEmpty) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Enter a food name before saving'),
                                ),
                              );
                              return;
                            }

                            provider.applyManualSelectionQuery(currentName);

                            final updatedSelection = Map<String, dynamic>.from(
                              provider.manualSelection ?? <String, dynamic>{},
                            )
                              ..['name'] = currentName
                              ..['serving_size'] = selectedServing
                              ..['selected_serving'] = selectedServing
                              ..['meal_info'] = Map<String, dynamic>.from(mealInfo)
                              ..['nutrition_data'] = Map<String, dynamic>.from(nutritionData)
                              ..['ingredients'] = ingredients;

                            final updatedFoodlog = updatedSelection['foodlog'] is Map<String, dynamic>
                                ? Map<String, dynamic>.from(updatedSelection['foodlog'])
                                : <String, dynamic>{};

                            updatedFoodlog
                              ..['food_name'] = currentName
                              ..['serving_size'] = selectedServing
                              ..['meal_info'] = Map<String, dynamic>.from(mealInfo)
                              ..['nutrition_data'] = Map<String, dynamic>.from(nutritionData)
                              ..['ingredients'] = ingredients;

                            updatedSelection['foodlog'] = updatedFoodlog;

                            provider.selectManualResult(updatedSelection);

                            setState(() {
                              _isSaving = true;
                            });
                            final response = await provider.saveManualEntry();
                            if (!mounted) {
                              return;
                            }
                            setState(() {
                              _isSaving = false;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                                backgroundColor: response.status
                                    ? const Color.fromRGBO(220, 250, 157, 1)
                                    : Colors.red,
                              ),
                            );
                            if (response.status) {
                              await context.read<HomeProvider>().loadHomeData();
                              if (!mounted) {
                                return;
                              }
                              Future.delayed(const Duration(milliseconds: 150), () {
                                if (!mounted) {
                                  return;
                                }
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              });
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Save Log',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
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

  Map<String, dynamic> _buildMealInfo(
    dynamic rawMeal,
    dynamic fallbackMeal,
    dynamic rawNutrition,
  ) {
    final mealSource = rawMeal is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawMeal)
        : <String, dynamic>{};
    final nutritionSource = rawNutrition is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawNutrition)
        : <String, dynamic>{};

    final mealName = (() {
      final explicitName = mealSource['meal']?.toString();
      if (explicitName != null && explicitName.trim().isNotEmpty) {
        return explicitName;
      }
      final fallback = fallbackMeal?.toString();
      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback;
      }
      return 'Manual Meal';
    })();

    final caloriesValue = _readValue(
          mealSource,
          const ['calories', 'energy', 'calories_kcal', 'energy_kcal'],
        ) ??
        _readValue(
          nutritionSource,
          const ['calories', 'energy', 'calories_kcal', 'energy_kcal', 'energy_kkal'],
        ) ??
        0;
    final calories = caloriesValue.round();

    double? proteinPercent = _readFraction(
      mealSource,
      const ['protein_percent', 'protein'],
    );
    double? carbsPercent = _readFraction(
      mealSource,
      const ['carbs_percent', 'carbs'],
    );
    double? fatPercent = _readFraction(
      mealSource,
      const ['fat_percent', 'fat'],
    );

    final proteinGrams = _readValue(
      nutritionSource,
      const ['protein', 'protein_g', 'protein_grams'],
    );
    final carbsGrams = _readValue(
      nutritionSource,
      const ['carbs', 'carbohydrates', 'carbs_g', 'carbohydrates_g'],
    );
    final fatGrams = _readValue(
      nutritionSource,
      const ['fat', 'fat_g', 'total_fat', 'total_fat_g'],
    );

    if ((proteinPercent == null || proteinPercent == 0) &&
        proteinGrams != null && calories > 0) {
      proteinPercent = ((proteinGrams * 4) / calories).clamp(0.0, 1.0);
    }
    if ((carbsPercent == null || carbsPercent == 0) &&
        carbsGrams != null && calories > 0) {
      carbsPercent = ((carbsGrams * 4) / calories).clamp(0.0, 1.0);
    }
    if ((fatPercent == null || fatPercent == 0) &&
        fatGrams != null && calories > 0) {
      fatPercent = ((fatGrams * 9) / calories).clamp(0.0, 1.0);
    }

    return {
      'meal': mealName,
      'calories': calories,
      'protein': proteinPercent ?? 0.0,
      'carbs': carbsPercent ?? 0.0,
      'fat': fatPercent ?? 0.0,
    };
  }

  List<String> _mergeServingOptions(List<String> providerOptions) {
    final defaults = ['Full Serving', 'Half Serving', 'Quarter Serving'];
    final merged = <String>{...defaults};
    merged.addAll(providerOptions);
    return merged.toList();
  }

  String _pickInitialServing({
    String? selectionServing,
    String? embeddedServing,
    required List<String> defaultOptions,
  }) {
    final candidates = [selectionServing, embeddedServing]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    for (final candidate in candidates) {
      if (defaultOptions.contains(candidate)) {
        return candidate;
      }
    }
    if (candidates.isNotEmpty) {
      return candidates.first;
    }
    return defaultOptions.isNotEmpty ? defaultOptions.first : 'Full Serving';
  }

  Map<String, dynamic> _scaledMealInfoForServing(
    Map<String, dynamic> base,
    String servingLabel,
  ) {
    final multiplier = _servingMultiplier(servingLabel);
    return {
      ...base,
      'calories': _scaleCalories(base['calories'], multiplier),
      'protein': _scaleMacro(base['protein'], multiplier),
      'carbs': _scaleMacro(base['carbs'], multiplier),
      'fat': _scaleMacro(base['fat'], multiplier),
    };
  }

  Map<String, dynamic> _scaledNutritionForServing(
    Map<String, dynamic> base,
    String servingLabel,
  ) {
    final multiplier = _servingMultiplier(servingLabel);
    final scaled = <String, dynamic>{};
    base.forEach((key, value) {
      scaled[key] = _scaleNutritionValue(value, multiplier);
    });
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
      final scaled = originalValue * multiplier;
      return originalValue is int
          ? scaled.round()
          : double.parse(scaled.toStringAsFixed(2));
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

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
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

  Map<String, dynamic> _buildNutritionData(dynamic raw) {
    final source = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    double resolve(String key, [List<String> fallbacks = const []]) {
      final values = [key, ...fallbacks];
      return _readValue(source, values) ?? 0;
    }

    return {
      'energy': resolve('energy', ['calories', 'energy_kcal', 'calories_kcal']).round(),
      'fat': resolve('fat', ['total_fat', 'fat_g', 'total_fat_g']),
      'saturatedFat': resolve('saturated_fat', ['saturatedFat', 'saturated_fat_g']),
      'polyFat': resolve('poly_fat', ['polyunsaturated_fat', 'polyFat']),
      'monoFat': resolve('mono_fat', ['monounsaturated_fat', 'monoFat']),
      'cholestrol': resolve('cholestrol', ['cholesterol', 'cholesterol_mg']),
      'fiber': resolve('fiber', ['dietary_fiber', 'fiber_g']),
      'sugar': resolve('sugar', ['sugars', 'sugar_g']),
      'sodium': resolve('sodium', ['sodium_mg']),
      'potassium': resolve('potassium', ['potassium_mg']),
      'protein': resolve('protein', ['protein_g']),
      'carbs': resolve('carbs', ['carbohydrates', 'carbs_g', 'carbohydrates_g']),
    };
  }

  double? _readValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (!source.containsKey(key)) {
        continue;
      }
      final value = _normalizeNumber(source[key]);
      if (value != null) {
        return value;
      }
      if (kDebugMode) {
        debugPrint('ManualLogCard value for $key could not be parsed: ${source[key]}');
      }
    }
    return null;
  }

  double? _readFraction(Map<String, dynamic> source, List<String> keys) {
    final value = _readValue(source, keys);
    if (value == null) {
      return null;
    }
    if (value <= 1) {
      return value.clamp(0.0, 1.0);
    }
    return (value / 100).clamp(0.0, 1.0);
  }

  double? _normalizeNumber(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final cleaned = value
          .replaceAll(RegExp(r'[^0-9.,-]'), '')
          .replaceAll(',', '.');
      return double.tryParse(cleaned);
    }
    return null;
  }

  dynamic _truncateValue(dynamic value, {int maxLength = 300}) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value.length > maxLength ? '${value.substring(0, maxLength)}…' : value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key, _truncateValue(val, maxLength: maxLength)));
    }
    if (value is Iterable) {
      return value.map((item) => _truncateValue(item, maxLength: maxLength)).toList();
    }
    return value;
  }

  List<String> _extractIngredients(
    Map<String, dynamic> source,
    Map<String, dynamic>? embedded,
  ) {
    final Set<String> entries = {};
    const potentialKeys = [
      'ingredients',
      'ingredient_list',
      'ingredientLines',
      'ingredient_line',
      'ingredient',
      'ingredientsList',
    ];

    for (final key in potentialKeys) {
      final value = source[key];
      if (value is List) {
        for (final item in value) {
          final parsed = item?.toString().trim();
          if (parsed != null && parsed.isNotEmpty) {
            entries.add(parsed);
          }
        }
      } else if (value is String) {
        entries.addAll(
          value
              .split(RegExp(r'[\n,]'))
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty),
        );
      }
    }

    if (embedded != null) {
      for (final key in potentialKeys) {
        final value = embedded[key];
        if (value is List) {
          for (final item in value) {
            final parsed = item?.toString().trim();
            if (parsed != null && parsed.isNotEmpty) {
              entries.add(parsed);
            }
          }
        } else if (value is String) {
          entries.addAll(
            value
                .split(RegExp(r'[,\n]'))
                .map((item) => item.trim())
                .where((item) => item.isNotEmpty),
          );
        }
      }

      final embeddedDescription = embedded['description']?.toString();
      if (embeddedDescription != null && embeddedDescription.trim().isNotEmpty) {
        entries.addAll(
          embeddedDescription
              .split(RegExp(r'[,\n]'))
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty),
        );
      }
    }

    if (entries.isEmpty) {
      final description = source['description']?.toString();
      if (description != null && description.trim().isNotEmpty) {
        entries.addAll(
          description
              .split(RegExp(r'[\n,]'))
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty),
        );
      }
    }

    return entries.toList();
  }

  List<String> _extractServingOptions(
    Map<String, dynamic> source,
    Map<String, dynamic>? embedded,
  ) {
    final Set<String> options = {};
    const potentialKeys = [
      'serving_options',
      'serving_sizes',
      'servingSizeOptions',
      'serving_size_options',
    ];

    for (final key in potentialKeys) {
      final value = source[key];
      if (value is List) {
        for (final item in value) {
          final parsed = item?.toString().trim();
          if (parsed != null && parsed.isNotEmpty) {
            options.add(parsed);
          }
        }
      } else if (value is Map) {
        for (final entry in value.values) {
          final parsed = entry?.toString().trim();
          if (parsed != null && parsed.isNotEmpty) {
            options.add(parsed);
          }
        }
      }
    }

    final defaultServing = source['serving_size']?.toString();
    if (defaultServing != null && defaultServing.trim().isNotEmpty) {
      options.add(defaultServing);
    }

    if (embedded != null) {
      for (final key in potentialKeys) {
        final value = embedded[key];
        if (value is List) {
          for (final item in value) {
            final parsed = item?.toString().trim();
            if (parsed != null && parsed.isNotEmpty) {
              options.add(parsed);
            }
          }
        } else if (value is Map) {
          for (final entry in value.values) {
            final parsed = entry?.toString().trim();
            if (parsed != null && parsed.isNotEmpty) {
              options.add(parsed);
            }
          }
        }
      }

      final embeddedServing = embedded['serving_size']?.toString();
      if (embeddedServing != null && embeddedServing.trim().isNotEmpty) {
        options.add(embeddedServing);
      }
    }

    return options.toList();
  }
}
