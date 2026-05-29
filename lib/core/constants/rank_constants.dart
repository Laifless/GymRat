import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ─── RANK HUNTER ──────────────────────────────────────────────────────────────
// Il rank si basa sull'XP totale accumulato da tutte le sessioni.

enum HunterRank {
  iron, bronze, silver, gold, platinum, diamond, ruby, crystal, elite, champion, celestial, titan,
  ss, ssp, sss,
}

class RankInfo {
  final HunterRank rank;
  final String label;
  final Color color;
  final int xpRequired; // XP totale per raggiungere questo rank

  const RankInfo({
    required this.rank,
    required this.label,
    required this.color,
    required this.xpRequired,
  });
}

const List<RankInfo> kRanks = [
  RankInfo(rank: HunterRank.iron,      label: 'Iron',      color: AppColors.tierIron,      xpRequired: 0),
  RankInfo(rank: HunterRank.bronze,    label: 'Bronze',    color: AppColors.tierBronze,    xpRequired: 1000),
  RankInfo(rank: HunterRank.silver,    label: 'Silver',    color: AppColors.tierSilver,    xpRequired: 3000),
  RankInfo(rank: HunterRank.gold,      label: 'Gold',      color: AppColors.tierGold,      xpRequired: 7000),
  RankInfo(rank: HunterRank.platinum,  label: 'Platinum',  color: AppColors.tierPlatinum,  xpRequired: 15000),
  RankInfo(rank: HunterRank.diamond,   label: 'Diamond',   color: AppColors.tierDiamond,   xpRequired: 30000),
  RankInfo(rank: HunterRank.ruby,      label: 'Ruby',      color: AppColors.tierRuby,      xpRequired: 55000),
  RankInfo(rank: HunterRank.crystal,   label: 'Crystal',   color: AppColors.tierCrystal,   xpRequired: 90000),
  RankInfo(rank: HunterRank.elite,     label: 'Elite',     color: AppColors.tierElite,     xpRequired: 140000),
  RankInfo(rank: HunterRank.champion,  label: 'Champion',  color: AppColors.tierChampion,  xpRequired: 210000),
  RankInfo(rank: HunterRank.celestial, label: 'Celestial', color: AppColors.tierCelestial, xpRequired: 300000),
  RankInfo(rank: HunterRank.titan,     label: 'Titan',     color: AppColors.tierTitan,     xpRequired: 420000),
  RankInfo(rank: HunterRank.ss,        label: 'SS',        color: Color(0xFFFF4090),       xpRequired: 600000),
  RankInfo(rank: HunterRank.ssp,       label: 'SS+',       color: Color(0xFFFF80C0),       xpRequired: 800000),
  RankInfo(rank: HunterRank.sss,       label: 'SSS',       color: Color(0xFFFFFFFF),       xpRequired: 1000000),
];

/// Restituisce il [RankInfo] corrente dato l'XP totale.
RankInfo getRankFromXp(int totalXp) {
  RankInfo current = kRanks.first;
  for (final r in kRanks) {
    if (totalXp >= r.xpRequired) current = r;
    else break;
  }
  return current;
}

/// XP necessari per il rank successivo (null se già SSS).
int? xpToNextRank(int totalXp) {
  for (int i = 0; i < kRanks.length - 1; i++) {
    if (totalXp < kRanks[i + 1].xpRequired) {
      return kRanks[i + 1].xpRequired - totalXp;
    }
  }
  return null;
}

/// Percentuale [0.0 – 1.0] di avanzamento verso il rank successivo.
double rankProgress(int totalXp) {
  for (int i = 0; i < kRanks.length - 1; i++) {
    final cur  = kRanks[i].xpRequired;
    final next = kRanks[i + 1].xpRequired;
    if (totalXp < next) {
      return (totalXp - cur) / (next - cur);
    }
  }
  return 1.0;
}

// ─── TIER MUSCOLI ─────────────────────────────────────────────────────────────
// Il tier di ogni muscolo si basa sul volume cumulativo (kg × reps).

enum MuscleTier {
  unranked, bronze, silver, gold, platinum, diamond, ruby, crystal, elite, champion, celestial, titan,
}

class MuscleTierInfo {
  final MuscleTier tier;
  final String label;
  final Color color;
  final int minVolume; // kg cumulativi per raggiungere questo tier

  const MuscleTierInfo({
    required this.tier,
    required this.label,
    required this.color,
    required this.minVolume,
  });
}

const List<MuscleTierInfo> kMuscleTiers = [
  MuscleTierInfo(tier: MuscleTier.unranked,  label: 'Unranked',  color: AppColors.tierUnranked,  minVolume: 0),
  MuscleTierInfo(tier: MuscleTier.bronze,    label: 'Bronze',    color: AppColors.tierBronze,    minVolume: 1000),
  MuscleTierInfo(tier: MuscleTier.silver,    label: 'Silver',    color: AppColors.tierSilver,    minVolume: 5000),
  MuscleTierInfo(tier: MuscleTier.gold,      label: 'Gold',      color: AppColors.tierGold,      minVolume: 20000),
  MuscleTierInfo(tier: MuscleTier.platinum,  label: 'Platinum',  color: AppColors.tierPlatinum,  minVolume: 60000),
  MuscleTierInfo(tier: MuscleTier.diamond,   label: 'Diamond',   color: AppColors.tierDiamond,   minVolume: 120000),
  MuscleTierInfo(tier: MuscleTier.ruby,      label: 'Ruby',      color: AppColors.tierRuby,      minVolume: 240000),
  MuscleTierInfo(tier: MuscleTier.crystal,   label: 'Crystal',   color: AppColors.tierCrystal,   minVolume: 480000),
  MuscleTierInfo(tier: MuscleTier.elite,     label: 'Elite',     color: AppColors.tierElite,     minVolume: 700000),
  MuscleTierInfo(tier: MuscleTier.champion,  label: 'Champion',  color: AppColors.tierChampion,  minVolume: 1200000),
  MuscleTierInfo(tier: MuscleTier.celestial, label: 'Celestial', color: AppColors.tierCelestial, minVolume: 1900000),
  MuscleTierInfo(tier: MuscleTier.titan,     label: 'Titan',     color: AppColors.tierTitan,     minVolume: 2400000),
];

/// Restituisce il [MuscleTierInfo] dato il volume cumulativo del muscolo.
MuscleTierInfo getTierFromVolume(int volume) {
  MuscleTierInfo current = kMuscleTiers.first;
  for (final t in kMuscleTiers) {
    if (volume >= t.minVolume) current = t;
    else break;
  }
  return current;
}

/// Percentuale [0.0 – 1.0] di avanzamento verso il tier successivo.
double tierProgress(int volume) {
  for (int i = 0; i < kMuscleTiers.length - 1; i++) {
    final cur  = kMuscleTiers[i].minVolume;
    final next = kMuscleTiers[i + 1].minVolume;
    if (volume < next) {
      return (volume - cur) / (next - cur);
    }
  }
  return 1.0;
}

// ─── XP PER SESSIONE ──────────────────────────────────────────────────────────
// Formula: ogni kg sollevato (peso × reps) = 0.03 XP, arrotondato all'intero.

int calculateSessionXp(int totalVolumeKg) => (totalVolumeKg * 0.03).round();

// ─── MUSCOLI DISPONIBILI ──────────────────────────────────────────────────────
const List<String> kMuscleGroups = [
  'pettorali',
  'spalle',
  'bicipiti',
  'tricipiti',
  'avambracci',
  'addominali',
  'dorsali',
  'trapezi',
  'lombari',
  'glutei',
  'quadricipiti',
  'femorali',
  'polpacci',
];