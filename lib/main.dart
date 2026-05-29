import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/providers/theme_provider.dart';
import 'core/providers/hunter_provider.dart';
import 'core/providers/workout_provider.dart';
import 'screens/auth_provider.dart';
import 'screens/sync_service.dart';
import 'screens/boot/boot_screen.dart';
import 'firebase_options.dart'; // generato da flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => SyncService()),
        ChangeNotifierProvider(create: (_) => HunterProvider()..load()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()..load()),
      ],
      child: const TheBigGymApp(),
    ),
  );
}

class TheBigGymApp extends StatelessWidget {
  const TheBigGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'The Big Gym',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const AppRouter(),
    );
  }
}

/// Router principale — decide quale schermata mostrare
/// in base allo stato auth.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return switch (auth.status) {
      AuthStatus.unknown         => const _SplashScreen(),
      AuthStatus.unauthenticated => const BootScreen(),  // boot → login
      AuthStatus.authenticated   => const BootScreen(),  // boot → shell
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: CircularProgressIndicator(color: colors.accent),
      ),
    );
  }
}