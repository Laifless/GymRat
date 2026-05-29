# 🏋️ The Big Gym

> Traccia il tuo allenamento. Sali di rank. Diventa leggenda.

Un gym tracker open source costruito con Flutter, con sistema di progressione RPG, muscle map anatomica e sync cloud su tutti i dispositivi.

---

## Screenshots

| Boot | Home | Workout | Muscoli | Impostazioni |
|------|------|---------|---------|--------------|
| Animazione terminale tematica | Profilo hunter + XP + stats | Timer live + log serie | Muscle map anatomica | Cambio tema + profilo |

---

## Funzionalità

- **Sistema RPG** — accumula XP completando sessioni, sali di rank da Iron fino a SSS
- **Muscle Map** — corpo anatomico anteriore e posteriore con tier per ogni muscolo (Bronze → Titan)
- **Workout Logger** — traccia esercizi, serie, peso e reps con timer live
- **4 temi** — Solo Leveling, Militare, Minimal, Medievale (ogni tema cambia anche il linguaggio dell'app)
- **Auth completa** — Google, Apple, Email/Password
- **Sync cloud** — dati sincronizzati su Firestore su tutti i dispositivi
- **Onboarding** — scelta nickname al primo accesso
- **Crash recovery** — sessione attiva recuperata al riavvio dell'app

---

## Stack tecnico

| Layer | Tecnologia |
|-------|-----------|
| Framework | Flutter 3.x |
| State management | Provider |
| Auth | Firebase Auth |
| Database cloud | Cloud Firestore |
| Database locale | SharedPreferences |
| Font | Google Fonts (Rajdhani, Cinzel, Oswald, DM Sans) |
| Auth providers | Google Sign In, Sign In With Apple |

---

## Struttura progetto

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Palette 4 temi
│   │   ├── app_themes.dart         # ThemeData Flutter
│   │   └── app_typography.dart     # Font per tema
│   ├── constants/
│   │   └── rank_constants.dart     # Soglie XP, rank, tier muscoli
│   └── providers/
│       ├── theme_provider.dart     # Tema attivo
│       ├── hunter_provider.dart    # Profilo + muscoli
│       └── workout_provider.dart   # Sessione attiva + storico
├── models/
│   ├── hunter.dart
│   ├── workout_session.dart
│   ├── exercise.dart
│   ├── exercise_set.dart
│   └── muscle_data.dart
└── screens/
    ├── auth_provider.dart
    ├── sync_service.dart
    ├── main_shell.dart
    ├── boot/
    ├── login/
    ├── onboarding/
    ├── home/
    ├── workout/
    ├── muscles/
    └── settings/
```

---

## Setup

### Prerequisiti

- Flutter SDK 3.x
- Node.js 18+
- Firebase CLI
- Un progetto Firebase

### 1. Clona il repo

```bash
git clone https://github.com/tuonome/the-big-gym.git
cd the-big-gym
```

### 2. Installa le dipendenze

```bash
flutter pub get
```

### 3. Configura Firebase

Installa FlutterFire CLI:
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Genera la configurazione:
```bash
flutterfire configure --project=ID-DEL-TUO-PROGETTO
```

Questo genera automaticamente `lib/firebase_options.dart`.

### 4. Abilita i metodi di autenticazione

Su [Firebase Console](https://console.firebase.google.com) → Authentication → Sign-in method:
- ✅ Google
-  Apple (Non ancora testato)
- ✅ Email/Password

### 5. Aggiungi le credenziali Android

```bash
cd android
gradlew signingReport
```

Copia la SHA-1 e aggiungila su Firebase Console → Impostazioni progetto → App Android.

### 6. Configura Google Sign In Web (solo sviluppo locale)

Su [Google Cloud Console](https://console.cloud.google.com) → API e servizi → Credenziali → OAuth 2.0 Client ID Web → Origini JavaScript autorizzate:
```
http://localhost
http://localhost:8080
```

### 7. Avvia l'app

```bash
flutter run
```

---

## Sistema di rank

| Rank | XP richiesti |
|------|-------------|
| Iron | 0 |
| Bronze | 1.000 |
| Silver | 3.000 |
| Gold | 7.000 |
| Platinum | 15.000 |
| Diamond | 30.000 |
| Ruby | 55.000 |
| Crystal | 90.000 |
| Elite | 140.000 |
| Champion | 210.000 |
| Celestial | 300.000 |
| Titan | 420.000 |
| SS | 600.000 |
| SS+ | 800.000 |
| SSS | 1.000.000 |

**Formula XP:** `volume sessione (kg) × 0.03`

---

## Tier muscoli

| Tier | Volume cumulativo |
|------|------------------|
| Unranked | 0 kg |
| Bronze | 1.000 kg |
| Silver | 5.000 kg |
| Gold | 20.000 kg |
| Platinum | 60.000 kg |
| Diamond | 120.000 kg |
| Ruby | 240.000 kg |
| Crystal | 480.000 kg |
| Elite | 700.000 kg |
| Champion | 1.200.000 kg |
| Celestial | 1.900.000 kg |
| Titan | 2.400.000 kg |

---

## Temi

| Tema | Vibe | Font titoli |
|------|------|-------------|
| Solo Leveling | Dark · Oro · RPG | Rajdhani |
| Militare | Verde oliva · Tattico | Oswald |
| Minimal | Light mode · Pulito | DM Sans |
| Medievale | Pergamena · Rune | Cinzel |

---

## Contribuire

Pull request benvenute! Per cambiamenti importanti apri prima una issue per discutere cosa vorresti modificare.

---

## Licenza

© 2025 Laifless. Tutti i diritti riservati.

Il codice sorgente, il design e i contenuti di questo progetto sono proprietà esclusiva dell'autore.
È vietata la copia, la modifica, la distribuzione o l'uso commerciale senza esplicito permesso scritto.
