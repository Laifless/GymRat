import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Font per tema:
/// - RPG       → Rajdhani (titoli) + Roboto Condensed (body)
/// - Military  → Oswald (titoli) + Source Code Pro (dettagli)
/// - Minimal   → DM Sans (tutto)
/// - Medieval  → MedievalSharp / Cinzel (titoli) + IM Fell English (body)
class AppTypography {
  AppTypography._();

  // ─── Display / Nome hunter ─────────────────────────────
  static TextStyle heroName(_ThemeId theme, Color color) {
    return switch (theme) {
      _ThemeId.rpg      => GoogleFonts.rajdhani(fontSize: 28, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.5),
      _ThemeId.military => GoogleFonts.oswald(fontSize: 26, fontWeight: FontWeight.w500, color: color, letterSpacing: 1),
      _ThemeId.minimal  => GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w500, color: color),
      _ThemeId.medieval => GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.5),
    };
  }

  // ─── Label rank/tier ───────────────────────────────────
  static TextStyle rankLabel(_ThemeId theme, Color color) {
    return switch (theme) {
      _ThemeId.rpg      => GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 2),
      _ThemeId.military => GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 1.5),
      _ThemeId.minimal  => GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: color, letterSpacing: 1),
      _ThemeId.medieval => GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.w500, color: color, letterSpacing: 1.5),
    };
  }

  // ─── Body normale ──────────────────────────────────────
  static TextStyle body(_ThemeId theme, Color color, {double size = 13}) {
    return switch (theme) {
      _ThemeId.rpg      => GoogleFonts.getFont('Roboto Condensed', fontSize: size, color: color),
      _ThemeId.military => GoogleFonts.oswald(fontSize: size, fontWeight: FontWeight.w300, color: color),
      _ThemeId.minimal  => GoogleFonts.dmSans(fontSize: size, color: color),
      _ThemeId.medieval => GoogleFonts.imFellEnglish(fontSize: size, color: color),
    };
  }

  // ─── Body secondario / hint ────────────────────────────
  static TextStyle caption(_ThemeId theme, Color color) {
    return switch (theme) {
      _ThemeId.rpg      => GoogleFonts.getFont('Roboto Condensed', fontSize: 11, color: color, letterSpacing: 0.3),
      _ThemeId.military => GoogleFonts.sourceCodePro(fontSize: 10, color: color, letterSpacing: 0.5),
      _ThemeId.minimal  => GoogleFonts.dmSans(fontSize: 11, color: color),
      _ThemeId.medieval => GoogleFonts.imFellEnglish(fontSize: 11, color: color, fontStyle: FontStyle.italic),
    };
  }

  // ─── Numero grande (timer, stat) ───────────────────────
  static TextStyle bigNumber(_ThemeId theme, Color color) {
    return switch (theme) {
      _ThemeId.rpg      => GoogleFonts.rajdhani(fontSize: 42, fontWeight: FontWeight.w600, color: color, letterSpacing: 2),
      _ThemeId.military => GoogleFonts.oswald(fontSize: 40, fontWeight: FontWeight.w400, color: color, letterSpacing: 3),
      _ThemeId.minimal  => GoogleFonts.dmSans(fontSize: 40, fontWeight: FontWeight.w300, color: color),
      _ThemeId.medieval => GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.w600, color: color, letterSpacing: 1),
    };
  }

  // ─── Section label (etichette sezione) ─────────────────
  static TextStyle sectionLabel(_ThemeId theme, Color color) {
    return switch (theme) {
      _ThemeId.rpg      => GoogleFonts.rajdhani(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 2.5),
      _ThemeId.military => GoogleFonts.sourceCodePro(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 2),
      _ThemeId.minimal  => GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: color, letterSpacing: 1.5),
      _ThemeId.medieval => GoogleFonts.cinzel(fontSize: 9, fontWeight: FontWeight.w500, color: color, letterSpacing: 2),
    };
  }
}

enum _ThemeId { rpg, military, minimal, medieval }