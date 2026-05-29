import 'package:flutter/material.dart';
import 'package:gym_rat/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_themes.dart';
import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'muscles/muscle_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    WorkoutScreen(),
    MuscleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final theme  = context.watch<ThemeProvider>().current;
    final isLight = theme == GymTheme.minimal;

    return Scaffold(
      backgroundColor: colors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        colors: colors,
        theme: theme,
        isLight: isLight,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ThemeColors colors;
  final GymTheme theme;
  final bool isLight;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.colors,
    required this.theme,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final items = _navItems(theme);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.glassBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.accentGlow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? items[i].activeIcon : items[i].icon,
                            color: selected
                                ? colors.accent
                                : colors.textTertiary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 0.8,
                            color: selected
                                ? colors.accent
                                : colors.textTertiary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

List<_NavItem> _navItems(GymTheme theme) {
  return switch (theme) {
    GymTheme.rpg => const [
      _NavItem(label: 'HUNTER',  icon: Icons.person_outline,    activeIcon: Icons.person),
      _NavItem(label: 'DUNGEON', icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
      _NavItem(label: 'CORPO',   icon: Icons.accessibility_new_outlined, activeIcon: Icons.accessibility_new),
      _NavItem(label: 'SETUP',   icon: Icons.tune_outlined,     activeIcon: Icons.tune),
    ],
    GymTheme.military => const [
      _NavItem(label: 'OPERATIVO', icon: Icons.person_outline,  activeIcon: Icons.person),
      _NavItem(label: 'CAMPO',     icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
      _NavItem(label: 'CORPO',     icon: Icons.accessibility_new_outlined, activeIcon: Icons.accessibility_new),
      _NavItem(label: 'CONFIG',    icon: Icons.tune_outlined,   activeIcon: Icons.tune),
    ],
    GymTheme.minimal => const [
      _NavItem(label: 'Profilo',  icon: Icons.person_outline,   activeIcon: Icons.person),
      _NavItem(label: 'Allena',   icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
      _NavItem(label: 'Corpo',    icon: Icons.accessibility_new_outlined, activeIcon: Icons.accessibility_new),
      _NavItem(label: 'Impost.',  icon: Icons.tune_outlined,    activeIcon: Icons.tune),
    ],
    GymTheme.medieval => const [
      _NavItem(label: 'GUERRIERO', icon: Icons.person_outline,  activeIcon: Icons.person),
      _NavItem(label: 'BATTAGLIA', icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
      _NavItem(label: 'CORPO',     icon: Icons.accessibility_new_outlined, activeIcon: Icons.accessibility_new),
      _NavItem(label: 'PERGAMENA', icon: Icons.tune_outlined,   activeIcon: Icons.tune),
    ],
  };
}