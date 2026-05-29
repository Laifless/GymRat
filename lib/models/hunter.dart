import '../core/constants/rank_constants.dart' as rank_constants;

/// Profilo del hunter (utente).
/// Persiste su SharedPreferences tramite [HunterProvider].
class Hunter {
  final String name;
  final int totalXp;
  final int totalSessions;
  final int currentStreak;    // giorni consecutivi di allenamento
  final int bestStreak;
  final DateTime? lastSessionDate;

  const Hunter({
    required this.name,
    this.totalXp = 0,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastSessionDate,
  });

  // ─── Rank derivato dall'XP ─────────────────────────────
  rank_constants.RankInfo get rank => rank_constants.getRankFromXp(totalXp);
  double get rankProgress => rank_constants.rankProgress(totalXp);
  int? get xpToNext => rank_constants.xpToNextRank(totalXp);

  // ─── Volume totale (kg) — calcolato dai workout ────────
  // Viene passato dal WorkoutProvider, non salvato qui.

  // ─── Serializzazione ───────────────────────────────────
  Map<String, dynamic> toJson() => {
    'name':            name,
    'totalXp':         totalXp,
    'totalSessions':   totalSessions,
    'currentStreak':   currentStreak,
    'bestStreak':      bestStreak,
    'lastSessionDate': lastSessionDate?.toIso8601String(),
  };

  factory Hunter.fromJson(Map<String, dynamic> json) => Hunter(
    name:            json['name'] as String? ?? 'Hunter',
    totalXp:         json['totalXp'] as int? ?? 0,
    totalSessions:   json['totalSessions'] as int? ?? 0,
    currentStreak:   json['currentStreak'] as int? ?? 0,
    bestStreak:      json['bestStreak'] as int? ?? 0,
    lastSessionDate: json['lastSessionDate'] != null
        ? DateTime.tryParse(json['lastSessionDate'] as String)
        : null,
  );

  Hunter copyWith({
    String? name,
    int? totalXp,
    int? totalSessions,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastSessionDate,
  }) => Hunter(
    name:            name            ?? this.name,
    totalXp:         totalXp         ?? this.totalXp,
    totalSessions:   totalSessions   ?? this.totalSessions,
    currentStreak:   currentStreak   ?? this.currentStreak,
    bestStreak:      bestStreak      ?? this.bestStreak,
    lastSessionDate: lastSessionDate ?? this.lastSessionDate,
  );

  /// Hunter di default per il primo avvio.
  static const initial = Hunter(name: 'Hunter');
}