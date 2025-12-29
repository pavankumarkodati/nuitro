import 'package:nuitro/services/api_config.dart';

class DietPlan {
  final String id;
  final String name;
  final String goal;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int? fiber;
  final double? waterLiters;
  final String intakeText;
  final String imageUrl;

  const DietPlan({
    required this.id,
    required this.name,
    required this.goal,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.waterLiters,
    this.intakeText = "",
    this.imageUrl = "",
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    String resolveString(dynamic value) => value?.toString().trim() ?? "";

    int? tryParseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    double? tryParseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    final rawImage = resolveString(json['image'] ?? json['image_path'] ?? json['imageUrl']);

    return DietPlan(
      id: resolveString(json['id'] ?? json['_id'] ?? json['uuid']),
      name: resolveString(json['name'] ?? json['title'] ?? 'Diet Plan'),
      goal: resolveString(json['goal'] ?? json['target'] ?? ''),
      description: resolveString(json['description'] ?? json['summary'] ?? ''),
      calories: tryParseInt(json['calories'] ?? json['kcal']) ?? 0,
      protein: tryParseInt(json['protein']) ?? 0,
      carbs: tryParseInt(json['carbs'] ?? json['carbohydrates']) ?? 0,
      fat: tryParseInt(json['fat'] ?? json['fats']) ?? 0,
      fiber: tryParseInt(json['fiber']),
      waterLiters: tryParseDouble(json['water_liters'] ?? json['water'] ?? json['waterLiters']),
      intakeText: resolveString(json['intake_text'] ?? json['intakeText'] ?? ''),
      imageUrl: ApiConfig.resolveMediaUrl(rawImage),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (waterLiters != null) 'water_liters': waterLiters,
      if (intakeText.isNotEmpty) 'intake_text': intakeText,
      if (imageUrl.isNotEmpty) 'image_path': imageUrl,
    };
  }

  bool get hasNutrients =>
      protein > 0 || carbs > 0 || fat > 0 || (fiber ?? 0) > 0;
}
