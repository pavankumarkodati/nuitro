import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nuitro/models/home_models.dart';
import 'package:nuitro/services/api_helper.dart';
import 'package:nuitro/services/services.dart';

class HomeProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  HomeDashboardData _dashboard = HomeDashboardData.empty();
  final List<Meal> _meals = [];
  final List<Map<String, dynamic>> _mealRawData = [];
  final List<FoodPrediction> _predictions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  HomeDashboardData get dashboard => _dashboard;
  UnmodifiableListView<Meal> get meals => UnmodifiableListView(_meals);
  UnmodifiableListView<Map<String, dynamic>> get mealRawData =>
      UnmodifiableListView(_mealRawData);
  UnmodifiableListView<FoodPrediction> get predictions =>
      UnmodifiableListView(_predictions);

  Future<void> loadHomeData({DateTime? date}) async {
    _setLoading(true);
    _errorMessage = null;

    final targetDate = date ?? DateTime.now();

    try {
      await ApiHelper.ensureFreshAccessToken();
      await _loadMeals(targetDate);
      await Future.wait([
        _loadPredictions(targetDate),
        _loadHydration(targetDate),
      ]);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadHomeData();

  Future<void> _loadMeals(DateTime targetDate) async {
    final response = await ApiServices.getFoodLog(date: targetDate);
    if (!response.status) {
      throw Exception(response.message);
    }

    final data = response.data as Map<String, dynamic>? ?? {};
    final rawLogs = (data['foodlogs'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final effectiveLogs = rawLogs
        .where((entry) => entry['foodlog'] is Map<String, dynamic>)
        .toList();
    debugPrint('[HomeProvider][_loadMeals] rawLogs=${rawLogs.length} foodLogs=${effectiveLogs.length}');

    _meals
      ..clear()
      ..addAll(effectiveLogs.map(Meal.fromJson));

    _mealRawData
      ..clear()
      ..addAll(effectiveLogs);

    final derivedCalories = _computeTotalCalories(effectiveLogs);
    final consumed = _parseToInt(
      data['Calories consumed'] ?? data['calories_consumed'],
      fallback: derivedCalories,
      defaultValue: derivedCalories,
    );
    final baselineGoal = _dashboard.totalCalories > 0
        ? _dashboard.totalCalories
        : (derivedCalories > 0 ? derivedCalories : 1);
    final total = _parseToInt(
      data['Total calories'] ?? data['total_calories'],
      fallback: baselineGoal,
    );

    final nutrientSummaries = _extractNutrients(data) ?? _aggregateNutrients();
    final wellnessPrompt = _extractWellnessPrompt(data);

    _dashboard = _dashboard.copyWith(
      consumedCalories: consumed,
      totalCalories: total,
      nutrients: nutrientSummaries,
      wellnessPrompt: wellnessPrompt,
    );
    notifyListeners();
  }

  Future<void> _loadPredictions(DateTime targetDate) async {
    final response = await ApiServices.getFoodPredictions(date: targetDate);
    if (!response.status) {
      return;
    }

    final data = response.data as Map<String, dynamic>? ?? {};
    final items = (data['predictions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(FoodPrediction.fromJson)
        .toList();

    _predictions
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  Future<void> setWellnessMood(String mood, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final previousPrompt = _dashboard.wellnessPrompt;
    final optimisticPrompt = previousPrompt.copyWith(selected: mood);

    _dashboard = _dashboard.copyWith(wellnessPrompt: optimisticPrompt);
    notifyListeners();

    try {
      await ApiHelper.ensureFreshAccessToken();
      final response = await ApiServices.updateWellness(
        date: targetDate,
        mood: mood,
        question: optimisticPrompt.question,
        options: optimisticPrompt.options.toList(),
      );

      if (!response.status) {
        throw Exception(response.message);
      }

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final prompt = responseData['wellness_prompt'];
        if (prompt is Map<String, dynamic>) {
          _dashboard = _dashboard.copyWith(
            wellnessPrompt: WellnessPrompt.fromJson(prompt),
          );
          notifyListeners();
          return;
        }
      }

      _dashboard = _dashboard.copyWith(wellnessPrompt: optimisticPrompt);
      notifyListeners();
    } catch (error) {
      _dashboard = _dashboard.copyWith(wellnessPrompt: previousPrompt);
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  WellnessPrompt _extractWellnessPrompt(Map<String, dynamic> data) {
    final raw = data['wellness_prompt'];
    if (raw is Map<String, dynamic>) {
      return WellnessPrompt.fromJson(raw);
    }
    return WellnessPrompt(
      question: 'How are you feeling today?',
      options: const ['Happy 😊', 'Low 😔', 'Sick 🤢', 'Energetic ⚡'],
      selected: _dashboard.wellnessPrompt.selected,
    );
  }

  List<NutrientSummary>? _extractNutrients(Map<String, dynamic> data) {
    final raw = data['nutrients'];
    if (raw is List) {
      final summaries = raw
          .whereType<Map<String, dynamic>>()
          .map(NutrientSummary.fromJson)
          .toList();
      if (summaries.isNotEmpty) {
        return summaries;
      }
    }
    return null;
  }

  List<NutrientSummary> _aggregateNutrients() {
    if (_meals.isEmpty) {
      // When there are no meals for the selected date, explicitly reset macros to 0
      // to avoid carrying over values from previous days.
      return const [
        NutrientSummary(label: 'Protein', value: 0, maxValue: 100),
        NutrientSummary(label: 'Carbs', value: 0, maxValue: 100),
        NutrientSummary(label: 'Fats', value: 0, maxValue: 100),
        NutrientSummary(label: 'Fibre', value: 0, maxValue: 100),
      ];
    }

    final totalProtein = _meals.fold<double>(0, (sum, meal) => sum + meal.protein);
    final totalCarbs = _meals.fold<double>(0, (sum, meal) => sum + meal.carbs);
    final totalFat = _meals.fold<double>(0, (sum, meal) => sum + meal.fat);
    final totalFiber = _meals.fold<double>(0, (sum, meal) => sum + meal.fiber);

    return [
      NutrientSummary(label: 'Protein', value: totalProtein, maxValue: 100),
      NutrientSummary(label: 'Carbs', value: totalCarbs, maxValue: 100),
      NutrientSummary(label: 'Fats', value: totalFat, maxValue: 100),
      NutrientSummary(label: 'Fibre', value: totalFiber, maxValue: 100),
    ];
  }

  Future<void> _loadHydration(DateTime targetDate) async {
    final response = await ApiServices.getWaterLog(date: targetDate);
    if (!response.status) {
      return;
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final hydrationMap = data['hydration'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['hydration'] as Map)
          : data;
      final parsed = HydrationSummary.fromJson(hydrationMap);
      final double fallbackGoal = _dashboard.hydration.goal > 0
          ? _dashboard.hydration.goal
          : math.max(parsed.intake, 2500);
      final double normalizedGoal = parsed.goal > 0 ? parsed.goal : fallbackGoal;
      final double normalizedIntake = normalizedGoal > 0
          ? math.min(parsed.intake, normalizedGoal)
          : parsed.intake;

      final updatedHydration = _dashboard.hydration.copyWith(
        goal: normalizedGoal,
        intake: normalizedIntake,
        tip: parsed.tip.isNotEmpty ? parsed.tip : _dashboard.hydration.tip,
      );

      _dashboard = _dashboard.copyWith(hydration: updatedHydration);
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  Future<void> logWaterIntake(double amount, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    try {
      await ApiHelper.ensureFreshAccessToken();
      final payload = {
        'date': _formatDate(targetDate),
        'amount_ml': amount,
      };
      final res = await ApiServices.logWater(payload: payload);
      if (!res.status) {
        throw Exception(res.message);
      }
      await _loadHydration(targetDate);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  int _computeTotalCalories(List<Map<String, dynamic>> logs) {
    int total = 0;
    for (final entry in logs) {
      final foodlog = entry['foodlog'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(entry['foodlog'] as Map)
          : <String, dynamic>{};
      final mealInfo = foodlog['meal_info'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(foodlog['meal_info'] as Map)
          : <String, dynamic>{};
      final nutrition = foodlog['nutrition_data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(foodlog['nutrition_data'] as Map)
          : <String, dynamic>{};

      final dynamic caloriesValue =
          mealInfo['calories'] ?? nutrition['calories'] ?? nutrition['energy'];
      total += _parseToInt(caloriesValue, fallback: 0, defaultValue: 0);
    }
    return total;
  }

  int _parseToInt(dynamic value, {int fallback = 0, int defaultValue = 0}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback != 0 ? fallback : defaultValue;
  }

}
