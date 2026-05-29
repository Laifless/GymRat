/// Una singola serie di un esercizio.
/// Es: 4 × 80 kg → [reps: 4, weightKg: 80]
class ExerciseSet {
  final int reps;
  final double weightKg;
  final bool completed;

  const ExerciseSet({
    required this.reps,
    required this.weightKg,
    this.completed = false,
  });

  /// Volume di questa serie in kg (peso × reps).
  int get volume => (weightKg * reps).round();

  ExerciseSet copyWith({
    int? reps,
    double? weightKg,
    bool? completed,
  }) => ExerciseSet(
    reps:      reps      ?? this.reps,
    weightKg:  weightKg  ?? this.weightKg,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'reps':      reps,
    'weightKg':  weightKg,
    'completed': completed,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    reps:      json['reps']      as int,
    weightKg:  (json['weightKg'] as num).toDouble(),
    completed: json['completed'] as bool? ?? false,
  );
}