class WeightTrendPoint {
  final DateTime date;
  final double weightKg;

  const WeightTrendPoint({required this.date, required this.weightKg});

  factory WeightTrendPoint.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return WeightTrendPoint(
      date: parseDate(json['date'] ?? json['label'] ?? json['x']),
      weightKg: parseDouble(json['weight'] ?? json['y'] ?? json['value']),
    );
  }
}

class WeightEntry {
  final DateTime date;
  final double weightKg;
  final int calories;
  final int burntCalories;

  const WeightEntry({
    required this.date,
    required this.weightKg,
    required this.calories,
    required this.burntCalories,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    double parseWeight(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return WeightEntry(
      date: parseDate(json['date'] ?? json['label']),
      weightKg: parseWeight(json['weight'] ?? json['weightKg'] ?? json['value']),
      calories: parseInt(json['calories'] ?? json['intake']),
      burntCalories: parseInt(json['burnt'] ?? json['burned'] ?? json['calories_burned']),
    );
  }
}

class WeightBmiInfo {
  final double score;
  final String status;
  final double minRange;
  final double maxRange;

  const WeightBmiInfo({
    required this.score,
    required this.status,
    required this.minRange,
    required this.maxRange,
  });

  factory WeightBmiInfo.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    String parseString(dynamic value) => value?.toString() ?? '';

    return WeightBmiInfo(
      score: parseDouble(json['score'] ?? json['bmi'] ?? json['value']),
      status: parseString(json['status'] ?? json['label'] ?? 'Normal'),
      minRange: parseDouble(json['min'] ?? json['min_range'] ?? 18.5),
      maxRange: parseDouble(json['max'] ?? json['max_range'] ?? 24.9),
    );
  }
}

class WeightDashboardData {
  final double goalWeight;
  final double currentWeight;
  final double progressPercent;
  final DateTime? projectedGoalDate;
  final List<WeightTrendPoint> trend;
  final List<WeightEntry> entries;
  final WeightBmiInfo bmi;

  const WeightDashboardData({
    required this.goalWeight,
    required this.currentWeight,
    required this.progressPercent,
    required this.projectedGoalDate,
    required this.trend,
    required this.entries,
    required this.bmi,
  });

  factory WeightDashboardData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    List<WeightTrendPoint> parseTrend(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(WeightTrendPoint.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    List<WeightEntry> parseEntries(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(WeightEntry.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    final bmiJson = json['bmi'] is Map<String, dynamic>
        ? json['bmi'] as Map<String, dynamic>
        : <String, dynamic>{};

    final trendPoints = parseTrend(json['trend'] ?? json['chart'] ?? json['timeline'])
      ..sort((a, b) => a.date.compareTo(b.date));
    final weightEntries = parseEntries(json['entries'] ?? json['history'] ?? json['logs'])
      ..sort((a, b) => b.date.compareTo(a.date));

    final rawProgress = parseDouble(json['progress_percent'] ?? json['progress'] ?? 0);
    final normalizedProgress = rawProgress > 1 ? rawProgress / 100 : rawProgress;

    return WeightDashboardData(
      goalWeight: parseDouble(json['goal_weight'] ?? json['goalWeight'] ?? json['goal']),
      currentWeight: parseDouble(json['current_weight'] ?? json['currentWeight'] ?? json['current']),
      progressPercent: normalizedProgress.clamp(0, 1),
      projectedGoalDate: parseDate(json['projected_goal_date'] ?? json['goalDate']),
      trend: trendPoints,
      entries: weightEntries,
      bmi: WeightBmiInfo.fromJson(bmiJson),
    );
  }

  static WeightDashboardData empty() {
    return WeightDashboardData(
      goalWeight: 0,
      currentWeight: 0,
      progressPercent: 0,
      projectedGoalDate: null,
      trend: const [],
      entries: const [],
      bmi: const WeightBmiInfo(score: 0, status: 'Unknown', minRange: 18.5, maxRange: 24.9),
    );
  }
}
