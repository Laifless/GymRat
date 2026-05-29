import 'package:flutter/material.dart';
import 'package:gym_rat/screens/sync_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_themes.dart';
import '../auth_provider.dart';
import '../onboarding/onboarding.dart';
import '../main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showEmail = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final theme  = themeProvider.current;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Logo / Titolo ──
              _buildHero(colors, theme),
              const SizedBox(height: 56),

              // ── Bottoni social ──
              _SocialButton(
                label: 'Continua con Google',
                icon: _googleIcon(),
                colors: colors,
                onTap: () => _signInGoogle(context),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                label: 'Continua con Apple',
                icon: const Icon(Icons.apple, size: 20, color: Colors.white),
                colors: colors,
                onTap: () => _signInApple(context),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                label: 'Continua con Email',
                icon: Icon(Icons.mail_outline, size: 20, color: colors.textSecondary),
                colors: colors,
                outlined: true,
                onTap: () => setState(() => _showEmail = !_showEmail),
              ),

              // ── Form email (espandibile) ──
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: _showEmail
                    ? _EmailForm(colors: colors, theme: theme)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

              // ── Divider ──
              Row(
                children: [
                  Expanded(child: Divider(color: colors.glassBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('oppure', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                  ),
                  Expanded(child: Divider(color: colors.glassBorder)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Accesso ospite ──
              GestureDetector(
                onTap: () => _continueAsGuest(context),
                child: Center(
                  child: Text(
                    'Continua senza account →',
                    style: TextStyle(
                      fontSize: 13, color: colors.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.textSecondary,
                    ),
                  ),
                ),
              ),

              // ── Errore ──
              Consumer<AuthProvider>(
                builder: (_, auth, __) => auth.error != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error!,
                                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(ThemeColors colors, GymTheme theme) {
    final isMedieval = theme == GymTheme.medieval;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE',
          style: isMedieval
              ? GoogleFonts.cinzel(fontSize: 13, color: colors.textSecondary, letterSpacing: 6)
              : GoogleFonts.rajdhani(fontSize: 13, color: colors.textSecondary, letterSpacing: 6),
        ),
        Text(
          'BIG GYM',
          style: isMedieval
              ? GoogleFonts.cinzel(fontSize: 50, fontWeight: FontWeight.w700, color: colors.accent, height: 1)
              : GoogleFonts.rajdhani(fontSize: 56, fontWeight: FontWeight.w700, color: colors.accent, height: 1),
        ),
        const SizedBox(height: 10),
        Text(
          _tagline(theme),
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
      ],
    );
  }

  Future<void> _signInGoogle(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok   = await auth.signInWithGoogle();
    if (ok && mounted) _afterLogin(context);
  }

  Future<void> _signInApple(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok   = await auth.signInWithApple();
    if (ok && mounted) _afterLogin(context);
  }

  Future<void> _continueAsGuest(BuildContext context) async {
    // Salta il login, vai direttamente all'app
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  Future<void> _afterLogin(BuildContext context) async {
    // Controlla se il profilo esiste già su Firestore
    final syncService = context.read<SyncService>();
    final exists      = await syncService.profileExists();

    if (!mounted) return;
    if (exists) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  Widget _googleIcon() => SizedBox(
    width: 20, height: 20,
    child: Image.network(
      'https://www.google.com/favicon.ico',
      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EMAIL FORM
// ─────────────────────────────────────────────────────────────────────────────
class _EmailForm extends StatefulWidget {
  final ThemeColors colors;
  final GymTheme theme;

  const _EmailForm({required this.colors, required this.theme});

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin   = true;
  bool _obscure   = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Toggle login / registrazione
          Container(
            decoration: BoxDecoration(
              color: c.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabBtn(label: 'Accedi',       active: _isLogin,  colors: c, onTap: () => setState(() => _isLogin = true)),
                _TabBtn(label: 'Registrati',   active: !_isLogin, colors: c, onTap: () => setState(() => _isLogin = false)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Email
          _InputField(
            ctrl: _emailCtrl,
            hint: 'Email',
            icon: Icons.mail_outline,
            colors: c,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),

          // Password
          _InputField(
            ctrl: _passwordCtrl,
            hint: 'Password',
            icon: Icons.lock_outline,
            colors: c,
            obscure: _obscure,
            suffix: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: c.textSecondary),
            ),
          ),
          const SizedBox(height: 4),

          // Reset password
          if (_isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _resetPassword(context),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('Password dimenticata?', style: TextStyle(fontSize: 11, color: c.textSecondary)),
              ),
            ),
          const SizedBox(height: 12),

          // Submit
          SizedBox(
            width: double.infinity,
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) => ElevatedButton(
                onPressed: auth.loading ? null : () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.accent,
                  foregroundColor: c.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: auth.loading
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: c.background, strokeWidth: 2))
                    : Text(_isLogin ? 'Accedi' : 'Crea account', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final auth  = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text;

    if (email.isEmpty || pass.isEmpty) return;

    bool ok;
    if (_isLogin) {
      ok = await auth.signInWithEmail(email, pass);
    } else {
      ok = await auth.registerWithEmail(email, pass);
    }

    if (ok && mounted) {
      final sync   = context.read<SyncService>();
      final exists = await sync.profileExists();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => exists ? const MainShell() : const OnboardingScreen()),
      );
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci prima la tua email')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok   = await auth.resetPassword(email);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email di reset inviata a $email')),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final ThemeColors colors;
  final VoidCallback onTap;
  final bool outlined;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Consumer<AuthProvider>(
      builder: (_, auth, __) => AnimatedOpacity(
        opacity: auth.loading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : colors.glass,
            border: Border.all(color: outlined ? colors.glassBorder : colors.glassBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final ThemeColors colors;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _InputField({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.colors,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: TextStyle(color: colors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: colors.textSecondary),
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
  );
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.active, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: active ? colors.background : colors.textSecondary,
          ),
        ),
      ),
    ),
  );
}

String _tagline(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'Traccia il tuo allenamento. Sali di rank.',
  GymTheme.military => 'Completa le missioni. Avanza di grado.',
  GymTheme.minimal  => 'Il tuo gym tracker personale.',
  GymTheme.medieval => 'Combatti. Cresci. Diventa leggenda.',
};