import '../core/constants/rank_constants.dart';

/// Dati cumulativi di un gruppo muscolare.
/// Calcolato aggregando tutte le sessioni storiche.
class MuscleData {
  final String muscleGroup;     // chiave da kMuscleGroups
  final int totalVolume;        // kg cumulativi
  final DateTime? lastTrained;

  const MuscleData({
    required this.muscleGroup,
    this.totalVolume = 0,
    this.lastTrained,
  });

  /// Tier corrente basato sul volume cumulativo.
  MuscleTierInfo get tier => getTierFromVolume(totalVolume);

  /// Progresso [0.0 – 1.0] verso il tier successivo.
  double get progress => tierProgress(totalVolume);

  /// Volume mancante al tier successivo (null se già Titan).
  int? get volumeToNextTier {
    for (int i = 0; i < kMuscleTiers.length - 1; i++) {
      if (totalVolume < kMuscleTiers[i + 1].minVolume) {
        return kMuscleTiers[i + 1].minVolume - totalVolume;
      }
    }
    return null;
  }

  /// Nome leggibile del gruppo muscolare (prima lettera maiuscola).
  String get displayName =>
      muscleGroup[0].toUpperCase() + muscleGroup.substring(1);

  MuscleData copyWith({
    String? muscleGroup,
    int? totalVolume,
    DateTime? lastTrained,
  }) => MuscleData(
    muscleGroup: muscleGroup ?? this.muscleGroup,
    totalVolume: totalVolume ?? this.totalVolume,
    lastTrained: lastTrained ?? this.lastTrained,
  );

  Map<String, dynamic> toJson() => {
    'muscleGroup': muscleGroup,
    'totalVolume': totalVolume,
    'lastTrained': lastTrained?.toIso8601String(),
  };

  factory MuscleData.fromJson(Map<String, dynamic> json) => MuscleData(
    muscleGroup: json['muscleGroup'] as String,
    totalVolume: json['totalVolume'] as int? ?? 0,
    lastTrained: json['lastTrained'] != null
        ? DateTime.tryParse(json['lastTrained'] as String)
        : null,
  );

  /// Crea un MuscleData vuoto per un muscolo.
  factory MuscleData.empty(String muscleGroup) =>
      MuscleData(muscleGroup: muscleGroup);
}