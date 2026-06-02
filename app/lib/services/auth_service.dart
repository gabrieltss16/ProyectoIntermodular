import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_bootstrap.dart';

// Clase auxiliar que expone solo los datos del usuario que necesita la app.
// Evitamos exponer directamente el objeto User de Firebase (encapsulamiento).
class AppUser {
  final String uid;    // ID único del usuario en Firebase (nunca cambia)
  final String? email; // Email del usuario (puede ser null con auth anónima)

  const AppUser({required this.uid, required this.email});
}

// AuthService centraliza todas las operaciones de autenticación.
// Equivale a un AuthRepository o AuthManager en Android/Kotlin.
class AuthService {
  // GoogleSignIn gestiona el flujo OAuth 2.0 con Google.
  // scopes: solo pedimos el email (menos permisos = mejor privacidad).
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
  );

  // Crea o actualiza el documento del usuario en Firestore al iniciar sesión.
  // Se llama cada vez que el usuario se loguea (primer login o logins posteriores).
  // Es 'best-effort': si Firestore falla no bloqueamos el login.
  Future<void> _ensureUserDoc({required AppUser user}) async {
    if (!FirebaseBootstrap.isReady) return;

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snap = await ref.get();

      if (!snap.exists) {
        // Primera vez: crea el documento con fecha de creación.
        // FieldValue.serverTimestamp() usa el reloj del servidor de Firebase,
        // no el del dispositivo (más fiable y resistente a cambios de hora del móvil).
        await ref.set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Logins posteriores: solo actualiza 'lastLoginAt'.
      // SetOptions(merge: true) hace un merge parcial: sólo actualiza los campos
      // indicados sin borrar el resto del documento (como un PATCH en REST).
      await ref.set(
        {
          'email': user.email,
          'lastLoginAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Best-effort: no bloqueamos el login si Firestore falla.
    }
  }

  // Stream que emite eventos cuando cambia el estado de autenticación.
  // En Android sería equivalente a un LiveData<FirebaseUser?> o AuthStateListener.
  // Emite: AppUser (si hay sesión activa) o null (si no hay sesión).
  // Si Firebase no está listo, devuelve un Stream vacío para no romper los listeners.
  Stream<AppUser?> authStateChanges() {
    if (!FirebaseBootstrap.isReady) {
      return const Stream<AppUser?>.empty();
    }

    return FirebaseAuth.instance.authStateChanges().map(
          (u) => u == null ? null : AppUser(uid: u.uid, email: u.email),
        );
  }

  // Devuelve el usuario actual de forma síncrona (sin await).
  // Útil cuando solo queremos el UID para operaciones puntuales.
  AppUser? currentUser() {
    if (!FirebaseBootstrap.isReady) return null;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return null;
    return AppUser(uid: u.uid, email: u.email);
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase no está configurado todavía.');
    }

    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final u = cred.user;
    if (u == null) throw StateError('Login fallido.');
    final user = AppUser(uid: u.uid, email: u.email);
    await _ensureUserDoc(user: user);
    return user;
  }

  Future<AppUser> register({required String email, required String password}) async {
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase no está configurado todavía.');
    }

    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final u = cred.user;
    if (u == null) throw StateError('Registro fallido.');
    final user = AppUser(uid: u.uid, email: u.email);
    await _ensureUserDoc(user: user);
    return user;
  }

  Future<AppUser> signInWithGoogle() async {
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase no está configurado todavía.');
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('Inicio de sesión con Google cancelado.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null) {
      throw StateError('No se pudo obtener el token de Google.');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await FirebaseAuth.instance.signInWithCredential(credential);
    final u = cred.user;
    if (u == null) throw StateError('Login con Google fallido.');

    final user = AppUser(uid: u.uid, email: u.email);
    await _ensureUserDoc(user: user);
    return user;
  }

  Future<void> sendEmailVerification() async {
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase no está configurado todavía.');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado para verificar.');
    }

    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  Future<bool> isCurrentUserEmailVerified() async {
    if (!FirebaseBootstrap.isReady) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    // user.reload() fuerza la recarga del estado desde Firebase.
    // Sin reload(), emailVerified puede estar cacheado y dar false aunque ya se verificó.
    await user.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    if (!FirebaseBootstrap.isReady) return;
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignored: logout still continues with Firebase signOut.
    }
    await FirebaseAuth.instance.signOut();
  }
}
