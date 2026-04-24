import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine.dart';
import 'firebase_bootstrap.dart';
import 'routine_storage.dart';

class RoutineRepository {
  final _local = RoutineStorage();

  Future<List<Routine>> list({required String? uid}) async {
    if (uid != null && FirebaseBootstrap.isReady) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('routines')
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs
          .map((d) => Routine.fromJson(d.data()).copyWith())
          .toList();
    }

    return _local.list();
  }

  Future<void> upsert({required String? uid, required Routine routine}) async {
    if (uid != null && FirebaseBootstrap.isReady) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('routines')
          .doc(routine.id)
          .set(routine.toJson());
      return;
    }

    await _local.upsert(routine);
  }

  Future<void> deleteById({required String? uid, required String id}) async {
    if (uid != null && FirebaseBootstrap.isReady) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('routines')
          .doc(id)
          .delete();
      return;
    }

    await _local.deleteById(id);
  }
}
