import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/api_helper.dart';
import 'package:nuitro/services/services.dart';

class ScanWorkflowProvider extends ChangeNotifier {
  String _manualQuery = '';
  bool _manualLoading = false;
  String? _manualError;
  final List<Map<String, dynamic>> _manualResults = [];
  Map<String, dynamic>? _manualSelection;

  String _voiceTranscript = '';
  String? _voiceError;
  bool _voiceLoading = false;
  final List<Map<String, dynamic>> _voiceResults = [];
  Map<String, dynamic>? _voiceSelection;

  String _logsQuery = '';
  bool _logsLoading = false;
  String? _logsError;
  final List<Map<String, dynamic>> _logsAllResults = [];
  final List<Map<String, dynamic>> _logsResults = [];
  Map<String, dynamic>? _logsSelection;

  bool _isCapturing = false;
  String? _captureError;

  UnmodifiableListView<Map<String, dynamic>> get manualResults =>
      UnmodifiableListView(_manualResults);
  UnmodifiableListView<Map<String, dynamic>> get logsResults =>
      UnmodifiableListView(_logsResults);

  String get manualQuery => _manualQuery;
  bool get manualLoading => _manualLoading;
  String? get manualError => _manualError;
  Map<String, dynamic>? get manualSelection => _manualSelection;

  String get voiceTranscript => _voiceTranscript;
  String? get voiceError => _voiceError;
  bool get voiceLoading => _voiceLoading;
  UnmodifiableListView<Map<String, dynamic>> get voiceResults =>
      UnmodifiableListView(_voiceResults);
  Map<String, dynamic>? get voiceSelection => _voiceSelection;

  String get logsQuery => _logsQuery;
  bool get logsLoading => _logsLoading;
  String? get logsError => _logsError;
  Map<String, dynamic>? get logsSelection => _logsSelection;
  int get logsTotalCount => _logsAllResults.length;

  bool get isCapturing => _isCapturing;
  String? get captureError => _captureError;

  void updateManualQuery(String value) {
    _manualQuery = value;
    _manualError = null;
    if (_manualSelection != null) {
      _manualSelection = null;
    }
    notifyListeners();
  }

  Future<ApiResponse> predictManualFood() async {
    final selectionName = _manualSelection?['name']?.toString().trim();
    final query = (selectionName != null && selectionName.isNotEmpty)
        ? selectionName
        : _manualQuery.trim();

    if (query.isEmpty) {
      _manualResults.clear();
      _manualError = 'Select or enter a food before predicting';
      notifyListeners();
      return ApiResponse(status: false, message: _manualError!, data: null);
    }

    _manualLoading = true;
    _manualError = null;
    notifyListeners();

    try {
      await ApiHelper.ensureFreshAccessToken();
      final response = await ApiServices.manualPredictFood(query);
      if (response.status) {
        final dynamic payload = response.data;
        final dynamic resultList =
            payload is Map<String, dynamic> ? (payload['result'] ?? payload['results']) : null;

        final predictions = _ensureMapList(resultList ?? payload);
        _manualResults
          ..clear()
          ..addAll(predictions);

        if (_manualResults.isEmpty) {
          _manualError = 'No prediction available';
        } else {
          _manualSelection = _manualResults.first;
          final firstName = _manualSelection?['name']?.toString();
          if (firstName != null && firstName.isNotEmpty) {
            _manualQuery = firstName;
          }
        }
      } else {
        _manualError = response.message;
        _manualResults.clear();
      }
      notifyListeners();
      return response;
    } catch (error) {
      final message = error.toString();
      _manualError = message;
      _manualResults.clear();
      notifyListeners();
      return ApiResponse(status: false, message: message, data: null);
    } finally {
      _manualLoading = false;
      notifyListeners();
    }
  }

  void selectManualResult(Map<String, dynamic> result) {
    _manualSelection = result;
    final name = result['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      _manualQuery = name;
    }
    notifyListeners();
  }

  void clearManualSelection() {
    _manualSelection = null;
    notifyListeners();
  }

  void applyManualSelectionQuery(String value) {
    _manualQuery = value;
    notifyListeners();
  }

  Future<ApiResponse> searchManualFoods() async {
    if (_manualQuery.trim().isEmpty) {
      _manualResults.clear();
      _manualError = 'Enter food details to search';
      notifyListeners();
      return ApiResponse(
        status: false,
        message: _manualError!,
        data: null,
      );
    }

    _manualLoading = true;
    _manualError = null;
    notifyListeners();

    try {
      await ApiHelper.ensureFreshAccessToken();
      final response = await ApiServices.manualSearchFoods(_manualQuery.trim());
      if (response.status) {
        final dynamic payload = response.data;
        final dynamic resultList = payload is Map<String, dynamic>
            ? (payload['result'] ?? payload['results'])
            : null;

        _manualResults
          ..clear()
          ..addAll(_ensureMapList(resultList));
        if (_manualResults.isEmpty) {
          _manualError = 'No matches found';
        }
      } else {
        _manualError = response.message;
        _manualResults.clear();
      }
      notifyListeners();
      return response;
    } catch (error) {
      _manualError = error.toString();
      _manualResults.clear();
      notifyListeners();
      return ApiResponse(status: false, message: _manualError!, data: null);
    } finally {
      _manualLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse> saveManualEntry() async {
    if (_manualQuery.trim().isEmpty && _manualSelection == null) {
      return ApiResponse(
        status: false,
        message: 'Add or select an item before saving',
        data: null,
      );
    }

    try {
      await ApiHelper.ensureFreshAccessToken();
      return await ApiServices.manualSaveEntry({
        'query': _manualQuery.trim(),
        if (_manualSelection != null) 'selection': _manualSelection,
      });
    } catch (error) {
      return ApiResponse(status: false, message: error.toString(), data: null);
    }
  }

  void setVoiceTranscript(String transcript) {
    _voiceTranscript = transcript;
    if (transcript.trim().isEmpty) {
      _voiceResults.clear();
      _voiceSelection = null;
    }
    notifyListeners();
  }

  void setVoiceError(String? message) {
    _voiceError = message;
    notifyListeners();
  }

  void clearVoiceTranscript() {
    _voiceTranscript = '';
    _voiceError = null;
    _voiceResults.clear();
    _voiceSelection = null;
    notifyListeners();
  }

  void selectVoiceResult(Map<String, dynamic> result) {
    _voiceSelection = result;
    notifyListeners();
  }

  Future<ApiResponse> predictVoice() async {
    final transcript = _voiceTranscript.trim();
    if (transcript.isEmpty) {
      const message = 'Record a voice prompt before predicting';
      _voiceError = message;
      _voiceResults.clear();
      _voiceSelection = null;
      notifyListeners();
      return ApiResponse(status: false, message: message, data: null);
    }

    _voiceLoading = true;
    _voiceError = null;
    notifyListeners();

    try {
      await ApiHelper.ensureFreshAccessToken();
      final response = await ApiServices.voicePredict(transcript);
      if (response.status) {
        _applyVoicePredictions(response.data);
        if (_voiceResults.isEmpty) {
          _voiceError = 'No prediction available';
        }
      } else {
        _voiceError = response.message;
        _voiceResults.clear();
        _voiceSelection = null;
      }
      notifyListeners();
      return response;
    } catch (error) {
      final message = error.toString();
      _voiceError = message;
      _voiceResults.clear();
      _voiceSelection = null;
      notifyListeners();
      return ApiResponse(status: false, message: message, data: null);
    } finally {
      _voiceLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse> captureManual() async {
    final payload = {
      if (_manualSelection != null) 'selection': _manualSelection,
      if (_manualQuery.trim().isNotEmpty) 'query': _manualQuery.trim(),
    };

    if (payload.isEmpty) {
      final response = ApiResponse(
        status: false,
        message: 'Select a result or enter details before capturing',
        data: null,
      );
      _captureError = response.message;
      notifyListeners();
      return response;
    }

    return _performCapture(() async {
      await ApiHelper.ensureFreshAccessToken();
      return await ApiServices.manualCapture(payload);
    });
  }

  Future<ApiResponse> captureVoice() async {
    if (_voiceTranscript.trim().isEmpty) {
      final response = ApiResponse(
        status: false,
        message: 'Record a voice prompt before capturing',
        data: null,
      );
      _captureError = response.message;
      notifyListeners();
      return response;
    }

    return _performCapture(() async {
      await ApiHelper.ensureFreshAccessToken();
      return await ApiServices.voiceCapture({
        'transcript': _voiceTranscript.trim(),
        if (_voiceSelection != null) 'selection': _voiceSelection,
      });
    });
  }

  Future<ApiResponse> saveVoiceLog() async {
    final transcript = _voiceTranscript.trim();
    final selection = _voiceSelection;

    if (transcript.isEmpty && selection == null) {
      const message = 'Record a voice prompt before saving';
      return ApiResponse(status: false, message: message, data: null);
    }

    try {
      await ApiHelper.ensureFreshAccessToken();
      final payload = <String, dynamic>{
        if (transcript.isNotEmpty) 'query': transcript,
        if (selection != null) 'selection': selection,
      };
      return await ApiServices.manualSaveEntry(payload);
    } catch (error) {
      return ApiResponse(status: false, message: error.toString(), data: null);
    }
  }

  void updateLogsQuery(String value) {
    _logsQuery = value;
    _logsError = null;
    if (_logsSelection != null) {
      _logsSelection = null;
    }
    _applyLogsFilter(updateError: true);
    notifyListeners();
  }

  void selectLogsResult(Map<String, dynamic> result) {
    _logsSelection = result;
    notifyListeners();
  }

  void clearLogsSelection() {
    _logsSelection = null;
    notifyListeners();
  }

  Future<ApiResponse> loadLogs({DateTime? date, bool forceRefresh = false}) async {
    final targetDate = date ?? DateTime.now();
    if (_logsAllResults.isNotEmpty && !forceRefresh) {
      _applyLogsFilter(updateError: true);
      notifyListeners();
      return ApiResponse(status: true, message: 'Logs cached', data: null);
    }

    _logsLoading = true;
    _logsError = null;
    notifyListeners();

    try {
      await ApiHelper.ensureFreshAccessToken();
      final response = await ApiServices.logsSearch(date: targetDate);
      if (response.status) {
        final fetched = _ensureMapList(response.data?['results']);
        _logsAllResults
          ..clear()
          ..addAll(fetched);
        _applyLogsFilter(updateError: true);
      } else {
        _logsAllResults.clear();
        _logsResults.clear();
        _logsError = response.message;
      }
      notifyListeners();
      return response;
    } catch (error) {
      _logsAllResults.clear();
      _logsResults.clear();
      _logsError = error.toString();
      notifyListeners();
      return ApiResponse(status: false, message: _logsError!, data: null);
    } finally {
      _logsLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse> searchLogs({DateTime? date}) async {
    if (_logsAllResults.isEmpty) {
      return await loadLogs(date: date);
    }

    _applyLogsFilter(updateError: true);
    notifyListeners();
    return ApiResponse(status: true, message: 'Logs filtered', data: null);
  }

  void _applyLogsFilter({bool updateError = false}) {
    final query = _logsQuery.trim().toLowerCase();

    List<Map<String, dynamic>> filtered;
    if (query.isEmpty) {
      filtered = _logsAllResults
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    } else {
      filtered = _logsAllResults.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final description = item['description']?.toString().toLowerCase() ?? '';
        final meal = item['meal']?.toString().toLowerCase() ?? '';
        return name.contains(query) || description.contains(query) || meal.contains(query);
      }).map((item) => Map<String, dynamic>.from(item)).toList(growable: false);
    }

    _logsResults
      ..clear()
      ..addAll(filtered);

    if (updateError) {
      _logsError = filtered.isEmpty && query.isNotEmpty ? 'No matches found' : null;
    }
  }

  Future<ApiResponse> captureLogs() async {
    final selected = _logsSelection;
    if (selected == null && _logsQuery.trim().isEmpty) {
      final response = ApiResponse(
        status: false,
        message: 'Select a food item before capturing',
        data: null,
      );
      _captureError = response.message;
      notifyListeners();
      return response;
    }

    return _performCapture(() async {
      await ApiHelper.ensureFreshAccessToken();
      return await ApiServices.logsCapture({
        if (selected != null) 'selection': selected,
        if (_logsQuery.trim().isNotEmpty) 'query': _logsQuery.trim(),
      });
    });
  }

  Future<ApiResponse> _performCapture(
    Future<ApiResponse> Function() action,
  ) async {
    if (_isCapturing) {
      return ApiResponse(
        status: false,
        message: 'Capture already in progress',
        data: null,
      );
    }

    _isCapturing = true;
    _captureError = null;
    notifyListeners();

    try {
      final response = await action();
      if (!response.status) {
        _captureError = response.message;
      }
      notifyListeners();
      return response;
    } catch (error) {
      final message = error.toString();
      _captureError = message;
      notifyListeners();
      return ApiResponse(status: false, message: message, data: null);
    } finally {
      _isCapturing = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _ensureMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  void _applyVoicePredictions(dynamic payload) {
    final List<Map<String, dynamic>> predictions = _extractPredictionList(payload);

    _voiceResults
      ..clear()
      ..addAll(predictions);

    if (_voiceResults.isNotEmpty) {
      _voiceSelection = _voiceResults.first;
    } else if (payload is Map<String, dynamic>) {
      _voiceSelection = Map<String, dynamic>.from(payload);
      _voiceResults.add(_voiceSelection!);
    } else {
      _voiceSelection = null;
    }
  }

  List<Map<String, dynamic>> _extractPredictionList(dynamic payload) {
    if (payload is List) {
      return _ensureMapList(payload);
    }
    if (payload is Map<String, dynamic>) {
      final dynamic firstLayer = payload['result'] ?? payload['results'];
      final listFromFirstLayer = _ensureMapList(firstLayer);
      if (listFromFirstLayer.isNotEmpty) {
        return listFromFirstLayer;
      }
      final dynamic dataLayer = payload['data'];
      if (dataLayer != null && dataLayer is List) {
        final listFromData = _ensureMapList(dataLayer);
        if (listFromData.isNotEmpty) {
          return listFromData;
        }
      } else if (dataLayer is Map<String, dynamic>) {
        final dynamic nestedResults = dataLayer['result'] ?? dataLayer['results'];
        final listFromNested = _ensureMapList(nestedResults ?? dataLayer);
        if (listFromNested.isNotEmpty) {
          return listFromNested;
        }
      }

      return _ensureMapList(payload.values
          .whereType<List>()
          .expand((element) => element)
          .toList());
    }
    return [];
  }
}
