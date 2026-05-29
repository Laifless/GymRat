import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/hunter_provider.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider  = context.watch<ThemeProvider>();
    final hunterProvider = context.watch<HunterProvider>();
    final colors = themeProvider.colors;
    final theme  = themeProvider.current;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Titolo ──
                Text(
                  _screenTitle(theme),
                  style: TextStyle(
                    fontSize: 9, color: colors.textTertiary,
                    letterSpacing: 2, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Nome hunter ──
                _SectionLabel(label: _profileLabel(theme), colors: colors),
                const SizedBox(height: 8),
                _NameCard(
                  name: hunterProvider.hunter.name,
                  colors: colors,
                  theme: theme,
                  onSave: (name) => hunterProvider.setName(name),
                ),
                const SizedBox(height: 24),

                // ── Tema ──
                _SectionLabel(label: _themeLabel(theme), colors: colors),
                const SizedBox(height: 8),
                _ThemePicker(
                  current: theme,
                  colors: colors,
                  onSelect: (t) => themeProvider.setTheme(t),
                ),
                const SizedBox(height: 24),

                // ── Stats hunter ──
                _SectionLabel(label: 'STATISTICHE', colors: colors),
                const SizedBox(height: 8),
                _StatsCard(
                  hunter: hunterProvider.hunter,
                  totalVolume: hunterProvider.totalVolume,
                  colors: colors,
                ),
                const SizedBox(height: 24),

                // ── Danger zone ──
                _SectionLabel(label: 'ZONA PERICOLOSA', colors: colors),
                const SizedBox(height: 8),
                _DangerRow(
                  label: 'Reset completo',
                  sub: 'Cancella tutti i dati — irreversibile',
                  colors: colors,
                  onTap: () => _confirmReset(context, hunterProvider, colors),
                ),
                const SizedBox(height: 32),

                // ── Info app ──
                _AppInfo(colors: colors),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    HunterProvider hunter,
    ThemeColors colors,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset completo?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Tutti i dati verranno cancellati permanentemente.\nNon potrai annullare questa azione.',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              hunter.reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAME CARD
// ─────────────────────────────────────────────────────────────────────────────
class _NameCard extends StatefulWidget {
  final String name;
  final ThemeColors colors;
  final GymTheme theme;
  final ValueChanged<String> onSave;

  const _NameCard({
    required this.name,
    required this.colors,
    required this.theme,
    required this.onSave,
  });

  @override
  State<_NameCard> createState() => _NameCardState();
}

class _NameCardState extends State<_NameCard> {
  late TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.glass,
        border: Border.all(color: c.glassBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: c.accentGlow,
              shape: BoxShape.circle,
              border: Border.all(color: c.accent, width: 1),
            ),
            child: Center(
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'H',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: c.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nome (editing o statico)
          Expanded(
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    autofocus: true,
                    style: TextStyle(color: c.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _namePlaceholder(widget.theme),
                      hintStyle: TextStyle(color: c.textSecondary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _save(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500,
                          color: c.textPrimary,
                        ),
                      ),
                      Text(
                        _roleLabel(widget.theme),
                        style: TextStyle(fontSize: 11, color: c.textSecondary),
                      ),
                    ],
                  ),
          ),

          // Edit / Save button
          GestureDetector(
            onTap: _editing ? _save : () => setState(() => _editing = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _editing ? c.accent : c.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _editing ? 'Salva' : 'Modifica',
                style: TextStyle(
                  fontSize: 11,
                  color: _editing ? c.background : c.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    widget.onSave(_ctrl.text);
    setState(() => _editing = false);
    HapticFeedback.lightImpact();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME PICKER
// ─────────────────────────────────────────────────────────────────────────────
class _ThemePicker extends StatelessWidget {
  final GymTheme current;
  final ThemeColors colors;
  final ValueChanged<GymTheme> onSelect;

  const _ThemePicker({
    required this.current,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: GymTheme.values.map((t) {
        final isSelected = t == current;
        final info = _themeInfo(t);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(t);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? colors.accentGlow : colors.glass,
              border: Border.all(
                color: isSelected ? colors.accent : colors.glassBorder,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Preview colore tema
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: info.previewBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: info.previewAccent.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(
                      info.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info tema
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: isSelected ? colors.accent : colors.textPrimary,
                        ),
                      ),
                      Text(
                        info.description,
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colors.accent : colors.textTertiary,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12, color: colors.background)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final dynamic hunter;
  final int totalVolume;
  final ThemeColors colors;

  const _StatsCard({
    required this.hunter,
    required this.totalVolume,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.glass,
        border: Border.all(color: colors.glassBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _StatRow(label: 'Sessioni totali',    value: '${hunter.totalSessions}',                               colors: colors),
          _Divider(colors: colors),
          _StatRow(label: 'XP totali',          value: '${hunter.totalXp}',                                     colors: colors),
          _Divider(colors: colors),
          _StatRow(label: 'Rank attuale',        value: hunter.rank.label,                                       colors: colors),
          _Divider(colors: colors),
          _StatRow(label: 'Streak attuale',      value: '${hunter.currentStreak} giorni',                        colors: colors),
          _Divider(colors: colors),
          _StatRow(label: 'Streak record',       value: '${hunter.bestStreak} giorni',                           colors: colors),
          _Divider(colors: colors),
          _StatRow(label: 'Volume totale',       value: '${(totalVolume / 1000).toStringAsFixed(1)} t',           colors: colors),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final ThemeColors colors;
  const _StatRow({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        Text(value,  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textPrimary)),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  final ThemeColors colors;
  const _Divider({required this.colors});

  @override
  Widget build(BuildContext context) => Divider(
    height: 1, thickness: 0.5, color: colors.glassBorder,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DANGER ROW
// ─────────────────────────────────────────────────────────────────────────────
class _DangerRow extends StatelessWidget {
  final String label, sub;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _DangerRow({
    required this.label,
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
        color: Colors.red.withOpacity(0.05),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                Text(sub,   style: TextStyle(fontSize: 11, color: colors.textSecondary)),
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
// APP INFO
// ─────────────────────────────────────────────────────────────────────────────
class _AppInfo extends StatelessWidget {
  final ThemeColors colors;
  const _AppInfo({required this.colors});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'THE BIG GYM',
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: colors.textTertiary, letterSpacing: 3,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'v1.0.0 · open source',
        style: TextStyle(fontSize: 10, color: colors.textTertiary),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeColors colors;
  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 9, color: colors.textTertiary,
      letterSpacing: 2, fontWeight: FontWeight.w600,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME INFO MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeInfo {
  final String name, description, emoji;
  final Color previewBg, previewAccent;

  const _ThemeInfo({
    required this.name,
    required this.description,
    required this.emoji,
    required this.previewBg,
    required this.previewAccent,
  });
}

_ThemeInfo _themeInfo(GymTheme t) => switch (t) {
  GymTheme.rpg => const _ThemeInfo(
    name:         'Solo Leveling',
    description:  'Dark · Oro · Stile RPG',
    emoji:        '⚔️',
    previewBg:    Color(0xFF0B0B0F),
    previewAccent: Color(0xFFC9A84C),
  ),
  GymTheme.military => const _ThemeInfo(
    name:         'Militare',
    description:  'Verde oliva · Tattico · Missioni',
    emoji:        '🎖️',
    previewBg:    Color(0xFF080C05),
    previewAccent: Color(0xFF6AAA2A),
  ),
  GymTheme.minimal => const _ThemeInfo(
    name:         'Minimal',
    description:  'Light mode · Pulito · Essenziale',
    emoji:        '◻️',
    previewBg:    Color(0xFFF5F4F0),
    previewAccent: Color(0xFF1A1A1A),
  ),
  GymTheme.medieval => const _ThemeInfo(
    name:         'Medievale',
    description:  'Pergamena · Rune · Gloria',
    emoji:        '🏰',
    previewBg:    Color(0xFF1A1208),
    previewAccent: Color(0xFFD4A843),
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS TESTO PER TEMA
// ─────────────────────────────────────────────────────────────────────────────
String _screenTitle(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'SETUP',
  GymTheme.military => 'CONFIGURAZIONE',
  GymTheme.minimal  => 'IMPOSTAZIONI',
  GymTheme.medieval => 'PERGAMENA',
};

String _profileLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'PROFILO HUNTER',
  GymTheme.military => 'IDENTITÀ OPERATORE',
  GymTheme.minimal  => 'PROFILO',
  GymTheme.medieval => 'IDENTITÀ DEL GUERRIERO',
};

String _themeLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'TEMA VISIVO',
  GymTheme.military => 'SKIN OPERATIVA',
  GymTheme.minimal  => 'ASPETTO',
  GymTheme.medieval => 'STILE DEL REGNO',
};

String _namePlaceholder(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Nome del tuo Hunter...',
  GymTheme.military => 'Callsign operatore...',
  GymTheme.minimal  => 'Il tuo nome...',
  GymTheme.medieval => 'Nome del guerriero...',
};

String _roleLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Dungeon Hunter',
  GymTheme.military => 'Operatore d\'élite',
  GymTheme.minimal  => 'Atleta',
  GymTheme.medieval => 'Cavaliere del Regno',
};