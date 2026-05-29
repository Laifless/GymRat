import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/hunter_provider.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/app_colors.dart';
import '../auth_provider.dart';
import '../sync_service.dart';
import '../main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final theme  = themeProvider.current;
    final auth   = context.read<AuthProvider>();
    final isMedieval = theme == GymTheme.medieval;

    // Pre-compila con il nome Google/Apple se disponibile
    if (_ctrl.text.isEmpty && auth.user?.displayName != null) {
      _ctrl.text = auth.user!.displayName!.split(' ').first;
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // ── Titolo ──
                  Text(
                    _welcomeTitle(theme),
                    style: TextStyle(
                      fontSize: 9, color: colors.textTertiary,
                      letterSpacing: 2, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _welcomeHeadline(theme),
                    style: isMedieval
                        ? GoogleFonts.cinzel(
                            fontSize: 32, fontWeight: FontWeight.w700,
                            color: colors.textPrimary, height: 1.2,
                          )
                        : GoogleFonts.rajdhani(
                            fontSize: 36, fontWeight: FontWeight.w700,
                            color: colors.textPrimary, height: 1.2,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _welcomeSub(theme),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),

                  const Spacer(),

                  // ── Avatar preview ──
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: colors.accentGlow,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.accent, width: 2),
                      ),
                      child: Center(
                        child: ValueListenableBuilder(
                          valueListenable: _ctrl,
                          builder: (_, value, __) => Text(
                            value.text.isNotEmpty
                                ? value.text[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w700,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Input nickname ──
                  Text(
                    _nicknameLabel(theme),
                    style: TextStyle(
                      fontSize: 9, color: colors.textTertiary,
                      letterSpacing: 2, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl,
                    autofocus: false,
                    maxLength: 20,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: _nicknamePlaceholder(theme),
                      hintStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
                      filled: true,
                      fillColor: colors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20,
                      ),
                      errorText: _error,
                    ),
                    onChanged: (_) => setState(() => _error = null),
                    onSubmitted: (_) => _save(context),
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\- ]')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lettere, numeri, trattino e underscore. Max 20 caratteri.',
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),

                  const Spacer(),

                  // ── Bottone conferma ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : () => _save(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                color: colors.background,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _confirmLabel(theme),
                              style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Il nickname non può essere vuoto');
      return;
    }
    if (name.length < 3) {
      setState(() => _error = 'Minimo 3 caratteri');
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    final auth   = context.read<AuthProvider>();
    final sync   = context.read<SyncService>();
    final hunter = context.read<HunterProvider>();

    // Crea profilo su Firestore
    await sync.createProfile(
      nickname: name,
      photoUrl: auth.user?.photoURL,
    );

    // Aggiorna nome locale
    await hunter.setName(name);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS TESTO
// ─────────────────────────────────────────────────────────────────────────────
String _welcomeTitle(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'BENVENUTO, HUNTER',
  GymTheme.military => 'OPERATORE RICONOSCIUTO',
  GymTheme.minimal  => 'INIZIAMO',
  GymTheme.medieval => 'IL REGNO TI ACCOGLIE',
};

String _welcomeHeadline(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Come vuoi\nessere chiamato?',
  GymTheme.military => 'Qual è il tuo\ncallsign?',
  GymTheme.minimal  => 'Come ti chiami?',
  GymTheme.medieval => 'Qual è il nome\ndel tuo guerriero?',
};

String _welcomeSub(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Scegli il tuo nome da Hunter. Potrai cambiarlo in seguito.',
  GymTheme.military => 'Il tuo callsign ti identificherà in ogni missione.',
  GymTheme.minimal  => 'Puoi cambiarlo in qualsiasi momento dalle impostazioni.',
  GymTheme.medieval => 'Il tuo nome echeggerà tra le mura del castello.',
};

String _nicknameLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'NICKNAME',
  GymTheme.military => 'CALLSIGN',
  GymTheme.minimal  => 'NOME',
  GymTheme.medieval => 'NOME DEL GUERRIERO',
};

String _nicknamePlaceholder(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'ShadowHunter, IronFist...',
  GymTheme.military => 'Ghost, Viper, Alpha...',
  GymTheme.minimal  => 'Il tuo nome...',
  GymTheme.medieval => 'Aldric, Thorvald...',
};

String _confirmLabel(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'ENTRA NEL DUNGEON',
  GymTheme.military => 'DEPLOY',
  GymTheme.minimal  => 'Inizia',
  GymTheme.medieval => 'GIURO FEDELTÀ',
};