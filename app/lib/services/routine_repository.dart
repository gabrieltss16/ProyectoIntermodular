import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine.dart';
import 'firebase_bootstrap.dart';
import 'routine_storage.dart';

// RoutineRepository implementa el patrón Repository:
// el resto de la app pide datos aquí y no sabe dónde están guardados.
//
// Ruta dual (dual-path):
//   - Si hay sesión activa Y Firebase está listo → usa Firestore (nube)
//   - Si no hay sesión o Firebase falló              → usa RoutineStorage (local)
//
// Esto hace la app resiliente: funciona sin internet y sin cuenta.
class RoutineRepository {
  // Instancia del almacenamiento local (SharedPreferences).
  final _local = RoutineStorage();

  // Lista las rutinas del usuario.
  // uid es el User ID de Firebase Auth. Si es null = modo invitado o sin sesión.
  Future<List<Routine>> list({required String? uid}) async {
    if (uid != null && FirebaseBootstrap.isReady) {
      // Ruta Firestore: coleción anidada users/{uid}/routines
      // ordenada por fecha de creación descendente (más reciente primero).
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
    // Ruta local: SharedPreferences (modo offline o invitado)
    return _local.list();
  }

  // Guarda o actualiza una rutina (upsert = insert OR update según si el ID ya existe).
  // Firestore: .set() reemplaza el documento completo con el ID dado.
  Future<void> upsert({required String? uid, required Routine routine}) async {
    if (uid != null && FirebaseBootstrap.isReady) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('routines')
          .doc(routine.id) // El ID del documento es el mismo que routine.id
          .set(routine.toJson());
      return;
    }
    // Sin sesión: guarda en SharedPreferences
    await _local.upsert(routine);
  }

  // Elimina una rutina por su ID.
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
    // Sin sesión: elimina de SharedPreferences
    await _local.deleteById(id);
  }
}
