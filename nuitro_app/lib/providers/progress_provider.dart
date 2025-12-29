import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/models/progress_models.dart';
import 'package:nuitro/services/api_helper.dart';
import 'package:nuitro/services/services.dart';

class ProgressProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  ProgressPeriod _currentPeriod = ProgressPeriod.daily;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasLoadedOnce = false;

  ProgressCaloriesData _calories = ProgressCaloriesData.empty();
  ProgressMacrosData _macros = ProgressMacrosData.empty();
  ProgressNutrientsData _nutrients = ProgressNutrientsData.empty();
  UnmodifiableMapView<String, dynamic> _analytics =
      UnmodifiableMapView(<String, dynamic>{});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProgressPeriod get currentPeriod => _currentPeriod;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get hasLoadedOnce => _hasLoadedOnce;

  ProgressCaloriesData get calories => _calories;
  ProgressMacrosData get macros => _macros;
  ProgressNutrientsData get nutrients => _nutrients;
  UnmodifiableMapView<String, dynamic> get analytics => _analytics;

  Future<void> loadProgress({
    ProgressPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool refreshAnalytics = false,
  }) async {
    final targetPeriod = period ?? _currentPeriod;
    final targetStart = startDate ?? _startDate;
    final targetEnd = endDate ?? _endDate;

    debugPrint('[ProgressProvider][loadProgress][REQ] period=${targetPeriod.apiValue} start=${targetStart?.toIso8601String()} end=${targetEnd?.toIso8601String()} refreshAnalytics=$refreshAnalytics');

    _currentPeriod = targetPeriod;
    _startDate = targetStart;
    _endDate = targetEnd;
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiHelper.ensureFreshAccessToken();

      final requests = <Future<ApiResponse>>[
        ApiServices.getProgressCalories(
          period: targetPeriod.apiValue,
          startDate: targetStart,
          endDate: targetEnd,
        ),
        ApiServices.getProgressMacros(
          period: targetPeriod.apiValue,
          startDate: targetStart,
          endDate: targetEnd,
        ),
        ApiServices.getProgressNutrients(
          period: targetPeriod.apiValue,
          startDate: targetStart,
          endDate: targetEnd,
        ),
      ];

      final shouldRefreshAnalytics = refreshAnalytics || !_hasLoadedOnce;
      if (shouldRefreshAnalytics) {
        requests.add(
          ApiServices.getProgressAnalytics(
            period: targetPeriod.apiValue,
            startDate: targetStart,
            endDate: targetEnd,
          ),
        );
      }

      final responses = await Future.wait(requests);

      _handleCaloriesResponse(responses[0]);
      _handleMacrosResponse(responses[1]);
      _handleNutrientsResponse(responses[2]);

      if (responses.length > 3) {
        _handleAnalyticsResponse(responses[3]);
      }

      _hasLoadedOnce = true;
      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('[ProgressProvider][loadProgress] $error\n$stackTrace');
      _errorMessage = error.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() {
    return loadProgress(
      period: _currentPeriod,
      startDate: _startDate,
      endDate: _endDate,
      refreshAnalytics: true,
    );
  }

  void setPeriod(ProgressPeriod period) {
    if (_currentPeriod == period) {
      return;
    }
    loadProgress(period: period);
  }

  void setCustomRange(DateTime start, DateTime end) {
    loadProgress(startDate: start, endDate: end, refreshAnalytics: true);
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _handleCaloriesResponse(ApiResponse response) {
    if (!response.status) {
      throw Exception(response.message);
    }
    final data = _asMap(response.data);
    if (data == null) {
      throw Exception('Unexpected calories payload');
    }
    _calories = ProgressCaloriesData.fromJson(data);
    try {
      final labels = _calories.labels;
      final seriesKeys = _calories.series.keys.join(',');
      debugPrint('[ProgressProvider][calories][PARSED] labels=${labels.length} series_keys=[$seriesKeys] entries=${_calories.entries.length} summary=${_calories.summary.total}/${_calories.summary.average}/${_calories.summary.goal}');
    } catch (_) {}
  }

  void _handleMacrosResponse(ApiResponse response) {
    if (!response.status) {
      throw Exception(response.message);
    }
    final data = _asMap(response.data);
    if (data == null) {
      throw Exception('Unexpected macros payload');
    }
    _macros = ProgressMacrosData.fromJson(data);
    try {
      final labels = _macros.labels.length;
      final seriesKeys = _macros.series.keys.join(',');
      debugPrint('[ProgressProvider][macros][PARSED] labels=$labels series_keys=[$seriesKeys] entries=${_macros.entries.length} summaries=${_macros.summaries.length}');
    } catch (_) {}
  }

  void _handleNutrientsResponse(ApiResponse response) {
    if (!response.status) {
      throw Exception(response.message);
    }
    final data = _asMap(response.data);
    if (data == null) {
      throw Exception('Unexpected nutrients payload');
    }
    _nutrients = ProgressNutrientsData.fromJson(data);
    try {
      debugPrint('[ProgressProvider][nutrients][PARSED] highlights=${_nutrients.highlights.length} detail_keys=${_nutrients.nutritionMap.length}');
    } catch (_) {}
  }

  void _handleAnalyticsResponse(ApiResponse response) {
    if (!response.status) {
      throw Exception(response.message);
    }
    final map = _asMap(response.data) ?? <String, dynamic>{};
    _analytics = UnmodifiableMapView(map);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
