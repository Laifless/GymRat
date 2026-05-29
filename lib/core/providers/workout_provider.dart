import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/workout_session.dart';
import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../constants/rank_constants.dart';

class WorkoutProvider extends ChangeNotifier {
  static const _historyKey = 'workout_history';
  static const _activeKey  = 'active_session';

  WorkoutSession? _active;        // sessione in corso
  List<WorkoutSession> _history = [];
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _loading = true;

  // ─── Getters ───────────────────────────────────────────
  WorkoutSession? get active    => _active;
  bool get hasActive            => _active != null;
  List<WorkoutSession> get history => List.unmodifiable(_history);
  Duration get elapsed          => _elapsed;
  bool get loading              => _loading;

  /// Ultima sessione completata.
  WorkoutSession? get lastSession =>
      _history.isEmpty ? null : _history.first;

  /// Volume totale su tutte le sessioni storiche per muscolo.
  Map<String, int> get historicVolumeByMuscle {
    final map = <String, int>{};
    for (final session in _history) {
      session.volumeByMuscle.forEach((muscle, vol) {
        map[muscle] = (map[muscle] ?? 0) + vol;
      });
    }
    return map;
  }

  // ─── Init ──────────────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Storico sessioni
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final raw = jsonDecode(historyJson) as List<dynamic>;
      _history = raw
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Sessione attiva (crash recovery)
    final activeJson = prefs.getString(_activeKey);
    if (activeJson != null) {
      _active = WorkoutSession.fromJson(
        jsonDecode(activeJson) as Map<String, dynamic>,
      );
      _startTimer();
    }

    _loading = false;
    notifyListeners();
  }

  // ─── Gestione sessione ─────────────────────────────────

  /// Avvia una nuova sessione.
  Future<void> startSession(String name) async {
    _active  = WorkoutSession.start(name);
    _elapsed = Duration.zero;
    _startTimer();
    await _saveActive();
    notifyListeners();
  }

  /// Aggiunge un esercizio alla sessione attiva.
  void addExercise(Exercise exercise) {
    if (_active == null) return;
    _active = _active!.copyWith(
      exercises: [..._active!.exercises, exercise],
    );
    _saveActive();
    notifyListeners();
  }

  /// Aggiunge una serie a un esercizio esistente.
  void addSet(String exerciseId, ExerciseSet set) {
    if (_active == null) return;
    final exercises = _active!.exercises.map((e) {
      if (e.id != exerciseId) return e;
      return e.copyWith(sets: [...e.sets, set]);
    }).toList();
    _active = _active!.copyWith(exercises: exercises);
    _saveActive();
    notifyListeners();
  }

  /// Rimuove una serie da un esercizio.
  void removeSet(String exerciseId, int setIndex) {
    if (_active == null) return;
    final exercises = _active!.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final newSets = List<ExerciseSet>.from(e.sets)..removeAt(setIndex);
      return e.copyWith(sets: newSets);
    }).toList();
    _active = _active!.copyWith(exercises: exercises);
    _saveActive();
    notifyListeners();
  }

  /// Segna una serie come completata/non completata.
  void toggleSet(String exerciseId, int setIndex) {
    if (_active == null) return;
    final exercises = _active!.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final newSets = List<ExerciseSet>.from(e.sets);
      newSets[setIndex] = newSets[setIndex].copyWith(
        completed: !newSets[setIndex].completed,
      );
      return e.copyWith(sets: newSets);
    }).toList();
    _active = _active!.copyWith(exercises: exercises);
    _saveActive();
    notifyListeners();
  }

  /// Rimuove un esercizio dalla sessione attiva.
  void removeExercise(String exerciseId) {
    if (_active == null) return;
    _active = _active!.copyWith(
      exercises: _active!.exercises.where((e) => e.id != exerciseId).toList(),
    );
    _saveActive();
    notifyListeners();
  }

  /// Completa la sessione e restituisce la sessione finita
  /// (con XP calcolato) da passare a [HunterProvider].
  Future<WorkoutSession> finishSession() async {
    if (_active == null) throw StateError('Nessuna sessione attiva');

    _timer?.cancel();
    _timer = null;

    final finished = _active!.copyWith(
      endTime:  DateTime.now(),
      xpGained: calculateSessionXp(_active!.totalVolume),
    );

    _history = [finished, ..._history];
    _active  = null;
    _elapsed = Duration.zero;

    await _saveHistory();
    await _clearActive();
    notifyListeners();

    return finished;
  }

  /// Annulla la sessione senza salvarla.
  Future<void> cancelSession() async {
    _timer?.cancel();
    _timer  = null;
    _active = null;
    _elapsed = Duration.zero;
    await _clearActive();
    notifyListeners();
  }

  // ─── Timer ─────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    final start = _active?.startTime ?? DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(start);
      notifyListeners();
    });
  }

  String get elapsedFormatted {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ─── Persistenza ───────────────────────────────────────
  Future<void> _saveActive() async {
    if (_active == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, jsonEncode(_active!.toJson()));
  }

  Future<void> _clearActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(_history.map((s) => s.toJson()).toList()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}