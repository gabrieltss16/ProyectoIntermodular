import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import 'firebase_bootstrap.dart';

class UserProfileRepository {
  Future<UserProfile> getByUid({required String uid}) async {
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase no está configurado todavía.');
    }

    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) return UserProfile.empty();
    return UserProfile.fromJson(data);
  }

  Future<void> upsert({required String uid, required UserProfile profile}) async {
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase no está configurado todavía.');
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        ...profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
