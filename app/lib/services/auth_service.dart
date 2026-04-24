import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_bootstrap.dart';

class AppUser {
  final String uid;
  final String? email;

  const AppUser({required this.uid, required this.email});
}

class AuthService {
  Future<void> _ensureUserDoc({required AppUser user}) async {
    if (!FirebaseBootstrap.isReady) return;

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snap = await ref.get();

      if (!snap.exists) {
        await ref.set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        return;
      }

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

  Stream<AppUser?> authStateChanges() {
    if (!FirebaseBootstrap.isReady) {
      return const Stream<AppUser?>.empty();
    }

    return FirebaseAuth.instance.authStateChanges().map(
          (u) => u == null ? null : AppUser(uid: u.uid, email: u.email),
        );
  }

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

  Future<void> signOut() async {
    if (!FirebaseBootstrap.isReady) return;
    await FirebaseAuth.instance.signOut();
  }
}
