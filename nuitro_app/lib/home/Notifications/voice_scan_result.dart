import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/providers/scan_workflow_provider.dart';
import 'package:nuitro/services/services.dart';

import 'food_detail_header.dart';
import 'meal_summary.dart';
import 'nutrition_card.dart';

class VoiceScanResult extends StatefulWidget {
  final String spokenText;
  final Map<String, dynamic> prediction;
  final List<Map<String, dynamic>> predictions;

  const VoiceScanResult({
    Key? key,
    required this.spokenText,
    required this.prediction,
    this.predictions = const [],
  }) : super(key: key);

  @override
  State<VoiceScanResult> createState() => _VoiceScanResultState();
}

class _VoiceScanResultState extends State<VoiceScanResult> {
  late Map<String, dynamic> _activePrediction;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _activePrediction = Map<String, dynamic>.from(widget.prediction);
  }

  Map<String, dynamic> get nutritionData {
    final foodlog = _foodlog;
    final data = foodlog?['nutrition_data'] ??
        _activePrediction['nutrition_data'] ??
        _activePrediction['nutrition'] ??
        {};
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  Map<String, dynamic> get mealInfo {
    final foodlog = _foodlog;
    final info = foodlog?['meal_info'] ?? _activePrediction['meal_info'];
    if (info is Map<String, dynamic>) {
      return Map<String, dynamic>.from(info);
    }
    return {
      'meal': _activePrediction['meal']?.toString() ?? 'Voice Log',
      'calories': _asInt(_activePrediction['calories']),
      'protein': _asFraction(_activePrediction['protein']),
      'carbs': _asFraction(_activePrediction['carbs']),
      'fat': _asFraction(_activePrediction['fat']),
    };
  }

  String get foodName {
    final foodlog = _foodlog;
    final name = foodlog?['food_name'] ??
        _activePrediction['name'] ??
        _activePrediction['food_name'] ??
        _activePrediction['title'];
    if (name is String && name.trim().isNotEmpty) {
      return name;
    }
    return widget.spokenText;
  }

  String get servingSize {
    final foodlog = _foodlog;
    final serving = foodlog?['serving_size'] ??
        _activePrediction['serving_size'] ??
        _activePrediction['serving'] ??
        _activePrediction['servingSize'];
    if (serving is String && serving.trim().isNotEmpty) {
      return serving;
    }
    final nutrition = nutritionData;
    final energy = nutrition['energy'] ?? nutrition['calories'];
    if (energy != null) {
      return '${energy.toString()} kcal';
    }
    return 'Serving size unavailable';
  }

  String? get imageUrl {
    final foodlog = _foodlog;
    final url = foodlog?['image_url'] ??
        _activePrediction['image_url'] ??
        _activePrediction['image'];
    if (url is String && url.isNotEmpty) {
      return url;
    }
    return null;
  }

  List<Map<String, dynamic>> get allPredictions {
    final seen = <int>{};
    final combined = <Map<String, dynamic>>[];
    List<Map<String, dynamic>> base = widget.predictions;
    if (base.isEmpty && widget.prediction.isNotEmpty) {
      base = [widget.prediction];
    }
    for (final entry in base) {
      final hash = entry.hashCode;
      if (seen.add(hash)) {
        combined.add(entry);
      }
    }
    if (!combined.contains(_activePrediction)) {
      combined.insert(0, _activePrediction);
    }
    return combined;
  }

  Future<void> _handleSaveLog() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final response = await context.read<ScanWorkflowProvider>().saveVoiceLog();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.status ? null : Colors.red,
        ),
      );
      if (response.status) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _switchPrediction(Map<String, dynamic> selection) {
    setState(() {
      _activePrediction = Map<String, dynamic>.from(selection);
    });
  }

  Map<String, dynamic>? get _foodlog {
    final raw = _activePrediction['foodlog'];
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meal = mealInfo;
    final nutrition = nutritionData;
    final options = allPredictions;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              FoodDetailHeader(
                foodName: foodName,
                servingSize: servingSize,
                imageUrl: imageUrl ?? 'assets/images/Food.png',
                onBack: () => Navigator.pop(context),
                onFavorite: () {
                  debugPrint('Favorite clicked');
                },
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _VoicePromptSummary(prompt: widget.spokenText),
                          if (options.length > 1)
                            _PredictionSelector(
                              predictions: options,
                              active: _activePrediction,
                              onSelected: _switchPrediction,
                            ),
                          MealSummaryCard(
                            mealName: meal['meal']?.toString() ?? 'Voice Log',
                            calories: meal['calories'] is int
                                ? meal['calories'] as int
                                : _asInt(meal['calories']),
                            proteinPercent: _asFraction(meal['protein']),
                            carbsPercent: _asFraction(meal['carbs']),
                            fatPercent: _asFraction(meal['fat']),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: NutritionCard(
                      editDeleteEnable: false,
                      nutritionData: _normalizeNutrition(nutrition),
                      onDelete: () {},
                      onEdit: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      children: [
                        SizedBox(
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
                            onPressed: _isSaving ? null : _handleSaveLog,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Save Log',
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                  ),
                          ),
                        ),
                        // const SizedBox(height: 12),
                        // SizedBox(
                        //   height: 50,
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.black,
                        //       foregroundColor: Colors.white,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //     onPressed: _isSaving ? null : _handleSaveLog,
                        //     child: _isSaving
                        //         ? const SizedBox(
                        //             width: 20,
                        //             height: 20,
                        //             child: CircularProgressIndicator(strokeWidth: 2),
                        //           )
                        //         : const Text(
                        //             'Save Log',
                        //             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                        //           ),
                        //   ),
                        // ),
                      ],
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

  Map<String, dynamic> _normalizeNutrition(Map<String, dynamic> nutrition) {
    final normalized = <String, dynamic>{
      'energy': _asInt(nutrition['energy'] ?? nutrition['calories']),
      'fat': _asDouble(nutrition['fat'] ?? nutrition['total_fat']),
      'saturatedFat': _asDouble(nutrition['saturatedFat'] ?? nutrition['saturated_fat']),
      'polyFat': _asDouble(nutrition['polyFat'] ?? nutrition['poly_fat']),
      'monoFat': _asDouble(nutrition['monoFat'] ?? nutrition['mono_fat']),
      'cholestrol': _asDouble(nutrition['cholestrol'] ?? nutrition['cholesterol']),
      'fiber': _asDouble(nutrition['fiber']),
      'sugar': _asDouble(nutrition['sugar']),
      'sodium': _asDouble(nutrition['sodium']),
      'potassium': _asDouble(nutrition['potassium']),
    };

    normalized.updateAll((key, value) => value ?? 0);
    return normalized;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asFraction(dynamic value) {
    if (value is num) {
      final doubleValue = value.toDouble();
      if (doubleValue <= 1.0) {
        return doubleValue.clamp(0.0, 1.0);
      }
      return (doubleValue / 100).clamp(0.0, 1.0);
    }
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      return 0;
    }
    if (parsed <= 1.0) {
      return parsed.clamp(0.0, 1.0);
    }
    return (parsed / 100).clamp(0.0, 1.0);
  }
}

class _VoicePromptSummary extends StatelessWidget {
  final String prompt;

  const _VoicePromptSummary({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Prompt',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            prompt,
            style: GoogleFonts.manrope(fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PredictionSelector extends StatelessWidget {
  final List<Map<String, dynamic>> predictions;
  final Map<String, dynamic> active;
  final ValueChanged<Map<String, dynamic>> onSelected;

  const _PredictionSelector({
    required this.predictions,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Predicted Items',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = predictions[index];
              final String title = item['name']?.toString() ??
                  item['food_name']?.toString() ??
                  'Prediction ${index + 1}';
              final bool isSelected = identical(item, active);

              return ChoiceChip(
                label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: isSelected,
                onSelected: (_) => onSelected(item),
                selectedColor: const Color.fromRGBO(220, 250, 157, 1),
                backgroundColor: Colors.grey.shade200,
                labelStyle: GoogleFonts.manrope(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.black,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: predictions.length,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
