import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/providers/theme_provider.dart';
import 'core/providers/hunter_provider.dart';
import 'core/providers/workout_provider.dart';
import 'screens/boot/boot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forza orientamento verticale
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Carica tema salvato prima di avviare l'app
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => HunterProvider()..load()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
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
      home: const BootScreen(),
    );
  }
}