import 'dart:collection';

import 'package:flutter/material.dart';

/// Supported time ranges for the progress dashboard.
enum ProgressPeriod { daily, weekly, monthly, quarterly }

extension ProgressPeriodExtension on ProgressPeriod {
  String get apiValue {
    switch (this) {
      case ProgressPeriod.daily:
        return 'daily';
      case ProgressPeriod.weekly:
        return 'weekly';
      case ProgressPeriod.monthly:
        return 'monthly';
      case ProgressPeriod.quarterly:
        return 'quarterly';
    }
  }

  String get displayLabel {
    switch (this) {
      case ProgressPeriod.daily:
        return 'Daily';
      case ProgressPeriod.weekly:
        return 'Weekly';
      case ProgressPeriod.monthly:
        return 'Monthly';
      case ProgressPeriod.quarterly:
        return 'Quarterly';
    }
  }

  static ProgressPeriod fromLabel(String raw) {
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'weekly':
        return ProgressPeriod.weekly;
      case 'monthly':
        return ProgressPeriod.monthly;
      case 'quarterly':
        return ProgressPeriod.quarterly;
      case 'daily':
      default:
        return ProgressPeriod.daily;
    }
  }
}

class ProgressSeriesPoint {
  final String label;
  final double value;

  const ProgressSeriesPoint({required this.label, required this.value});

  factory ProgressSeriesPoint.fromJson(Map<String, dynamic> json) {
    return ProgressSeriesPoint(
      label: (json['label'] ?? json['date'] ?? json['x']).toString(),
      value: _parseToDouble(json['value'] ?? json['y']),
    );
  }
}

class ProgressSeries {
  final String key;
  final UnmodifiableListView<ProgressSeriesPoint> points;

  ProgressSeries({required this.key, required List<ProgressSeriesPoint> points})
      : points = UnmodifiableListView(points);
}

class ProgressEntry {
  final String label;
  final double value;
  final DateTime? date;
  final UnmodifiableMapView<String, double> macros;

  ProgressEntry({
    required this.label,
    required double value,
    DateTime? date,
    Map<String, double>? macros,
  })  : value = value,
        date = date,
        macros = UnmodifiableMapView(macros ?? const {});

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['label'];
    DateTime? parsedDate;
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    Map<String, double> parsedMacros = {};
    final macrosRaw = json['macros'] ?? json['values'];
    if (macrosRaw is Map<String, dynamic>) {
      parsedMacros = macrosRaw.map(
        (key, value) => MapEntry(key.toLowerCase(), _parseToDouble(value)),
      );
    }

    return ProgressEntry(
      label: (json['label'] ?? json['date'] ?? 'Entry').toString(),
      value: _parseToDouble(json['value'] ?? json['calories'] ?? json['amount']),
      date: parsedDate,
      macros: parsedMacros,
    );
  }
}

class ProgressMacroSummary {
  final String label;
  final double amount;
  final double percent;
  final String unit;

  const ProgressMacroSummary({
    required this.label,
    required this.amount,
    required this.percent,
    this.unit = 'g',
  });

  factory ProgressMacroSummary.fromJson(Map<String, dynamic> json) {
    final amount = _parseToDouble(json['amount'] ?? json['value'] ?? json['grams']);
    final percent = _parseToDouble(json['percent'] ?? json['percentage']);
    return ProgressMacroSummary(
      label: (json['label'] ?? json['name'] ?? json['title'] ?? '').toString(),
      amount: amount,
      percent: percent,
      unit: (json['unit'] ?? 'g').toString(),
    );
  }
}

class ProgressMacroEntry {
  final String label;
  final UnmodifiableMapView<String, double> values;

  ProgressMacroEntry({required this.label, required Map<String, double> values})
      : values = UnmodifiableMapView(values);

  factory ProgressMacroEntry.fromJson(Map<String, dynamic> json) {
    final valuesRaw = json['macros'] ?? json['values'] ?? json;
    final resolved = <String, double>{};
    if (valuesRaw is Map) {
      valuesRaw.forEach((key, value) {
        resolved[key.toString().toLowerCase()] = _parseToDouble(value);
      });
    }

    return ProgressMacroEntry(
      label: (json['label'] ?? json['date'] ?? json['title'] ?? '').toString(),
      values: resolved,
    );
  }
}

class ProgressCaloriesSummary {
  final double total;
  final double average;
  final double goal;

  const ProgressCaloriesSummary({
    required this.total,
    required this.average,
    required this.goal,
  });

  factory ProgressCaloriesSummary.fromJson(Map<String, dynamic> json) {
    return ProgressCaloriesSummary(
      total: _parseToDouble(
        json['total'] ?? json['total_calories'] ?? json['sum'] ?? 0,
      ),
      average: _parseToDouble(json['average'] ?? json['avg'] ?? json['mean'] ?? 0),
      goal: _parseToDouble(json['goal'] ?? json['target'] ?? json['goal_calories'] ?? 0),
    );
  }

  static const empty = ProgressCaloriesSummary(total: 0, average: 0, goal: 0);
}

class ProgressCaloriesData {
  final ProgressCaloriesSummary summary;
  final UnmodifiableListView<String> labels;
  final UnmodifiableMapView<String, List<double>> series;
  final UnmodifiableListView<ProgressEntry> entries;

  ProgressCaloriesData({
    required this.summary,
    required List<String> labels,
    required Map<String, List<double>> series,
    required List<ProgressEntry> entries,
  })  : labels = UnmodifiableListView(labels),
        series = UnmodifiableMapView(series.map((key, value) => MapEntry(key, List<double>.from(value)))),
        entries = UnmodifiableListView(entries);

  factory ProgressCaloriesData.fromJson(Map<String, dynamic> json) {
    final summaryRaw = (json['summary'] ?? json['totals'] ?? json) as Map<String, dynamic>;
    final summary = ProgressCaloriesSummary.fromJson(summaryRaw);
    final labels = _parseStringList(json['labels'] ?? json['dates'] ?? json['axis']);
    final series = _parseSeriesMap(json['series'] ?? json['datasets'] ?? json['lines']);
    final entriesRaw = json['entries'] ?? json['history'] ?? [];
    final entries = _parseEntryList(entriesRaw);

    return ProgressCaloriesData(
      summary: summary,
      labels: labels,
      series: series,
      entries: entries,
    );
  }

  factory ProgressCaloriesData.empty() {
    return ProgressCaloriesData(
      summary: ProgressCaloriesSummary.empty,
      labels: const [],
      series: const {},
      entries: const [],
    );
  }
}

class ProgressMacrosData {
  final UnmodifiableListView<String> labels;
  final UnmodifiableMapView<String, List<double>> series;
  final UnmodifiableListView<ProgressMacroEntry> entries;
  final UnmodifiableListView<ProgressMacroSummary> summaries;

  ProgressMacrosData({
    required List<String> labels,
    required Map<String, List<double>> series,
    required List<ProgressMacroEntry> entries,
    required List<ProgressMacroSummary> summaries,
  })  : labels = UnmodifiableListView(labels),
        series = UnmodifiableMapView(series.map((key, value) => MapEntry(key, List<double>.from(value)))),
        entries = UnmodifiableListView(entries),
        summaries = UnmodifiableListView(summaries);

  factory ProgressMacrosData.fromJson(Map<String, dynamic> json) {
    final labels = _parseStringList(json['labels'] ?? json['dates'] ?? json['axis']);
    final series = _parseSeriesMap(json['series'] ?? json['datasets'] ?? json['lines']);
    final entriesRaw = json['entries'] ?? json['history'];
    final entries = _parseMacroEntryList(entriesRaw);
    final summariesRaw = json['summary'] ?? json['totals'] ?? json['distribution'];
    final summaries = _parseMacroSummaryList(summariesRaw);

    return ProgressMacrosData(
      labels: labels,
      series: series,
      entries: entries,
      summaries: summaries,
    );
  }

  factory ProgressMacrosData.empty() {
    return ProgressMacrosData(
      labels: [],
      series: {},
      entries: [],
      summaries: [],
    );
  }
}

class ProgressNutrientsData {
  final UnmodifiableListView<ProgressMacroSummary> highlights;
  final UnmodifiableMapView<String, double> nutritionMap;

  ProgressNutrientsData({
    required List<ProgressMacroSummary> highlights,
    required Map<String, double> nutritionMap,
  })  : highlights = UnmodifiableListView(highlights),
        nutritionMap = UnmodifiableMapView(nutritionMap);

  factory ProgressNutrientsData.fromJson(Map<String, dynamic> json) {
    final highlightRaw = json['highlights'] ?? json['summary'] ?? json['cards'];
    final highlights = _parseMacroSummaryList(highlightRaw);
    final detailRaw = json['detail'] ?? json['breakdown'] ?? json['nutrition'] ?? {};
    final normalized = _normalizeNutrition(detailRaw);

    return ProgressNutrientsData(
      highlights: highlights,
      nutritionMap: normalized,
    );
  }

  Map<String, num> toNutritionCardPayload() {
    return {
      'energy': nutritionMap['energy'] ?? 0,
      'fat': nutritionMap['fat'] ?? 0,
      'saturatedFat': nutritionMap['saturatedFat'] ?? nutritionMap['saturated_fat'] ?? 0,
      'polyFat': nutritionMap['polyFat'] ?? nutritionMap['polyunsaturated_fat'] ?? 0,
      'monoFat': nutritionMap['monoFat'] ?? nutritionMap['monounsaturated_fat'] ?? 0,
      'cholestrol': nutritionMap['cholestrol'] ?? nutritionMap['cholesterol'] ?? 0,
      'fiber': nutritionMap['fiber'] ?? 0,
      'sugar': nutritionMap['sugar'] ?? 0,
      'sodium': nutritionMap['sodium'] ?? 0,
      'potassium': nutritionMap['potassium'] ?? 0,
    };
  }

  factory ProgressNutrientsData.empty() {
    return ProgressNutrientsData(highlights: const [], nutritionMap: const {});
  }
}

List<String> _parseStringList(dynamic raw) {
  if (raw is List) {
    return raw.map((item) => item.toString()).toList();
  }
  return const [];
}

Map<String, List<double>> _parseSeriesMap(dynamic raw) {
  final Map<String, List<double>> resolved = {};
  if (raw is Map) {
    raw.forEach((key, value) {
      resolved[key.toString()] = _parseDoubleList(value);
    });
    return resolved;
  }

  if (raw is List) {
    for (final item in raw) {
      if (item is Map) {
        final key = item['key'] ?? item['label'] ?? item['name'] ?? 'Series ${resolved.length + 1}';
        resolved[key.toString()] = _parseDoubleList(item['values'] ?? item['data']);
      }
    }
  }
  return resolved;
}

List<ProgressEntry> _parseEntryList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProgressEntry.fromJson)
        .toList();
  }
  return const [];
}

List<ProgressMacroEntry> _parseMacroEntryList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProgressMacroEntry.fromJson)
        .toList();
  }
  return const [];
}

List<ProgressMacroSummary> _parseMacroSummaryList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProgressMacroSummary.fromJson)
        .toList();
  }
  if (raw is Map) {
    return raw.entries
        .map(
          (entry) => ProgressMacroSummary(
            label: entry.key.toString(),
            amount: _parseToDouble(entry.value),
            percent: 0,
          ),
        )
        .toList();
  }
  return const [];
}

List<double> _parseDoubleList(dynamic raw) {
  if (raw is List) {
    return raw.map(_parseToDouble).toList();
  }
  return const [];
}

double _parseToDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

Map<String, double> _normalizeNutrition(dynamic raw) {
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), _parseToDouble(value)));
  }
  return const {};
}
