import 'exercise_set.dart';

/// Un esercizio all'interno di una sessione.
/// Contiene il nome, il gruppo muscolare principale e le serie.
class Exercise {
  final String id;
  final String name;
  final String muscleGroup;   // chiave da kMuscleGroups (es. 'pettorali')
  final List<ExerciseSet> sets;
  final String? notes;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.sets = const [],
    this.notes,
  });

  /// Volume totale dell'esercizio (somma di tutte le serie).
  int get totalVolume => sets.fold(0, (sum, s) => sum + s.volume);

  /// Numero di serie completate.
  int get completedSets => sets.where((s) => s.completed).length;

  /// True se tutte le serie sono completate.
  bool get isCompleted => sets.isNotEmpty && completedSets == sets.length;

  /// Peso massimo usato in questo esercizio.
  double get maxWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    List<ExerciseSet>? sets,
    String? notes,
  }) => Exercise(
    id:          id          ?? this.id,
    name:        name        ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    sets:        sets        ?? this.sets,
    notes:       notes       ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'name':        name,
    'muscleGroup': muscleGroup,
    'sets':        sets.map((s) => s.toJson()).toList(),
    'notes':       notes,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id:          json['id']          as String,
    name:        json['name']        as String,
    muscleGroup: json['muscleGroup'] as String,
    sets: (json['sets'] as List<dynamic>)
        .map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
        .toList(),
    notes: json['notes'] as String?,
  );
}

/// Catalogo esercizi predefiniti per nome → muscolo principale.
/// L'utente può sempre aggiungerne di custom.
const List<Map<String, String>> kDefaultExercises = [
  // Petto
  {'name': 'Panca Piana',          'muscle': 'pettorali'},
  {'name': 'Panca Inclinata',      'muscle': 'pettorali'},
  {'name': 'Croci ai Cavi',        'muscle': 'pettorali'},
  {'name': 'Push-up',              'muscle': 'pettorali'},
  // Spalle
  {'name': 'Shoulder Press',       'muscle': 'spalle'},
  {'name': 'Alzate Laterali',      'muscle': 'spalle'},
  {'name': 'Face Pull',            'muscle': 'spalle'},
  // Bicipiti
  {'name': 'Curl con Bilanciere',  'muscle': 'bicipiti'},
  {'name': 'Curl con Manubri',     'muscle': 'bicipiti'},
  {'name': 'Curl a Martello',      'muscle': 'bicipiti'},
  // Tricipiti
  {'name': 'Tricep Pushdown',      'muscle': 'tricipiti'},
  {'name': 'French Press',         'muscle': 'tricipiti'},
  {'name': 'Dips',                 'muscle': 'tricipiti'},
  // Dorsali
  {'name': 'Lat Machine',          'muscle': 'dorsali'},
  {'name': 'Rematore con Bilanciere', 'muscle': 'dorsali'},
  {'name': 'Pull-up',              'muscle': 'dorsali'},
  {'name': 'Cable Row',            'muscle': 'dorsali'},
  // Addominali
  {'name': 'Crunch',               'muscle': 'addominali'},
  {'name': 'Plank',                'muscle': 'addominali'},
  {'name': 'Leg Raise',            'muscle': 'addominali'},
  // Quadricipiti
  {'name': 'Squat',                'muscle': 'quadricipiti'},
  {'name': 'Leg Press',            'muscle': 'quadricipiti'},
  {'name': 'Leg Extension',        'muscle': 'quadricipiti'},
  // Femorali
  {'name': 'Romanian Deadlift',    'muscle': 'femorali'},
  {'name': 'Leg Curl',             'muscle': 'femorali'},
  // Glutei
  {'name': 'Hip Thrust',           'muscle': 'glutei'},
  {'name': 'Bulgarian Split Squat','muscle': 'glutei'},
  // Polpacci
  {'name': 'Calf Raise',           'muscle': 'polpacci'},
  // Full body
  {'name': 'Stacco da Terra',      'muscle': 'dorsali'},
  {'name': 'Trazioni',             'muscle': 'dorsali'},
];