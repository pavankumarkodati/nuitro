import 'dart:collection';

import 'package:nuitro/services/api_config.dart';

double _parseToDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

class NutrientSummary {
  final String label;
  final double value;
  final double maxValue;
  final String unit;

  const NutrientSummary({
    required this.label,
    required this.value,
    required this.maxValue,
    this.unit = 'g',
  });

  factory NutrientSummary.fromJson(Map<String, dynamic> json) {
    return NutrientSummary(
      label: (json['label'] ?? '').toString(),
      value: _parseToDouble(json['value']),
      maxValue: _parseToDouble(json['max_value'] ?? json['max'] ?? json['goal']),
      unit: (json['unit'] ?? 'g').toString(),
    );
  }

  NutrientSummary copyWith({
    String? label,
    double? value,
    double? maxValue,
    String? unit,
  }) {
    return NutrientSummary(
      label: label ?? this.label,
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      unit: unit ?? this.unit,
    );
  }
}

class HydrationSummary {
  final double goal;
  final double intake;
  final String tip;

  const HydrationSummary({
    required this.goal,
    required this.intake,
    required this.tip,
  });

  factory HydrationSummary.fromJson(Map<String, dynamic> json) {
    return HydrationSummary(
      goal: _parseToDouble(json['goal_ml'] ?? json['goal']),
      intake: _parseToDouble(
        json['intake_ml'] ??
            json['intake'] ??
            json['total_ml'] ??
            json['total_water_ml'],
      ),
      tip: (json['tip'] ?? '').toString(),
    );
  }

  HydrationSummary copyWith({
    double? goal,
    double? intake,
    String? tip,
  }) {
    return HydrationSummary(
      goal: goal ?? this.goal,
      intake: intake ?? this.intake,
      tip: tip ?? this.tip,
    );
  }
}

class WellnessPrompt {
  final String question;
  final UnmodifiableListView<String> options;
  final String selected;

  WellnessPrompt({
    required this.question,
    required List<String> options,
    this.selected = '',
  }) : options = UnmodifiableListView(options);

  factory WellnessPrompt.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((option) => option.toString())
        .toList();
    final selected = (json['selected'] ?? json['mood'] ?? '').toString();
    return WellnessPrompt(
      question: (json['question'] ?? '').toString(),
      options: opts,
      selected: selected,
    );
  }

  WellnessPrompt copyWith({
    String? question,
    List<String>? options,
    String? selected,
  }) {
    return WellnessPrompt(
      question: question ?? this.question,
      options: options ?? this.options.toList(),
      selected: selected ?? this.selected,
    );
  }
}

class FoodPrediction {
  final String title;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;

  const FoodPrediction({
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imageUrl,
  });

  factory FoodPrediction.fromJson(Map<String, dynamic> json) {
    final source = json['food'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['food'] as Map)
        : json;
    return FoodPrediction(
      title: (source['food_name'] ?? source['title'] ?? 'Recommendation').toString(),
      description: (source['description'] ?? '').toString(),
      calories: _parseToDouble(source['calories']),
      protein: _parseToDouble(source['protein']),
      carbs: _parseToDouble(source['carbs']),
      fat: _parseToDouble(source['fat']),
      imageUrl: (source['image_url'] ?? source['image'] ?? '').toString(),
    );
  }
}

class Meal {
  final String name;
  final String time;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String imageUrl;

  const Meal({
    required this.name,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.imageUrl,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final foodlog = json['foodlog'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['foodlog'] as Map)
        : json;
    final nutrition = foodlog['nutrition_data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(foodlog['nutrition_data'] as Map)
        : <String, dynamic>{};
    final mealInfo = foodlog['meal_info'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(foodlog['meal_info'] as Map)
        : <String, dynamic>{};

    final resolvedImage = ApiConfig.resolveMediaUrl(foodlog['image_url']);

    return Meal(
      name: (foodlog['food_name'] ?? 'Unknown').toString(),
      time: (mealInfo['meal'] ?? '').toString(),
      calories: _parseToDouble(nutrition['calories'] ?? mealInfo['calories']),
      protein: _parseToDouble(nutrition['protein'] ?? mealInfo['protein']),
      carbs: _parseToDouble(nutrition['carbs'] ?? mealInfo['carbs']),
      fat: _parseToDouble(nutrition['fat'] ?? mealInfo['fat']),
      fiber: _parseToDouble(nutrition['fiber']),
      imageUrl: resolvedImage.isEmpty
          ? 'https://via.placeholder.com/150'
          : resolvedImage,
    );
  }
}

class HomeDashboardData {
  final int consumedCalories;
  final int totalCalories;
  final UnmodifiableListView<NutrientSummary> nutrients;
  final HydrationSummary hydration;
  final WellnessPrompt wellnessPrompt;

  HomeDashboardData({
    required this.consumedCalories,
    required this.totalCalories,
    required List<NutrientSummary> nutrients,
    required this.hydration,
    required this.wellnessPrompt,
  }) : nutrients = UnmodifiableListView(nutrients);

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final nutrientsJson = (json['nutrients'] as List<dynamic>? ?? [])
        .map((nutrient) => NutrientSummary.fromJson(
              Map<String, dynamic>.from(nutrient as Map),
            ))
        .toList();

    return HomeDashboardData(
      consumedCalories: (json['calories_consumed'] ?? 0) is num
          ? (json['calories_consumed'] as num).round()
          : int.tryParse(json['calories_consumed'].toString()) ?? 0,
      totalCalories: (json['total_calories'] ?? 1) is num
          ? (json['total_calories'] as num).round()
          : int.tryParse(json['total_calories'].toString()) ?? 1,
      nutrients: nutrientsJson,
      hydration: HydrationSummary.fromJson(
        json['hydration'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      wellnessPrompt: WellnessPrompt.fromJson(
        json['wellness_prompt'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  factory HomeDashboardData.empty() {
    return HomeDashboardData(
      consumedCalories: 0,
      totalCalories: 1,
      nutrients: const <NutrientSummary>[],
      hydration: const HydrationSummary(goal: 0, intake: 0, tip: ''),
      wellnessPrompt: WellnessPrompt(question: '', options: const <String>[], selected: ''),
    );
  }

  HomeDashboardData copyWith({
    int? consumedCalories,
    int? totalCalories,
    List<NutrientSummary>? nutrients,
    HydrationSummary? hydration,
    WellnessPrompt? wellnessPrompt,
  }) {
    return HomeDashboardData(
      consumedCalories: consumedCalories ?? this.consumedCalories,
      totalCalories: totalCalories ?? this.totalCalories,
      nutrients: nutrients ?? this.nutrients.toList(),
      hydration: hydration ?? this.hydration,
      wellnessPrompt: wellnessPrompt ?? this.wellnessPrompt,
    );
  }
}
