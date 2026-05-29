import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/hunter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_themes.dart';
import '../../core/constants/rank_constants.dart';
import '../../models/muscle_data.dart';

class MuscleScreen extends StatefulWidget {
  const MuscleScreen({super.key});

  @override
  State<MuscleScreen> createState() => _MuscleScreenState();
}

class _MuscleScreenState extends State<MuscleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider  = context.watch<ThemeProvider>();
    final hunterProvider = context.watch<HunterProvider>();
    final colors = themeProvider.colors;
    final theme  = themeProvider.current;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _screenTitle(theme),
                    style: TextStyle(
                      fontSize: 9, color: colors.textTertiary,
                      letterSpacing: 2, fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab fronte/retro ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: colors.background,
                  unselectedLabelColor: colors.textSecondary,
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                  tabs: const [
                    Tab(text: 'ANTERIORE'),
                    Tab(text: 'POSTERIORE'),
                  ],
                ),
              ),
            ),

            // ── Muscle map ──
            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _MuscleMapFront(
                    muscleData: hunterProvider.allMuscles,
                    selected: _selected,
                    onSelect: (m) => setState(() => _selected = _selected == m ? null : m),
                    colors: colors,
                  ),
                  _MuscleMapBack(
                    muscleData: hunterProvider.allMuscles,
                    selected: _selected,
                    onSelect: (m) => setState(() => _selected = _selected == m ? null : m),
                    colors: colors,
                  ),
                ],
              ),
            ),

            // ── Dettaglio muscolo selezionato ──
            if (_selected != null)
              _MuscleDetail(
                muscleKey: _selected!,
                data: hunterProvider.muscleData(_selected!),
                colors: colors,
              ),

            // ── Lista tutti i muscoli ──
            Expanded(
              child: _MuscleList(
                allMuscles: hunterProvider.allMuscles,
                selected: _selected,
                onSelect: (m) => setState(() => _selected = _selected == m ? null : m),
                colors: colors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MUSCLE MAP FRONT — SVG anatomico anteriore
// ─────────────────────────────────────────────────────────────────────────────
class _MuscleMapFront extends StatelessWidget {
  final Map<String, MuscleData> muscleData;
  final String? selected;
  final ValueChanged<String> onSelect;
  final ThemeColors colors;

  const _MuscleMapFront({
    required this.muscleData,
    required this.selected,
    required this.onSelect,
    required this.colors,
  });

  Color _color(String key) {
    final data = muscleData[key];
    if (data == null || data.totalVolume == 0) return colors.surfaceVariant;
    final tier = getTierFromVolume(data.totalVolume);
    return tier.color;
  }

  double _opacity(String key) => selected == null || selected == key ? 1.0 : 0.35;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition),
      child: Center(
        child: SizedBox(
          height: 300,
          child: AspectRatio(
            aspectRatio: 0.55,
            child: CustomPaint(
              painter: _FrontMusclePainter(
                pettorali:    _color('pettorali'),
                spalle:       _color('spalle'),
                bicipiti:     _color('bicipiti'),
                tricipiti:    _color('tricipiti'),
                addominali:   _color('addominali'),
                dorsali:      _color('dorsali'),
                quadricipiti: _color('quadricipiti'),
                femorali:     _color('femorali'),
                polpacci:     _color('polpacci'),
                avambracci:   _color('avambracci'),
                glutei:       _color('glutei'),
                bodyColor:    colors.glass,
                borderColor:  colors.glassBorder,
                selectedKey:  selected,
                opacityFn:    _opacity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset pos) {
    // Mapping approssimativo delle zone di tap → muscolo
    // Basato sul layout del CustomPainter (viewBox 160×300)
    final w = 160.0, h = 300.0;
    // Normalizza in base alle dimensioni reali del widget
    // Il GestureDetector riceve coordinate locali al widget
    final muscles = _getTapZones();
    for (final zone in muscles) {
      if (zone['rect'].contains(pos)) {
        onSelect(zone['key'] as String);
        return;
      }
    }
  }

  List<Map<String, dynamic>> _getTapZones() => [
    {'key': 'spalle',       'rect': const Rect.fromLTWH(10, 60, 35, 35)},
    {'key': 'spalle',       'rect': const Rect.fromLTWH(115, 60, 35, 35)},
    {'key': 'pettorali',    'rect': const Rect.fromLTWH(45, 70, 70, 45)},
    {'key': 'bicipiti',     'rect': const Rect.fromLTWH(15, 95, 28, 50)},
    {'key': 'bicipiti',     'rect': const Rect.fromLTWH(117, 95, 28, 50)},
    {'key': 'avambracci',   'rect': const Rect.fromLTWH(10, 145, 28, 45)},
    {'key': 'avambracci',   'rect': const Rect.fromLTWH(122, 145, 28, 45)},
    {'key': 'addominali',   'rect': const Rect.fromLTWH(52, 112, 56, 55)},
    {'key': 'quadricipiti', 'rect': const Rect.fromLTWH(42, 175, 32, 65)},
    {'key': 'quadricipiti', 'rect': const Rect.fromLTWH(86, 175, 32, 65)},
    {'key': 'femorali',     'rect': const Rect.fromLTWH(42, 235, 32, 40)},
    {'key': 'femorali',     'rect': const Rect.fromLTWH(86, 235, 32, 40)},
    {'key': 'polpacci',     'rect': const Rect.fromLTWH(48, 268, 25, 30)},
    {'key': 'polpacci',     'rect': const Rect.fromLTWH(87, 268, 25, 30)},
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// FRONT MUSCLE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _FrontMusclePainter extends CustomPainter {
  final Color pettorali, spalle, bicipiti, tricipiti, addominali;
  final Color dorsali, quadricipiti, femorali, polpacci, avambracci, glutei;
  final Color bodyColor, borderColor;
  final String? selectedKey;
  final double Function(String) opacityFn;

  _FrontMusclePainter({
    required this.pettorali,
    required this.spalle,
    required this.bicipiti,
    required this.tricipiti,
    required this.addominali,
    required this.dorsali,
    required this.quadricipiti,
    required this.femorali,
    required this.polpacci,
    required this.avambracci,
    required this.glutei,
    required this.bodyColor,
    required this.borderColor,
    required this.selectedKey,
    required this.opacityFn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 160;
    final scaleY = size.height / 300;
    canvas.scale(scaleX, scaleY);

    _drawBody(canvas);
    _drawMuscles(canvas);
  }

  void _drawBody(Canvas canvas) {
    final paint = Paint()
      ..color = bodyColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Testa
    final head = Path()
      ..addOval(const Rect.fromLTWH(58, 4, 44, 50));
    canvas.drawPath(head, paint);
    canvas.drawPath(head, border);

    // Collo
    final neck = Path()
      ..moveTo(72, 50)
      ..lineTo(88, 50)
      ..lineTo(90, 68)
      ..lineTo(70, 68)
      ..close();
    canvas.drawPath(neck, paint);
    canvas.drawPath(neck, border);

    // Torso
    final torso = Path()
      ..moveTo(35, 68)
      ..cubicTo(25, 72, 18, 80, 20, 100)
      ..lineTo(22, 170)
      ..cubicTo(24, 178, 30, 182, 40, 182)
      ..lineTo(60, 183)
      ..lineTo(62, 175)
      ..lineTo(98, 175)
      ..lineTo(100, 183)
      ..lineTo(120, 182)
      ..cubicTo(130, 182, 136, 178, 138, 170)
      ..lineTo(140, 100)
      ..cubicTo(142, 80, 135, 72, 125, 68)
      ..close();
    canvas.drawPath(torso, paint);
    canvas.drawPath(torso, border);

    // Braccio sinistro
    final armL = Path()
      ..moveTo(20, 70)
      ..cubicTo(10, 74, 4, 88, 6, 100)
      ..lineTo(8, 150)
      ..cubicTo(8, 158, 12, 165, 18, 168)
      ..lineTo(28, 168)
      ..cubicTo(34, 165, 38, 158, 38, 150)
      ..lineTo(38, 100)
      ..cubicTo(38, 85, 32, 74, 20, 70)
      ..close();
    canvas.drawPath(armL, paint);
    canvas.drawPath(armL, border);

    // Avambraccio sinistro
    final forearmL = Path()
      ..moveTo(10, 168)
      ..cubicTo(6, 172, 4, 180, 5, 190)
      ..lineTo(8, 218)
      ..cubicTo(9, 225, 14, 230, 20, 230)
      ..lineTo(30, 230)
      ..cubicTo(36, 230, 40, 225, 40, 218)
      ..lineTo(42, 190)
      ..cubicTo(42, 180, 40, 172, 36, 168)
      ..close();
    canvas.drawPath(forearmL, paint);
    canvas.drawPath(forearmL, border);

    // Braccio destro
    final armR = Path()
      ..moveTo(140, 70)
      ..cubicTo(150, 74, 156, 88, 154, 100)
      ..lineTo(152, 150)
      ..cubicTo(152, 158, 148, 165, 142, 168)
      ..lineTo(132, 168)
      ..cubicTo(126, 165, 122, 158, 122, 150)
      ..lineTo(122, 100)
      ..cubicTo(122, 85, 128, 74, 140, 70)
      ..close();
    canvas.drawPath(armR, paint);
    canvas.drawPath(armR, border);

    // Avambraccio destro
    final forearmR = Path()
      ..moveTo(150, 168)
      ..cubicTo(154, 172, 156, 180, 155, 190)
      ..lineTo(152, 218)
      ..cubicTo(151, 225, 146, 230, 140, 230)
      ..lineTo(130, 230)
      ..cubicTo(124, 230, 120, 225, 120, 218)
      ..lineTo(118, 190)
      ..cubicTo(118, 180, 120, 172, 124, 168)
      ..close();
    canvas.drawPath(forearmR, paint);
    canvas.drawPath(forearmR, border);

    // Gamba sinistra coscia
    final legL = Path()
      ..moveTo(40, 182)
      ..cubicTo(32, 185, 26, 195, 28, 210)
      ..lineTo(34, 258)
      ..cubicTo(35, 268, 42, 275, 52, 275)
      ..lineTo(64, 275)
      ..cubicTo(72, 275, 76, 268, 76, 258)
      ..lineTo(74, 210)
      ..cubicTo(74, 195, 68, 185, 60, 182)
      ..close();
    canvas.drawPath(legL, paint);
    canvas.drawPath(legL, border);

    // Polpaccio sinistro
    final calfL = Path()
      ..moveTo(34, 275)
      ..cubicTo(30, 280, 28, 290, 30, 300)
      ..lineTo(34, 295)
      ..cubicTo(36, 300, 44, 304, 52, 304)
      ..lineTo(62, 304)
      ..cubicTo(70, 304, 76, 298, 76, 292)
      ..lineTo(76, 280)
      ..cubicTo(74, 272, 70, 272, 66, 275)
      ..close();
    canvas.drawPath(calfL, paint);
    canvas.drawPath(calfL, border);

    // Gamba destra coscia
    final legR = Path()
      ..moveTo(120, 182)
      ..cubicTo(128, 185, 134, 195, 132, 210)
      ..lineTo(126, 258)
      ..cubicTo(125, 268, 118, 275, 108, 275)
      ..lineTo(96, 275)
      ..cubicTo(88, 275, 84, 268, 84, 258)
      ..lineTo(86, 210)
      ..cubicTo(86, 195, 92, 185, 100, 182)
      ..close();
    canvas.drawPath(legR, paint);
    canvas.drawPath(legR, border);

    // Polpaccio destro
    final calfR = Path()
      ..moveTo(126, 275)
      ..cubicTo(130, 280, 132, 290, 130, 300)
      ..lineTo(126, 295)
      ..cubicTo(124, 300, 116, 304, 108, 304)
      ..lineTo(98, 304)
      ..cubicTo(90, 304, 84, 298, 84, 292)
      ..lineTo(84, 280)
      ..cubicTo(86, 272, 90, 272, 94, 275)
      ..close();
    canvas.drawPath(calfR, paint);
    canvas.drawPath(calfR, border);
  }

  void _drawMuscles(Canvas canvas) {
    // SPALLE (deltoidi)
    _drawMuscle(canvas, 'spalle', spalle, () {
      final p = Path();
      // Spalla sinistra
      p.moveTo(20, 70);
      p.cubicTo(10, 68, 4, 76, 8, 92);
      p.lineTo(14, 105);
      p.cubicTo(18, 110, 24, 108, 28, 102);
      p.lineTo(36, 88);
      p.cubicTo(38, 80, 34, 70, 20, 70);
      // Spalla destra
      p.moveTo(140, 70);
      p.cubicTo(150, 68, 156, 76, 152, 92);
      p.lineTo(146, 105);
      p.cubicTo(142, 110, 136, 108, 132, 102);
      p.lineTo(124, 88);
      p.cubicTo(122, 80, 126, 70, 140, 70);
      return p;
    }());

    // PETTORALI
    _drawMuscle(canvas, 'pettorali', pettorali, () {
      final p = Path();
      // Pettorale sinistro
      p.moveTo(70, 70);
      p.cubicTo(55, 70, 40, 76, 38, 88);
      p.cubicTo(36, 98, 42, 110, 55, 115);
      p.lineTo(75, 118);
      p.lineTo(75, 70);
      p.close();
      // Pettorale destro
      p.moveTo(90, 70);
      p.cubicTo(105, 70, 120, 76, 122, 88);
      p.cubicTo(124, 98, 118, 110, 105, 115);
      p.lineTo(85, 118);
      p.lineTo(85, 70);
      p.close();
      return p;
    }());

    // BICIPITI
    _drawMuscle(canvas, 'bicipiti', bicipiti, () {
      final p = Path();
      // Bicipite sinistro
      p.moveTo(12, 96);
      p.cubicTo(6, 100, 4, 115, 8, 128);
      p.lineTo(14, 148);
      p.cubicTo(16, 155, 24, 158, 30, 154);
      p.lineTo(36, 138);
      p.cubicTo(38, 124, 36, 110, 30, 100);
      p.cubicTo(26, 94, 18, 92, 12, 96);
      // Bicipite destro
      p.moveTo(148, 96);
      p.cubicTo(154, 100, 156, 115, 152, 128);
      p.lineTo(146, 148);
      p.cubicTo(144, 155, 136, 158, 130, 154);
      p.lineTo(124, 138);
      p.cubicTo(122, 124, 124, 110, 130, 100);
      p.cubicTo(134, 94, 142, 92, 148, 96);
      return p;
    }());

    // AVAMBRACCI
    _drawMuscle(canvas, 'avambracci', avambracci, () {
      final p = Path();
      p.moveTo(8, 155);
      p.cubicTo(4, 162, 4, 178, 8, 192);
      p.lineTo(14, 220);
      p.cubicTo(16, 228, 24, 232, 30, 228);
      p.lineTo(38, 210);
      p.cubicTo(40, 196, 38, 180, 34, 168);
      p.cubicTo(28, 158, 14, 152, 8, 155);
      p.moveTo(152, 155);
      p.cubicTo(156, 162, 156, 178, 152, 192);
      p.lineTo(146, 220);
      p.cubicTo(144, 228, 136, 232, 130, 228);
      p.lineTo(122, 210);
      p.cubicTo(120, 196, 122, 180, 126, 168);
      p.cubicTo(132, 158, 146, 152, 152, 155);
      return p;
    }());

    // ADDOMINALI
    _drawMuscle(canvas, 'addominali', addominali, () {
      final p = Path();
      // Retto addominale con segmentazioni
      p.moveTo(62, 115);
      p.cubicTo(58, 118, 56, 125, 57, 132);
      p.lineTo(60, 165);
      p.cubicTo(62, 172, 68, 175, 75, 173);
      p.lineTo(85, 173);
      p.cubicTo(92, 175, 98, 172, 100, 165);
      p.lineTo(103, 132);
      p.cubicTo(104, 125, 102, 118, 98, 115);
      p.close();
      return p;
    }());

    // Linee addominali
    final linePaint = Paint()
      ..color = bodyColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(80, 115), const Offset(80, 173), linePaint);
    canvas.drawLine(const Offset(60, 132), const Offset(100, 132), linePaint);
    canvas.drawLine(const Offset(59, 148), const Offset(101, 148), linePaint);
    canvas.drawLine(const Offset(60, 162), const Offset(100, 162), linePaint);

    // OBLIQUI (parte degli addominali visivamente)
    _drawMuscle(canvas, 'addominali', addominali.withOpacity(0.7), () {
      final p = Path();
      p.moveTo(40, 115);
      p.cubicTo(36, 120, 38, 135, 44, 145);
      p.lineTo(58, 155);
      p.lineTo(60, 145);
      p.lineTo(50, 130);
      p.cubicTo(46, 122, 44, 116, 40, 115);
      p.moveTo(120, 115);
      p.cubicTo(124, 120, 122, 135, 116, 145);
      p.lineTo(102, 155);
      p.lineTo(100, 145);
      p.lineTo(110, 130);
      p.cubicTo(114, 122, 116, 116, 120, 115);
      return p;
    }());

    // QUADRICIPITI
    _drawMuscle(canvas, 'quadricipiti', quadricipiti, () {
      final p = Path();
      // Quad sinistro
      p.moveTo(40, 185);
      p.cubicTo(30, 190, 26, 208, 30, 225);
      p.lineTo(38, 258);
      p.cubicTo(42, 268, 52, 272, 60, 268);
      p.lineTo(68, 255);
      p.cubicTo(74, 240, 74, 215, 68, 195);
      p.cubicTo(62, 183, 50, 182, 40, 185);
      // Quad destro
      p.moveTo(120, 185);
      p.cubicTo(130, 190, 134, 208, 130, 225);
      p.lineTo(122, 258);
      p.cubicTo(118, 268, 108, 272, 100, 268);
      p.lineTo(92, 255);
      p.cubicTo(86, 240, 86, 215, 92, 195);
      p.cubicTo(98, 183, 110, 182, 120, 185);
      return p;
    }());

    // Divisione quad interna
    final qdivPaint = Paint()
      ..color = bodyColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    // Sinistra
    canvas.drawLine(const Offset(54, 185), const Offset(50, 270), qdivPaint);
    // Destra
    canvas.drawLine(const Offset(106, 185), const Offset(110, 270), qdivPaint);

    // POLPACCI
    _drawMuscle(canvas, 'polpacci', polpacci, () {
      final p = Path();
      p.moveTo(32, 275);
      p.cubicTo(26, 282, 26, 298, 32, 308);
      p.cubicTo(38, 316, 50, 318, 58, 314);
      p.lineTo(62, 304);
      p.cubicTo(66, 295, 66, 282, 62, 275);
      p.cubicTo(56, 270, 40, 268, 32, 275);
      p.moveTo(128, 275);
      p.cubicTo(134, 282, 134, 298, 128, 308);
      p.cubicTo(122, 316, 110, 318, 102, 314);
      p.lineTo(98, 304);
      p.cubicTo(94, 295, 94, 282, 98, 275);
      p.cubicTo(104, 270, 120, 268, 128, 275);
      return p;
    }());
  }

  void _drawMuscle(Canvas canvas, String key, Color color, Path path) {
    final opacity = opacityFn(key);
    final fill = Paint()
      ..color = color.withOpacity(opacity * (color == Colors.transparent ? 0 : 0.85))
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_FrontMusclePainter old) =>
      old.pettorali != pettorali ||
      old.spalle != spalle ||
      old.bicipiti != bicipiti ||
      old.addominali != addominali ||
      old.quadricipiti != quadricipiti ||
      old.femorali != femorali ||
      old.polpacci != polpacci ||
      old.selectedKey != selectedKey;
}

// ─────────────────────────────────────────────────────────────────────────────
// MUSCLE MAP BACK — SVG anatomico posteriore
// ─────────────────────────────────────────────────────────────────────────────
class _MuscleMapBack extends StatelessWidget {
  final Map<String, MuscleData> muscleData;
  final String? selected;
  final ValueChanged<String> onSelect;
  final ThemeColors colors;

  const _MuscleMapBack({
    required this.muscleData,
    required this.selected,
    required this.onSelect,
    required this.colors,
  });

  Color _color(String key) {
    final data = muscleData[key];
    if (data == null || data.totalVolume == 0) return colors.surfaceVariant;
    return getTierFromVolume(data.totalVolume).color;
  }

  double _opacity(String key) => selected == null || selected == key ? 1.0 : 0.35;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        child: AspectRatio(
          aspectRatio: 0.55,
          child: CustomPaint(
            painter: _BackMusclePainter(
              dorsali:      _color('dorsali'),
              trapezi:      _color('trapezi'),
              tricipiti:    _color('tricipiti'),
              glutei:       _color('glutei'),
              femorali:     _color('femorali'),
              polpacci:     _color('polpacci'),
              lombari:      _color('lombari'),
              avambracci:   _color('avambracci'),
              bodyColor:    colors.glass,
              borderColor:  colors.glassBorder,
              selectedKey:  selected,
              opacityFn:    _opacity,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackMusclePainter extends CustomPainter {
  final Color dorsali, trapezi, tricipiti, glutei, femorali, polpacci, lombari, avambracci;
  final Color bodyColor, borderColor;
  final String? selectedKey;
  final double Function(String) opacityFn;

  _BackMusclePainter({
    required this.dorsali,
    required this.trapezi,
    required this.tricipiti,
    required this.glutei,
    required this.femorali,
    required this.polpacci,
    required this.lombari,
    required this.avambracci,
    required this.bodyColor,
    required this.borderColor,
    required this.selectedKey,
    required this.opacityFn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 160;
    final scaleY = size.height / 300;
    canvas.scale(scaleX, scaleY);
    _drawBody(canvas);
    _drawMuscles(canvas);
  }

  void _drawBody(Canvas canvas) {
    final paint = Paint()
      ..color = bodyColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final head = Path()..addOval(const Rect.fromLTWH(58, 4, 44, 50));
    canvas.drawPath(head, paint);
    canvas.drawPath(head, border);

    final neck = Path()
      ..moveTo(72, 50)..lineTo(88, 50)..lineTo(90, 68)..lineTo(70, 68)..close();
    canvas.drawPath(neck, paint);
    canvas.drawPath(neck, border);

    final torso = Path()
      ..moveTo(35, 68)
      ..cubicTo(25, 72, 18, 82, 22, 100)
      ..lineTo(24, 170)
      ..cubicTo(26, 178, 32, 182, 42, 182)
      ..lineTo(118, 182)
      ..cubicTo(128, 182, 134, 178, 136, 170)
      ..lineTo(138, 100)
      ..cubicTo(142, 82, 135, 72, 125, 68)
      ..close();
    canvas.drawPath(torso, paint);
    canvas.drawPath(torso, border);

    // Braccia
    for (final isLeft in [true, false]) {
      final sx = isLeft ? 1.0 : -1.0;
      final ox = isLeft ? 0.0 : 160.0;

      final arm = Path()
        ..moveTo(ox + sx * 20, 70)
        ..cubicTo(ox + sx * 10, 74, ox + sx * 4, 88, ox + sx * 6, 100)
        ..lineTo(ox + sx * 8, 150)
        ..cubicTo(ox + sx * 8, 158, ox + sx * 14, 165, ox + sx * 20, 168)
        ..lineTo(ox + sx * 30, 168)
        ..cubicTo(ox + sx * 36, 165, ox + sx * 40, 158, ox + sx * 38, 150)
        ..lineTo(ox + sx * 36, 100)
        ..cubicTo(ox + sx * 36, 85, ox + sx * 30, 74, ox + sx * 20, 70)
        ..close();
      canvas.drawPath(arm, paint);
      canvas.drawPath(arm, border);

      final forearm = Path()
        ..moveTo(ox + sx * 10, 168)
        ..cubicTo(ox + sx * 5, 172, ox + sx * 4, 182, ox + sx * 6, 194)
        ..lineTo(ox + sx * 10, 222)
        ..cubicTo(ox + sx * 13, 230, ox + sx * 20, 232, ox + sx * 28, 228)
        ..lineTo(ox + sx * 36, 212)
        ..cubicTo(ox + sx * 40, 198, ox + sx * 38, 178, ox + sx * 34, 168)
        ..close();
      canvas.drawPath(forearm, paint);
      canvas.drawPath(forearm, border);
    }

    // Gambe posteriori
    for (final isLeft in [true, false]) {
      final sx = isLeft ? 1.0 : -1.0;
      final ox = isLeft ? 0.0 : 160.0;

      final thigh = Path()
        ..moveTo(ox + sx * 40, 183)
        ..cubicTo(ox + sx * 30, 188, ox + sx * 26, 205, ox + sx * 30, 222)
        ..lineTo(ox + sx * 38, 260)
        ..cubicTo(ox + sx * 42, 270, ox + sx * 52, 275, ox + sx * 62, 271)
        ..lineTo(ox + sx * 72, 258)
        ..cubicTo(ox + sx * 76, 242, ox + sx * 74, 215, ox + sx * 68, 196)
        ..cubicTo(ox + sx * 62, 183, ox + sx * 50, 180, ox + sx * 40, 183)
        ..close();
      canvas.drawPath(thigh, paint);
      canvas.drawPath(thigh, border);

      final calf = Path()
        ..moveTo(ox + sx * 34, 272)
        ..cubicTo(ox + sx * 28, 280, ox + sx * 28, 296, ox + sx * 34, 308)
        ..cubicTo(ox + sx * 40, 316, ox + sx * 52, 318, ox + sx * 60, 312)
        ..lineTo(ox + sx * 64, 300)
        ..cubicTo(ox + sx * 68, 288, ox + sx * 66, 275, ox + sx * 60, 272)
        ..cubicTo(ox + sx * 52, 268, ox + sx * 40, 266, ox + sx * 34, 272)
        ..close();
      canvas.drawPath(calf, paint);
      canvas.drawPath(calf, border);
    }
  }

  void _drawMuscles(Canvas canvas) {
    // TRAPEZI
    _drawMuscle(canvas, 'trapezi', trapezi, () {
      final p = Path();
      p.moveTo(80, 54);
      p.cubicTo(65, 56, 40, 62, 35, 72);
      p.cubicTo(38, 80, 50, 88, 65, 90);
      p.lineTo(80, 92);
      p.lineTo(95, 90);
      p.cubicTo(110, 88, 122, 80, 125, 72);
      p.cubicTo(120, 62, 95, 56, 80, 54);
      return p;
    }());

    // DORSALI (lat)
    _drawMuscle(canvas, 'dorsali', dorsali, () {
      final p = Path();
      // Dorsale sinistro
      p.moveTo(26, 95);
      p.cubicTo(22, 102, 22, 120, 28, 140);
      p.lineTo(38, 165);
      p.cubicTo(44, 175, 55, 178, 65, 172);
      p.lineTo(72, 160);
      p.cubicTo(76, 148, 74, 130, 68, 115);
      p.cubicTo(58, 98, 38, 90, 26, 95);
      // Dorsale destro
      p.moveTo(134, 95);
      p.cubicTo(138, 102, 138, 120, 132, 140);
      p.lineTo(122, 165);
      p.cubicTo(116, 175, 105, 178, 95, 172);
      p.lineTo(88, 160);
      p.cubicTo(84, 148, 86, 130, 92, 115);
      p.cubicTo(102, 98, 122, 90, 134, 95);
      return p;
    }());

    // LOMBARI
    _drawMuscle(canvas, 'lombari', lombari, () {
      final p = Path();
      p.moveTo(66, 145);
      p.cubicTo(62, 150, 60, 162, 62, 172);
      p.lineTo(65, 182);
      p.lineTo(80, 184);
      p.lineTo(95, 182);
      p.lineTo(98, 172);
      p.cubicTo(100, 162, 98, 150, 94, 145);
      p.cubicTo(88, 140, 72, 140, 66, 145);
      return p;
    }());

    // TRICIPITI
    _drawMuscle(canvas, 'tricipiti', tricipiti, () {
      final p = Path();
      // Tricipite sinistro (parte posteriore braccio)
      p.moveTo(10, 90);
      p.cubicTo(4, 98, 4, 118, 10, 135);
      p.lineTo(18, 155);
      p.cubicTo(22, 162, 30, 164, 36, 158);
      p.lineTo(40, 142);
      p.cubicTo(42, 128, 40, 108, 34, 95);
      p.cubicTo(28, 86, 16, 84, 10, 90);
      // Tricipite destro
      p.moveTo(150, 90);
      p.cubicTo(156, 98, 156, 118, 150, 135);
      p.lineTo(142, 155);
      p.cubicTo(138, 162, 130, 164, 124, 158);
      p.lineTo(120, 142);
      p.cubicTo(118, 128, 120, 108, 126, 95);
      p.cubicTo(132, 86, 144, 84, 150, 90);
      return p;
    }());

    // AVAMBRACCI POSTERIORI
    _drawMuscle(canvas, 'avambracci', avambracci, () {
      final p = Path();
      p.moveTo(6, 158);
      p.cubicTo(2, 166, 2, 184, 6, 198);
      p.lineTo(12, 224);
      p.cubicTo(16, 232, 24, 234, 32, 228);
      p.lineTo(38, 210);
      p.cubicTo(42, 194, 40, 174, 36, 162);
      p.cubicTo(28, 152, 12, 150, 6, 158);
      p.moveTo(154, 158);
      p.cubicTo(158, 166, 158, 184, 154, 198);
      p.lineTo(148, 224);
      p.cubicTo(144, 232, 136, 234, 128, 228);
      p.lineTo(122, 210);
      p.cubicTo(118, 194, 120, 174, 124, 162);
      p.cubicTo(132, 152, 148, 150, 154, 158);
      return p;
    }());

    // GLUTEI
    _drawMuscle(canvas, 'glutei', glutei, () {
      final p = Path();
      // Gluteo sinistro
      p.moveTo(38, 180);
      p.cubicTo(26, 184, 22, 200, 28, 218);
      p.cubicTo(34, 232, 50, 240, 68, 235);
      p.lineTo(78, 225);
      p.cubicTo(80, 210, 76, 192, 68, 184);
      p.cubicTo(60, 178, 48, 178, 38, 180);
      // Gluteo destro
      p.moveTo(122, 180);
      p.cubicTo(134, 184, 138, 200, 132, 218);
      p.cubicTo(126, 232, 110, 240, 92, 235);
      p.lineTo(82, 225);
      p.cubicTo(80, 210, 84, 192, 92, 184);
      p.cubicTo(100, 178, 112, 178, 122, 180);
      return p;
    }());

    // FEMORALI (bicipite femorale posteriore)
    _drawMuscle(canvas, 'femorali', femorali, () {
      final p = Path();
      p.moveTo(30, 228);
      p.cubicTo(24, 238, 24, 258, 30, 272);
      p.lineTo(40, 272);
      p.cubicTo(50, 270, 60, 264, 64, 254);
      p.lineTo(66, 236);
      p.cubicTo(62, 228, 52, 224, 42, 226);
      p.close();
      p.moveTo(130, 228);
      p.cubicTo(136, 238, 136, 258, 130, 272);
      p.lineTo(120, 272);
      p.cubicTo(110, 270, 100, 264, 96, 254);
      p.lineTo(94, 236);
      p.cubicTo(98, 228, 108, 224, 118, 226);
      p.close();
      return p;
    }());

    // POLPACCI POSTERIORI
    _drawMuscle(canvas, 'polpacci', polpacci, () {
      final p = Path();
      p.moveTo(30, 272);
      p.cubicTo(24, 280, 24, 300, 32, 312);
      p.cubicTo(40, 320, 54, 320, 62, 312);
      p.lineTo(66, 300);
      p.cubicTo(68, 288, 66, 275, 60, 272);
      p.cubicTo(52, 268, 38, 268, 30, 272);
      p.moveTo(130, 272);
      p.cubicTo(136, 280, 136, 300, 128, 312);
      p.cubicTo(120, 320, 106, 320, 98, 312);
      p.lineTo(94, 300);
      p.cubicTo(92, 288, 94, 275, 100, 272);
      p.cubicTo(108, 268, 122, 268, 130, 272);
      return p;
    }());
  }

  void _drawMuscle(Canvas canvas, String key, Color color, Path path) {
    final opacity = opacityFn(key);
    final fill = Paint()
      ..color = color.withOpacity(opacity * 0.85)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_BackMusclePainter old) =>
      old.dorsali != dorsali ||
      old.trapezi != trapezi ||
      old.glutei != glutei ||
      old.femorali != femorali ||
      old.polpacci != polpacci ||
      old.selectedKey != selectedKey;
}

// ─────────────────────────────────────────────────────────────────────────────
// MUSCLE DETAIL
// ─────────────────────────────────────────────────────────────────────────────
class _MuscleDetail extends StatelessWidget {
  final String muscleKey;
  final MuscleData data;
  final ThemeColors colors;

  const _MuscleDetail({
    required this.muscleKey,
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final tier     = data.tier;
    final progress = data.progress;
    final volNext  = data.volumeToNextTier;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.glass,
        border: Border.all(color: tier.color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: tier.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tier.color.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                tier.label[0],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tier.color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.displayName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tier.color.withOpacity(0.08),
                        border: Border.all(color: tier.color.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tier.label.toUpperCase(),
                        style: TextStyle(fontSize: 9, color: tier.color, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(tier.color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  volNext != null
                      ? '${data.totalVolume} kg totali · ${volNext} kg al prossimo tier'
                      : '${data.totalVolume} kg totali · TITAN raggiunto',
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MUSCLE LIST
// ─────────────────────────────────────────────────────────────────────────────
class _MuscleList extends StatelessWidget {
  final Map<String, MuscleData> allMuscles;
  final String? selected;
  final ValueChanged<String> onSelect;
  final ThemeColors colors;

  const _MuscleList({
    required this.allMuscles,
    required this.selected,
    required this.onSelect,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = allMuscles.values.toList()
      ..sort((a, b) => b.totalVolume.compareTo(a.totalVolume));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final m = sorted[i];
        final tier = m.tier;
        final isSelected = selected == m.muscleGroup;

        return GestureDetector(
          onTap: () => onSelect(m.muscleGroup),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? colors.accentGlow : colors.glass,
              border: Border.all(
                color: isSelected ? colors.accent : colors.glassBorder,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: tier.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? colors.accent : colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: m.progress,
                      minHeight: 3,
                      backgroundColor: colors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(tier.color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 50,
                  child: Text(
                    tier.label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 9,
                      color: tier.color,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
String _screenTitle(GymTheme t) => switch (t) {
  GymTheme.rpg      => 'CORPO',
  GymTheme.military => 'STATO FISICO',
  GymTheme.minimal  => 'MUSCOLI',
  GymTheme.medieval => 'CORPO DEL GUERRIERO',
};