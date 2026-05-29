import 'exercise.dart';
import '../core/constants/rank_constants.dart';

/// Una sessione di allenamento completa.
class WorkoutSession {
  final String id;
  final String name;            // es. "Push Day"
  final DateTime startTime;
  final DateTime? endTime;
  final List<Exercise> exercises;
  final int xpGained;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    this.exercises = const [],
    this.xpGained = 0,
    this.notes,
  });

  // ─── Computed ──────────────────────────────────────────

  /// Volume totale della sessione in kg.
  int get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.totalVolume);

  /// Durata della sessione.
  Duration get duration =>
      (endTime ?? DateTime.now()).difference(startTime);

  /// True se la sessione è ancora in corso.
  bool get isActive => endTime == null;

  /// XP calcolato dal volume (usato se xpGained == 0).
  int get calculatedXp => calculateSessionXp(totalVolume);

  /// Mappa muscolo → volume accumulato in questa sessione.
  Map<String, int> get volumeByMuscle {
    final map = <String, int>{};
    for (final exercise in exercises) {
      map[exercise.muscleGroup] =
          (map[exercise.muscleGroup] ?? 0) + exercise.totalVolume;
    }
    return map;
  }

  /// Numero di serie totali completate.
  int get totalCompletedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSets);

  // ─── CopyWith ──────────────────────────────────────────
  WorkoutSession copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<Exercise>? exercises,
    int? xpGained,
    String? notes,
  }) => WorkoutSession(
    id:        id        ?? this.id,
    name:      name      ?? this.name,
    startTime: startTime ?? this.startTime,
    endTime:   endTime   ?? this.endTime,
    exercises: exercises ?? this.exercises,
    xpGained:  xpGained  ?? this.xpGained,
    notes:     notes     ?? this.notes,
  );

  // ─── Serializzazione ───────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':        id,
    'name':      name,
    'startTime': startTime.toIso8601String(),
    'endTime':   endTime?.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'xpGained':  xpGained,
    'notes':     notes,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id:        json['id']   as String,
    name:      json['name'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime:   json['endTime'] != null
        ? DateTime.tryParse(json['endTime'] as String)
        : null,
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    xpGained: json['xpGained'] as int? ?? 0,
    notes:    json['notes'] as String?,
  );

  /// Crea una nuova sessione vuota con id e orario corrente.
  factory WorkoutSession.start(String name) => WorkoutSession(
    id:        DateTime.now().millisecondsSinceEpoch.toString(),
    name:      name,
    startTime: DateTime.now(),
  );
}