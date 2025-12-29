import 'package:flutter/foundation.dart';
import 'package:nuitro/models/weight_models.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';

class WeightProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  WeightDashboardData _dashboard = WeightDashboardData.empty();

  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;
  WeightDashboardData get dashboard => _dashboard;

  Future<void> fetchDashboard({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_hasLoadedOnce && !forceRefresh) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final ApiResponse response = await ApiServices.getWeightDashboard();
      if (!response.status) {
        throw Exception(response.message);
      }

      final dataMap = _asMap(response.data);
      if (dataMap == null) {
        throw Exception('Unexpected weight dashboard payload');
      }

      _dashboard = WeightDashboardData.fromJson(dataMap);
      _hasLoadedOnce = true;
      _errorMessage = null;
    } catch (error, stackTrace) {
      debugPrint('[WeightProvider][fetchDashboard] $error\n$stackTrace');
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshDashboard() {
    _hasLoadedOnce = false;
    return fetchDashboard(forceRefresh: true);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }
}
