import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/hunter_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hunter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider   = context.watch<ThemeProvider>();
    final hunterProvider  = context.watch<HunterProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final colors = themeProvider.colors;
    final theme  = themeProvider.current;
    final hunter = hunterProvider.hunter;

    if (hunterProvider.loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: colors.background,
            expandedHeight: 0,
            pinned: true,
            title: _sectionLabel(theme == GymTheme.rpg      ? 'HUNTER'
                               : theme == GymTheme.military ? 'OPERATIVO'
                               : theme == GymTheme.medieval ? 'GUERRIERO'
                               : 'PROFILO', colors),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _iconButton(
                  icon: Icons.notifications_none_rounded,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Hero Card ──
                _HeroCard(hunter: hunter, colors: colors, theme: theme),
                const SizedBox(height: 12),

                // ── Se c'è sessione attiva ──
                if (workoutProvider.hasActive) ...[
                  _ActiveSessionBanner(
                    provider: workoutProvider,
                    colors: colors,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Prossimo rank ──
                _sectionLabel(_nextRankLabel(theme), colors),
                const SizedBox(height: 8),
                _NextRankRow(hunter: hunter, colors: colors),
                const SizedBox(height: 20),

                // ── Ultima sessione ──
                _sectionLabel(_lastSessionLabel(theme), colors),
                const SizedBox(height: 8),
                _LastSessionRow(
                  session: workoutProvider.lastSession,
                  colors: colors,
                ),
                const SizedBox(height: 20),

                // ── Statistiche veloci ──
                _sectionLabel('STATISTICHE', colors),
                const SizedBox(height: 8),
                _StatsGrid(
                  hunter: hunter,
                  totalVolume: hunterProvider.totalVolume,
                  colors: colors,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Hunter hunter;
  final ThemeColors colors;
  final GymTheme theme;

  const _HeroCard({
    required this.hunter,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final rank     = hunter.rank;
    final progress = hunter.rankProgress;
    final xpToNext = hunter.xpToNext;
    final isMedieval = theme == GymTheme.medieval;

    return Container(
      decoration: BoxDecoration(
        color: colors.glass,
        border: Border.all(color: colors.glassBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Glow sfondo
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accentGlow,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accentGlow,
                  border: Border.all(color: colors.accent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 11, color: colors.accent),
                    const SizedBox(width: 5),
                    Text(
                      rank.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Nome
              Text(
                hunter.name,
                style: isMedieval
                    ? GoogleFonts.cinzel(
                        fontSize: 28, fontWeight: FontWeight.w600,
                        color: colors.textPrimary, height: 1.1,
                      )
                    : GoogleFonts.rajdhani(
                        fontSize: 32, fontWeight: FontWeight.w600,
                        color: colors.textPrimary, height: 1.1,
                      ),
              ),
              Text(
                '${_hunterTitle(theme)} · ${hunter.totalSessions} ${_sessionsLabel(theme)}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 16),

              // XP bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('XP', style: TextStyle(fontSize: 10, color: colors.textSecondary, letterSpacing: 1)),
                  Text(
                    xpToNext != null
                        ? '${hunter.totalXp.toStringAsFixed(0)} / ${(hunter.totalXp + xpToNext).toStringAsFixed(0)}'
                        : 'MAX',
                    style: TextStyle(fontSize: 10, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: colors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(colors.accent),
                ),
              ),
              const SizedBox(height: 16),

              // Trio stats
              Row(
                children: [
                  _TrioItem(value: '${hunter.totalSessions}', label: _sessionsLabel(theme).toUpperCase(), colors: colors),
                  _TrioDivider(colors: colors),
                  _TrioItem(value: '${hunter.currentStreak}🔥', label: 'STREAK', colors: colors),
                  _TrioDivider(colors: colors),
                  _TrioItem(value: '${hunter.totalXp}', label: 'XP TOTALI', colors: colors),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrioItem extends StatelessWidget {
  final String value, label;
  final ThemeColors colors;
  const _TrioItem({required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: colors.textSecondary, letterSpacing: 1)),
      ],
    ),
  );
}

class _TrioDivider extends StatelessWidget {
  final ThemeColors colors;
  const _TrioDivider({required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 28,
    color: colors.glassBorder,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE SESSION BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveSessionBanner extends StatelessWidget {
  final WorkoutProvider provider;
  final ThemeColors colors;
  final GymTheme theme;
  const _ActiveSessionBanner({required this.provider, required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Torna alla tab workout (index 1)
        // Gestito dal MainShell via callback — per ora naviga
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.accentGlow,
          border: Border.all(color: colors.accent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 8, color: colors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${provider.active?.name ?? "Sessione"} in corso · ${provider.elapsedFormatted}',
                style: TextStyle(fontSize: 12, color: colors.accent, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.accent),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEXT RANK ROW
// ─────────────────────────────────────────────────────────────────────────────
class _NextRankRow extends StatelessWidget {
  final Hunter hunter;
  final ThemeColors colors;
  const _NextRankRow({required this.hunter, required this.colors});

  @override
  Widget build(BuildContext context) {
    final xpToNext = hunter.xpToNext;
    if (xpToNext == null) {
      return _GlassRow(
        icon: Icons.emoji_events_outlined,
        title: 'Rank massimo raggiunto',
        subtitle: 'Sei un SSS Hunter',
        colors: colors,
        trailing: _TierTag(label: 'SSS', color: Colors.white, colors: colors),
      );
    }

    final nextRankIndex = hunter.rank.xpRequired < 1000000
        ? hunter.rank.xpRequired
        : null;

    return _GlassRow(
      icon: Icons.emoji_events,
      title: 'Prossimo rank: ${hunter.rank.label}',
      subtitle: '$xpToNext XP mancanti',
      colors: colors,
      trailing: _TierTag(
        label: hunter.rank.label.toUpperCase(),
        color: hunter.rank.color,
        colors: colors,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAST SESSION ROW
// ─────────────────────────────────────────────────────────────────────────────
class _LastSessionRow extends StatelessWidget {
  final dynamic session;
  final ThemeColors colors;
  const _LastSessionRow({required this.session, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return _GlassRow(
        icon: Icons.fitness_center,
        title: 'Nessuna sessione ancora',
        subtitle: 'Inizia il tuo primo allenamento',
        colors: colors,
      );
    }

    final duration = session.duration as Duration;
    final minutes  = duration.inMinutes;

    return _GlassRow(
      icon: Icons.fitness_center,
      title: session.name as String,
      subtitle: '${minutes}min · +${session.xpGained} XP · ${session.totalVolume} kg',
      colors: colors,
      trailing: _TierTag(
        label: '+${session.xpGained} XP',
        color: colors.accent,
        colors: colors,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS GRID
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final Hunter hunter;
  final int totalVolume;
  final ThemeColors colors;
  const _StatsGrid({required this.hunter, required this.totalVolume, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _StatCard(value: '${hunter.totalSessions}', label: 'Sessioni totali', colors: colors),
        _StatCard(value: '${hunter.currentStreak}', label: 'Streak giorni', colors: colors),
        _StatCard(value: '${(totalVolume / 1000).toStringAsFixed(1)}t', label: 'Volume totale', colors: colors),
        _StatCard(value: '${hunter.bestStreak}', label: 'Streak record', colors: colors),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final ThemeColors colors;
  const _StatCard({required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: colors.glass,
      border: Border.all(color: colors.glassBorder),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: colors.accentLight)),
        Text(label, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _GlassRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final ThemeColors colors;
  final Widget? trailing;

  const _GlassRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: colors.glass,
      border: Border.all(color: colors.glassBorder),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class _TierTag extends StatelessWidget {
  final String label;
  final Color color;
  final ThemeColors colors;
  const _TierTag({required this.label, required this.color, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      border: Border.all(color: color.withOpacity(0.6)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 9, color: color, letterSpacing: 1, fontWeight: FontWeight.w600),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS TESTO PER TEMA
// ─────────────────────────────────────────────────────────────────────────────
Widget _sectionLabel(String text, ThemeColors colors) => Padding(
  padding: const EdgeInsets.only(bottom: 0),
  child: Text(
    text,
    style: TextStyle(fontSize: 9, color: colors.textTertiary, letterSpacing: 2, fontWeight: FontWeight.w600),
  ),
);

Widget _iconButton({required IconData icon, required Color color}) =>
    Icon(icon, color: color, size: 22);

String _hunterTitle(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Dungeon Hunter',
  GymTheme.military => 'Soldato d\'élite',
  GymTheme.minimal  => 'Atleta',
  GymTheme.medieval => 'Cavaliere',
};

String _sessionsLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'sessioni',
  GymTheme.military => 'missioni',
  GymTheme.minimal  => 'allenamenti',
  GymTheme.medieval => 'battaglie',
};

String _nextRankLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'PROSSIMO RANK',
  GymTheme.military => 'PROSSIMA PROMOZIONE',
  GymTheme.minimal  => 'OBIETTIVO SUCCESSIVO',
  GymTheme.medieval => 'PROSSIMA ASCESA',
};

String _lastSessionLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'ULTIMA SESSIONE',
  GymTheme.military => 'ULTIMA MISSIONE',
  GymTheme.minimal  => 'ULTIMO ALLENAMENTO',
  GymTheme.medieval => 'ULTIMA BATTAGLIA',
};