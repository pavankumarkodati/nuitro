import 'package:flutter/foundation.dart';
import 'package:nuitro/models/diet_plan.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';

class DietTargets {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final double waterLiters;

  const DietTargets({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.waterLiters = 0,
  });

  static const empty = DietTargets();

  bool get hasTargets =>
      calories > 0 || protein > 0 || carbs > 0 || fat > 0 || fiber > 0 || waterLiters > 0;

  factory DietTargets.fromPlans(List<DietPlan> plans) {
    if (plans.isEmpty) {
      return DietTargets.empty;
    }

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;
    int fiber = 0;
    double water = 0;

    for (final plan in plans) {
      calories += plan.calories;
      protein += plan.protein;
      carbs += plan.carbs;
      fat += plan.fat;
      fiber += plan.fiber ?? 0;
      water += plan.waterLiters ?? 0;
    }

    return DietTargets(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      waterLiters: water,
    );
  }
}

class DietProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  List<DietPlan> _myDiets = const [];
  DietTargets _targets = DietTargets.empty;

  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;
  List<DietPlan> get myDiets => _myDiets;
  DietTargets get targets => _targets;

  Future<void> fetchMyDiets({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_hasLoadedOnce && !forceRefresh) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final ApiResponse response = await ApiServices.getMyDiets();
      if (!response.status) {
        throw Exception(response.message);
      }

      final List<DietPlan> parsed = _parseDietList(response.data);
      _myDiets = parsed;
      _targets = DietTargets.fromPlans(parsed);
      _hasLoadedOnce = true;
      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('[DietProvider][fetchMyDiets] $error\n$stackTrace');
      _errorMessage = error.toString();
      _targets = DietTargets.empty;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshMyDiets() {
    _hasLoadedOnce = false;
    return fetchMyDiets(forceRefresh: true);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  List<DietPlan> _parseDietList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(DietPlan.fromJson)
          .toList(growable: false);
    }

    if (raw is Map<String, dynamic>) {
      final listCandidate = raw['diets'] ?? raw['diet'] ?? raw['results'] ?? raw['data'] ?? raw['items'];
      if (listCandidate is List) {
        return listCandidate
            .whereType<Map<String, dynamic>>()
            .map(DietPlan.fromJson)
            .toList(growable: false);
      }
    }

    return const [];
  }
}
