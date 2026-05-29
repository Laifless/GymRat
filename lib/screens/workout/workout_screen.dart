import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/hunter_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/rank_constants.dart';
import '../../models/exercise.dart';
import '../../models/exercise_set.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final colors  = context.watch<ThemeProvider>().colors;
    final theme   = context.watch<ThemeProvider>().current;

    if (!workout.hasActive) {
      return _NoSessionView(colors: colors, theme: theme);
    }
    return _ActiveSessionView(colors: colors, theme: theme);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NO SESSION VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _NoSessionView extends StatelessWidget {
  final ThemeColors colors;
  final GymTheme theme;

  const _NoSessionView({required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                _screenTitle(theme),
                style: TextStyle(
                  fontSize: 9, color: colors.textTertiary,
                  letterSpacing: 2, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Start button
              GestureDetector(
                onTap: () => _showStartDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.glass,
                    border: Border.all(color: colors.accent),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: colors.accentGlow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: colors.accent, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _startLabel(theme),
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startSub(theme),
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                _quickStartLabel(theme),
                style: TextStyle(
                  fontSize: 9, color: colors.textTertiary,
                  letterSpacing: 2, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Quick start schede
              ..._quickTemplates(theme).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _QuickStartRow(
                  name: t['name']!,
                  sub: t['sub']!,
                  colors: colors,
                  onTap: () => _startSession(context, t['name']!),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final colors = context.read<ThemeProvider>().colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sessionNameLabel(context.read<ThemeProvider>().current),
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: _sessionNameHint(context.read<ThemeProvider>().current),
                hintStyle: TextStyle(color: colors.textSecondary),
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) {
                Navigator.pop(context);
                _startSession(context, v.trim().isEmpty ? 'Allenamento' : v.trim());
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final name = ctrl.text.trim();
                  _startSession(context, name.isEmpty ? 'Allenamento' : name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(_startBtnLabel(context.read<ThemeProvider>().current)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession(BuildContext context, String name) {
    context.read<WorkoutProvider>().startSession(name);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE SESSION VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveSessionView extends StatelessWidget {
  final ThemeColors colors;
  final GymTheme theme;

  const _ActiveSessionView({required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final session = workout.active!;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Timer Hero ──
          SliverToBoxAdapter(
            child: _TimerHero(
              workout: workout,
              colors: colors,
              theme: theme,
            ),
          ),

          // ── Esercizi ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i == session.exercises.length) {
                    return _AddExerciseButton(colors: colors, theme: theme);
                  }
                  return _ExerciseCard(
                    exercise: session.exercises[i],
                    colors: colors,
                    theme: theme,
                  );
                },
                childCount: session.exercises.length + 1,
              ),
            ),
          ),

          // ── Fine sessione ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverToBoxAdapter(
              child: _FinishButton(colors: colors, theme: theme),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMER HERO
// ─────────────────────────────────────────────────────────────────────────────
class _TimerHero extends StatelessWidget {
  final WorkoutProvider workout;
  final ThemeColors colors;
  final GymTheme theme;

  const _TimerHero({
    required this.workout,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final session = workout.active!;
    final isMedieval = theme == GymTheme.medieval;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.glass,
        border: Border.all(color: colors.glassBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Glow
          Positioned(
            bottom: -20, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 160, height: 60,
                decoration: BoxDecoration(
                  color: colors.accentGlow,
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Nome sessione
              Text(
                session.name,
                style: TextStyle(fontSize: 12, color: colors.textSecondary, letterSpacing: 1),
              ),
              const SizedBox(height: 4),

              // Timer
              Text(
                workout.elapsedFormatted,
                style: isMedieval
                    ? GoogleFonts.cinzel(
                        fontSize: 44, fontWeight: FontWeight.w600,
                        color: colors.textPrimary, letterSpacing: 2,
                      )
                    : GoogleFonts.rajdhani(
                        fontSize: 50, fontWeight: FontWeight.w600,
                        color: colors.textPrimary, letterSpacing: 3,
                      ),
              ),
              const SizedBox(height: 16),

              // Stats riga
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TimerStat(
                    value: '${session.totalVolume}',
                    label: 'KG TOTALI',
                    colors: colors,
                  ),
                  _TimerStat(
                    value: '${session.exercises.length}',
                    label: _exercisesLabel(theme),
                    colors: colors,
                  ),
                  _TimerStat(
                    value: '+${calculateSessionXp(session.totalVolume)}',
                    label: 'XP',
                    colors: colors,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerStat extends StatelessWidget {
  final String value, label;
  final ThemeColors colors;
  const _TimerStat({required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.accentLight)),
      Text(label, style: TextStyle(fontSize: 9, color: colors.textSecondary, letterSpacing: 1)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final ThemeColors colors;
  final GymTheme theme;

  const _ExerciseCard({
    required this.exercise,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final workout = context.read<WorkoutProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.glass,
        border: Border.all(color: colors.glassBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header esercizio
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.fitness_center, size: 16, color: colors.accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup,
                        style: TextStyle(fontSize: 10, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Tier tag
                _TierTag(
                  tier: getTierFromVolume(exercise.totalVolume),
                  colors: colors,
                ),
                const SizedBox(width: 8),
                // Elimina esercizio
                GestureDetector(
                  onTap: () => workout.removeExercise(exercise.id),
                  child: Icon(Icons.close, size: 16, color: colors.textTertiary),
                ),
              ],
            ),
          ),

          // Header colonne serie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                SizedBox(width: 28, child: Text('SET', style: _colStyle(colors))),
                Expanded(child: Text('KG', style: _colStyle(colors), textAlign: TextAlign.center)),
                Expanded(child: Text('REPS', style: _colStyle(colors), textAlign: TextAlign.center)),
                SizedBox(width: 36, child: Text('✓', style: _colStyle(colors), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Serie
          ...exercise.sets.asMap().entries.map((entry) => _SetRow(
            index: entry.key,
            set: entry.value,
            exerciseId: exercise.id,
            colors: colors,
          )),

          // Aggiungi serie
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: GestureDetector(
              onTap: () => _addSet(context, exercise),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colors.accentGlow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+ Aggiungi serie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, color: colors.accent,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSet(BuildContext context, Exercise exercise) {
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.read<ThemeProvider>().colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddSetSheet(
        exerciseId: exercise.id,
        lastSet: lastSet,
        colors: context.read<ThemeProvider>().colors,
      ),
    );
  }

  TextStyle _colStyle(ThemeColors c) => TextStyle(
    fontSize: 9, color: c.textTertiary, letterSpacing: 1.5, fontWeight: FontWeight.w600,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SET ROW
// ─────────────────────────────────────────────────────────────────────────────
class _SetRow extends StatelessWidget {
  final int index;
  final ExerciseSet set;
  final String exerciseId;
  final ThemeColors colors;

  const _SetRow({
    required this.index,
    required this.set,
    required this.exerciseId,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final workout = context.read<WorkoutProvider>();

    return GestureDetector(
      onLongPress: () => workout.removeSet(exerciseId, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: BoxDecoration(
          color: set.completed ? colors.accentGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
            Expanded(
              child: Text(
                '${set.weightKg % 1 == 0 ? set.weightKg.toInt() : set.weightKg}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: set.completed ? colors.accent : colors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${set.reps}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: set.completed ? colors.accent : colors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  workout.toggleSet(exerciseId, index);
                },
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: set.completed ? colors.accent : Colors.transparent,
                      border: Border.all(
                        color: set.completed ? colors.accent : colors.textTertiary,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: set.completed
                        ? Icon(Icons.check, size: 14, color: colors.background)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD SET SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _AddSetSheet extends StatefulWidget {
  final String exerciseId;
  final ExerciseSet? lastSet;
  final ThemeColors colors;

  const _AddSetSheet({
    required this.exerciseId,
    required this.lastSet,
    required this.colors,
  });

  @override
  State<_AddSetSheet> createState() => _AddSetSheetState();
}

class _AddSetSheetState extends State<_AddSetSheet> {
  late double _weight;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _weight = widget.lastSet?.weightKg ?? 20;
    _reps   = widget.lastSet?.reps ?? 10;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nuova serie',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: c.textPrimary),
          ),
          const SizedBox(height: 24),

          // Peso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Peso (kg)', style: TextStyle(fontSize: 13, color: c.textSecondary)),
              Row(
                children: [
                  _StepButton(icon: Icons.remove, color: c, onTap: () => setState(() => _weight = (_weight - 2.5).clamp(0, 500))),
                  const SizedBox(width: 12),
                  Text(
                    _weight % 1 == 0 ? '${_weight.toInt()}' : '$_weight',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: c.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  _StepButton(icon: Icons.add, color: c, onTap: () => setState(() => _weight = (_weight + 2.5).clamp(0, 500))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ripetizioni', style: TextStyle(fontSize: 13, color: c.textSecondary)),
              Row(
                children: [
                  _StepButton(icon: Icons.remove, color: c, onTap: () => setState(() => _reps = (_reps - 1).clamp(1, 100))),
                  const SizedBox(width: 12),
                  Text('$_reps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: c.textPrimary)),
                  const SizedBox(width: 12),
                  _StepButton(icon: Icons.add, color: c, onTap: () => setState(() => _reps = (_reps + 1).clamp(1, 100))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<WorkoutProvider>().addSet(
                  widget.exerciseId,
                  ExerciseSet(reps: _reps, weightKg: _weight),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: c.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Aggiungi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final ThemeColors color;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: color.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color.textPrimary),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD EXERCISE BUTTON + PICKER
// ─────────────────────────────────────────────────────────────────────────────
class _AddExerciseButton extends StatelessWidget {
  final ThemeColors colors;
  final GymTheme theme;
  const _AddExerciseButton({required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: context.read<ThemeProvider>().colors.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _ExercisePicker(colors: colors),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors.accentGlow,
          border: Border.all(color: colors.accent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '+ ${_addExerciseLabel(theme)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12, color: colors.accent,
            fontWeight: FontWeight.w500, letterSpacing: 1,
          ),
        ),
      ),
    ),
  );
}

class _ExercisePicker extends StatefulWidget {
  final ThemeColors colors;
  const _ExercisePicker({required this.colors});

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final filtered = kDefaultExercises
        .where((e) => e['name']!.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: c.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cerca esercizio...',
                hintStyle: TextStyle(color: c.textSecondary),
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
                filled: true,
                fillColor: c.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: filtered.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, i) {
                final ex = filtered[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.fitness_center, size: 16, color: c.accent),
                  ),
                  title: Text(ex['name']!, style: TextStyle(fontSize: 13, color: c.textPrimary)),
                  subtitle: Text(ex['muscle']!, style: TextStyle(fontSize: 11, color: c.textSecondary)),
                  onTap: () {
                    context.read<WorkoutProvider>().addExercise(
                      Exercise(
                        id: '${ex['name']}_${DateTime.now().millisecondsSinceEpoch}',
                        name: ex['name']!,
                        muscleGroup: ex['muscle']!,
                      ),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FINISH BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _FinishButton extends StatelessWidget {
  final ThemeColors colors;
  final GymTheme theme;
  const _FinishButton({required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _confirmFinish(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _finishLabel(theme),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => _confirmCancel(context),
        child: Text(
          'Annulla sessione',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ),
    ],
  );

  void _confirmFinish(BuildContext context) {
    final workout = context.read<WorkoutProvider>();
    final hunter  = context.read<HunterProvider>();
    final colors  = context.read<ThemeProvider>().colors;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_finishDialogTitle(theme), style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'Volume: ${workout.active?.totalVolume ?? 0} kg\nXP guadagnati: +${calculateSessionXp(workout.active?.totalVolume ?? 0)}',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continua', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final session = await workout.finishSession();
              await hunter.onSessionCompleted(
                xpGained: session.xpGained,
                volumeByMuscle: session.volumeByMuscle,
                sessionDate: session.endTime ?? DateTime.now(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_finishLabel(theme)),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Annullare la sessione?', style: TextStyle(color: colors.textPrimary)),
        content: Text('I dati non verranno salvati.', style: TextStyle(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WorkoutProvider>().cancelSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Annulla sessione'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK START ROW
// ─────────────────────────────────────────────────────────────────────────────
class _QuickStartRow extends StatelessWidget {
  final String name, sub;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _QuickStartRow({
    required this.name,
    required this.sub,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.glass,
        border: Border.all(color: colors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: colors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.bolt, size: 18, color: colors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                Text(sub, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TIER TAG
// ─────────────────────────────────────────────────────────────────────────────
class _TierTag extends StatelessWidget {
  final MuscleTierInfo tier;
  final ThemeColors colors;
  const _TierTag({required this.tier, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: tier.color.withOpacity(0.08),
      border: Border.all(color: tier.color.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      tier.label.toUpperCase(),
      style: TextStyle(fontSize: 9, color: tier.color, letterSpacing: 1, fontWeight: FontWeight.w600),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS TESTO PER TEMA
// ─────────────────────────────────────────────────────────────────────────────
String _screenTitle(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'DUNGEON',
  GymTheme.military => 'CAMPO DI BATTAGLIA',
  GymTheme.minimal  => 'ALLENAMENTO',
  GymTheme.medieval => 'BATTAGLIA',
};

String _startLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Entra nel Dungeon',
  GymTheme.military => 'Inizia la Missione',
  GymTheme.minimal  => 'Inizia allenamento',
  GymTheme.medieval => 'Parti per la Battaglia',
};

String _startSub(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Nuova sessione · guadagna XP',
  GymTheme.military => 'Nuova missione · ottieni punti esperienza',
  GymTheme.minimal  => 'Traccia i tuoi esercizi',
  GymTheme.medieval => 'Combatti · accumula gloria',
};

String _quickStartLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'SCHEDE RAPIDE',
  GymTheme.military => 'PROTOCOLLI RAPIDI',
  GymTheme.minimal  => 'PROGRAMMI SALVATI',
  GymTheme.medieval => 'PERGAMENE DI BATTAGLIA',
};

String _addExerciseLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Aggiungi esercizio',
  GymTheme.military => 'Aggiungi esercizio',
  GymTheme.minimal  => 'Aggiungi esercizio',
  GymTheme.medieval => 'Aggiungi movimento',
};

String _finishLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'COMPLETA SESSIONE',
  GymTheme.military => 'MISSIONE COMPLETATA',
  GymTheme.minimal  => 'Termina allenamento',
  GymTheme.medieval => 'VITTORIA',
};

String _finishDialogTitle(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Completare la sessione?',
  GymTheme.military => 'Chiudere la missione?',
  GymTheme.minimal  => 'Terminare l\'allenamento?',
  GymTheme.medieval => 'La battaglia è vinta?',
};

String _sessionNameLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Nome sessione',
  GymTheme.military => 'Nome missione',
  GymTheme.minimal  => 'Nome allenamento',
  GymTheme.medieval => 'Nome della battaglia',
};

String _sessionNameHint(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Push Day, Pull Day...',
  GymTheme.military => 'Operazione Alpha...',
  GymTheme.minimal  => 'Upper, Lower, Full Body...',
  GymTheme.medieval => 'Assalto al Castello...',
};

String _startBtnLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Inizia',
  GymTheme.military => 'Deploy',
  GymTheme.minimal  => 'Inizia',
  GymTheme.medieval => 'In battaglia',
};

String _exercisesLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'ESERCIZI',
  GymTheme.military => 'OBIETTIVI',
  GymTheme.minimal  => 'ESERCIZI',
  GymTheme.medieval => 'MOSSE',
};

List<Map<String, String>> _quickTemplates(GymTheme t) => switch (t) {
  GymTheme.rpg || GymTheme.minimal => [
    {'name': 'Push Day',  'sub': 'Petto · Spalle · Tricipiti'},
    {'name': 'Pull Day',  'sub': 'Schiena · Bicipiti'},
    {'name': 'Leg Day',   'sub': 'Quadricipiti · Femorali · Glutei'},
  ],
  GymTheme.military => [
    {'name': 'Operazione Push',  'sub': 'Petto · Spalle · Tricipiti'},
    {'name': 'Operazione Pull',  'sub': 'Schiena · Bicipiti'},
    {'name': 'Operazione Legs',  'sub': 'Quadricipiti · Femorali · Glutei'},
  ],
  GymTheme.medieval => [
    {'name': 'Assalto',    'sub': 'Petto · Spalle · Tricipiti'},
    {'name': 'Difesa',     'sub': 'Schiena · Bicipiti'},
    {'name': 'Cavalcata',  'sub': 'Quadricipiti · Femorali · Glutei'},
  ],
};