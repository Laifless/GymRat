import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/hunter.dart';
import '../../models/muscle_data.dart';
import '../../models/workout_session.dart';

/// Gestisce la sincronizzazione con Firestore.
/// Struttura collezioni:
///   users/{uid}/
///     profile     → Hunter + MuscleData
///     sessions/{sessionId} → WorkoutSession
class SyncService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference? get _profileRef => _uid != null
      ? _db.collection('users').doc(_uid).collection('data').doc('profile')
      : null;

  CollectionReference? get _sessionsRef => _uid != null
      ? _db.collection('users').doc(_uid).collection('sessions')
      : null;

  // ─── Profile ───────────────────────────────────────────

  /// Salva hunter + muscoli su Firestore.
  Future<void> saveProfile({
    required Hunter hunter,
    required Map<String, MuscleData> muscles,
  }) async {
    if (_profileRef == null) return;
    await _profileRef!.set({
      'hunter':    hunter.toJson(),
      'muscles':   muscles.map((k, v) => MapEntry(k, v.toJson())),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Carica hunter + muscoli da Firestore.
  /// Ritorna null se il documento non esiste.
  Future<Map<String, dynamic>?> loadProfile() async {
    if (_profileRef == null) return null;
    final snap = await _profileRef!.get();
    if (!snap.exists) return null;
    return snap.data() as Map<String, dynamic>;
  }

  /// Stream in tempo reale del profilo (per sync live).
  Stream<Map<String, dynamic>?> profileStream() {
    if (_profileRef == null) return const Stream.empty();
    return _profileRef!.snapshots().map((snap) {
      if (!snap.exists) return null;
      return snap.data() as Map<String, dynamic>;
    });
  }

  // ─── Sessions ──────────────────────────────────────────

  /// Salva una singola sessione su Firestore.
  Future<void> saveSession(WorkoutSession session) async {
    if (_sessionsRef == null) return;
    await _sessionsRef!.doc(session.id).set(session.toJson());
  }

  /// Carica tutte le sessioni ordinate per data (più recente prima).
  Future<List<WorkoutSession>> loadSessions() async {
    if (_sessionsRef == null) return [];
    final snap = await _sessionsRef!
        .orderBy('startTime', descending: true)
        .get();
    return snap.docs
        .map((d) => WorkoutSession.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Stream delle sessioni in tempo reale.
  Stream<List<WorkoutSession>> sessionsStream() {
    if (_sessionsRef == null) return const Stream.empty();
    return _sessionsRef!
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WorkoutSession.fromJson(d.data() as Map<String, dynamic>))
            .toList());
  }

  // ─── Nickname / Onboarding ─────────────────────────────

  /// Controlla se il profilo esiste già su Firestore
  /// (usato per sapere se mostrare l'onboarding nickname).
  Future<bool> profileExists() async {
    if (_profileRef == null) return false;
    final snap = await _profileRef!.get();
    return snap.exists;
  }

  /// Crea il profilo iniziale con il nickname scelto.
  Future<void> createProfile({
    required String nickname,
    required String? photoUrl,
  }) async {
    if (_profileRef == null) return;
    final hunter = Hunter.initial.copyWith(name: nickname);
    await _profileRef!.set({
      'hunter':    hunter.toJson(),
      'muscles':   {},
      'photoUrl':  photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Merge locale ↔ cloud ──────────────────────────────

  /// Confronta i dati locali con quelli cloud e restituisce
  /// la versione più aggiornata (vince chi ha più XP/sessioni).
  static Map<String, dynamic> mergeProfiles(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final localHunter  = Hunter.fromJson(local['hunter'] as Map<String, dynamic>);
    final remoteHunter = Hunter.fromJson(remote['hunter'] as Map<String, dynamic>);

    // Vince il profilo con più dati
    if (remoteHunter.totalXp >= localHunter.totalXp) return remote;
    return local;
  }
}