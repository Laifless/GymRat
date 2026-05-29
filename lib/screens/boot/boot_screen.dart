import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/hunter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_themes.dart';
import '../auth_provider.dart';
import '../main_shell.dart';
import '../login/login.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  final List<String> _lines = [];
  bool _showTitle = false;
  bool _showEnter = false;
  bool _navigating = false;

  static const Map<GymTheme, List<String>> _sequences = {
    GymTheme.rpg: [
      '> initializing hunter system...',
      '> loading dungeon archive...',
      '> calibrating mana flow...',
      '> syncing rank database...',
      '> SYSTEM ONLINE',
    ],
    GymTheme.military: [
      '> booting tactical OS...',
      '> loading mission protocols...',
      '> syncing field data...',
      '> authenticating operator...',
      '> SYSTEM READY',
    ],
    GymTheme.minimal: [
      '> loading profile...',
      '> syncing workouts...',
      '> preparing dashboard...',
      '> READY',
    ],
    GymTheme.medieval: [
      '> apertura pergamene antiche...',
      '> invocazione degli spiriti...',
      '> lettura delle rune...',
      '> il regno ti attende...',
      '> BENVENUTO, GUERRIERO',
    ],
  };

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  Future<void> _runSequence() async {
    final theme    = context.read<ThemeProvider>().current;
    final sequence = _sequences[theme] ?? _sequences[GymTheme.rpg]!;

    await Future.delayed(const Duration(milliseconds: 300));

    for (final line in sequence) {
      await Future.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => _lines.add(line));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showTitle = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _showEnter = true);
  }

  void _enter() {
    if (_navigating || !_showEnter) return;
    _navigating = true;

    final auth = context.read<AuthProvider>();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            auth.isAuth ? const MainShell() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors     = themeProvider.colors;
    final isMedieval = themeProvider.current == GymTheme.medieval;

    final fontStyle = isMedieval
        ? GoogleFonts.cinzel(
            fontSize: 11, color: colors.textSecondary, letterSpacing: 1,
          )
        : GoogleFonts.sourceCodePro(
            fontSize: 11, color: colors.textSecondary, letterSpacing: 0.5,
          );

    return GestureDetector(
      onTap: _enter,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Linee terminale ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _lines.map((line) {
                      final isOnline = line.contains('ONLINE') ||
                          line.contains('READY') ||
                          line.contains('GUERRIERO');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          line,
                          style: fontStyle.copyWith(
                            color: isOnline
                                ? colors.accent
                                : colors.textSecondary,
                            fontWeight: isOnline
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: isOnline ? 13 : 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 48),

                // ── Titolo ──
                AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedSlide(
                    offset: _showTitle ? Offset.zero : const Offset(0, 0.1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE',
                          style: isMedieval
                              ? GoogleFonts.cinzel(
                                  fontSize: 14, color: colors.textSecondary,
                                  letterSpacing: 6, fontWeight: FontWeight.w400,
                                )
                              : GoogleFonts.rajdhani(
                                  fontSize: 14, color: colors.textSecondary,
                                  letterSpacing: 6, fontWeight: FontWeight.w400,
                                ),
                        ),
                        Text(
                          'BIG GYM',
                          style: isMedieval
                              ? GoogleFonts.cinzel(
                                  fontSize: 52, color: colors.accent,
                                  letterSpacing: 2, fontWeight: FontWeight.w700,
                                  height: 1,
                                )
                              : GoogleFonts.rajdhani(
                                  fontSize: 58, color: colors.accent,
                                  letterSpacing: 4, fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // ── Tap to enter ──
                AnimatedOpacity(
                  opacity: _showEnter ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => Text(
                      isMedieval
                          ? '[ tocca per entrare nel regno ]'
                          : '[ tap to enter ]',
                      style: fontStyle.copyWith(
                        color: colors.textSecondary
                            .withOpacity(_glow.value * 0.8),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}