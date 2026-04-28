import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import '../models/app_user.dart';

/// Service d'authentification Use Me.
///
/// Étend BaseAuthService pour utiliser AppUser au lieu de BaseUser.
class UseMeAuthService extends BaseAuthService {
  /// Utilisateur Use Me actuellement connecté.
  AppUser? get appUser => currentUser as AppUser?;

  @override
  Future<BaseUser?> getUserFromFirestore(String uid) async {
    final doc = await SmoothFirebase.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  /// Sentinel détectant les appels qui n'ont PAS passé `role` explicitement.
  /// `BaseUserRole.user` n'est jamais utilisé en useme (on a admin/superAdmin/
  /// worker/client) — donc s'il arrive ici, c'est qu'on est dans un code path
  /// du package partagé qui appelle sans rôle (ex. base_auth_service.dart
  /// signInWithEmail L133, qui crée un doc minimal si Firestore manque).
  static const BaseUserRole _missingRoleSentinel = BaseUserRole.user;

  @override
  Future<void> saveUserToFirestore(
    User firebaseUser, {
    String? name,
    BaseUserRole role = _missingRoleSentinel,
    Map<String, dynamic>? extraData,
  }) async {
    var safeRole = role;
    if (role == _missingRoleSentinel) {
      // Aucun rôle passé explicitement — on tombe ici uniquement quand le
      // package partagé crée un doc minimal en cas de désynchro Auth/Firestore
      // (cf. base_auth_service.signInWithEmail L133). On fallback en `client`
      // (rôle le moins privilégié), mais on log à Crashlytics et on garde
      // isFirstTime=true (default AppUser) pour que le RoleSelector relance.
      final crashlytics = FirebaseCrashlytics.instance;
      crashlytics.log(
        '[Auth] saveUserToFirestore called WITHOUT explicit role for '
        '${firebaseUser.email} — falling back to client',
      );
      crashlytics.recordError(
        StateError('saveUserToFirestore called without role'),
        StackTrace.current,
        reason: 'Missing role on user creation: ${firebaseUser.email}',
        fatal: false,
      );
      safeRole = BaseUserRole.client;
    }

    final appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: name ?? firebaseUser.displayName ?? firebaseUser.email?.split('@')[0],
      displayName: firebaseUser.displayName ?? name,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      role: safeRole,
      createdAt: DateTime.now(),
      studioId: extraData?['studioId'],
      studioIds: List<String>.from(extraData?['studioIds'] ?? []),
      stageName: extraData?['stageName'],
      genres: List<String>.from(extraData?['genres'] ?? []),
      bio: extraData?['bio'],
      city: extraData?['city'],
    );

    await SmoothFirebase.collection('users').doc(firebaseUser.uid).set(appUser.toMap());
  }

  @override
  Future<SmoothResponse<bool>> signInWithGoogle() async {
    final crashlytics = FirebaseCrashlytics.instance;
    crashlytics.log('[Auth] signInWithGoogle started');
    final result = await super.signInWithGoogle();
    if (result.isSuccess) {
      crashlytics.log('[Auth] Google sign-in success (code ${result.code})');
    } else {
      crashlytics.log('[Auth] Google sign-in failed: ${result.message} (code ${result.code})');
    }
    return result;
  }

  @override
  Future<SmoothResponse<bool>> signInWithApple() async {
    final crashlytics = FirebaseCrashlytics.instance;
    crashlytics.log('[Auth] signInWithApple started');
    final result = await super.signInWithApple();
    if (result.isSuccess) {
      crashlytics.log('[Auth] Apple sign-in success (code ${result.code})');
    } else {
      crashlytics.log('[Auth] Apple sign-in failed: ${result.message} (code ${result.code})');
    }
    return result;
  }

  @override
  Future<SmoothResponse<bool>> signInWithEmail(String email, String password) async {
    final crashlytics = FirebaseCrashlytics.instance;
    crashlytics.log('[Auth] signInWithEmail started');
    final result = await super.signInWithEmail(email, password);
    if (result.isSuccess) {
      crashlytics.log('[Auth] Email sign-in success');
    } else {
      crashlytics.log('[Auth] Email sign-in failed: ${result.message} (code ${result.code})');
    }
    return result;
  }

  /// Met à jour le profil de l'utilisateur.
  Future<SmoothResponse<bool>> updateUserProfile(AppUser user) async {
    try {
      await SmoothFirebase.collection('users').doc(user.uid).update(user.toMap());
      await reloadUser();
      return SmoothResponse(data: true, message: 'Profil mis à jour', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Met à jour le rôle de l'utilisateur.
  Future<SmoothResponse<bool>> updateUserRole(String userId, BaseUserRole role) async {
    try {
      await SmoothFirebase.collection('users').doc(userId).update({'role': role.name});
      return SmoothResponse(data: true, message: 'Rôle mis à jour', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Lie un artiste à un studio.
  Future<SmoothResponse<bool>> linkArtistToStudio(String artistId, String studioId) async {
    try {
      await SmoothFirebase.collection('users').doc(artistId).update({
        'studioIds': FieldValue.arrayUnion([studioId]),
      });
      return SmoothResponse(data: true, message: 'Artiste lié au studio', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Assigne un ingénieur à un studio.
  Future<SmoothResponse<bool>> assignEngineerToStudio(String engineerId, String studioId) async {
    try {
      await SmoothFirebase.collection('users').doc(engineerId).update({
        'studioId': studioId,
      });
      return SmoothResponse(data: true, message: 'Ingénieur assigné', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }
}
