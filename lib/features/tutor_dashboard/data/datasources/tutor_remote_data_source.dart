import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/alumno_model.dart';

/// Contrato del origen de datos remoto del tutor.
abstract class TutorRemoteDataSource {
  /// Obtiene los hijos del tutor [tutorUid] desde Firestore.
  /// Retorna lista vacía si el tutor no tiene hijos.
  /// Lanza [ServerException] ante cualquier error de red o Firestore.
  Future<List<AlumnoModel>> getHijos(String tutorUid);

  /// Registra [alumno] en la colección `alumnos` y vincula su ID al tutor
  /// [tutorUid] en la colección `usuarios` usando un [WriteBatch] atómico.
  /// Lanza [ServerException] ante cualquier error.
  Future<void> registrarHijo(String tutorUid, AlumnoModel alumno);
}

class TutorRemoteDataSourceImpl implements TutorRemoteDataSource {
  final FirebaseFirestore _firestore;

  const TutorRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<AlumnoModel>> getHijos(String tutorUid) async {
    try {
      // ── 1. Obtener el documento del tutor para leer su array de hijos ────
      print('🔍 [DEBUG DATASOURCE] Ejecutando getHijos para UID: $tutorUid');
      final tutorDoc =
          await _firestore.collection('usuarios').doc(tutorUid).get();

      if (!tutorDoc.exists) {
        print('⚠️ [DEBUG DATASOURCE] El documento del tutor NO EXISTE en Firestore.');
        throw const ServerException('Perfil de tutor no encontrado.');
      }

      final data = tutorDoc.data();
      // Cast explícito a List<String>; el SDK nativo de Firestore falla al
      // parsear los argumentos de whereIn si recibe un List<dynamic>.
      final List<String> hijosIds = List<String>.from(
        (data?['hijos'] as List<dynamic>?) ?? [],
      );

     

      // ── 2. Si el array está vacío, retornar lista vacía sin consultar ────
      if (hijosIds.isEmpty) {
        print('🟢 [DEBUG DATASOURCE] Array vacío. Retornando lista vacía.');
        return [];
      }

      // ── 3. Firestore limita whereIn a 30 elementos por consulta ─────────
      //       Dividimos en chunks de 30 para respetar el límite.
      final List<AlumnoModel> alumnos = [];
      const int chunkSize = 30;

      for (int i = 0; i < hijosIds.length; i += chunkSize) {
        final chunk = hijosIds.sublist(
          i,
          (i + chunkSize) < hijosIds.length ? i + chunkSize : hijosIds.length,
        );

        final snapshot = await _firestore
            .collection('alumnos')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        alumnos.addAll(
          snapshot.docs.map(
            (doc) => AlumnoModel.fromJson(doc.id, doc.data()),
          ),
        );
      }

      return alumnos;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Error de Firestore inesperado.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> registrarHijo(String tutorUid, AlumnoModel alumno) async {
    try {
      print('🚀 [DEBUG DATASOURCE] Iniciando registrarHijo para UID: $tutorUid');
      // ── 1. Generar una nueva referencia con ID auto-generado ─────────────
      final nuevoAlumnoRef = _firestore.collection('alumnos').doc();
      final nuevoId = nuevoAlumnoRef.id;

      // ── 2. Asignar el ID generado al modelo ──────────────────────────────
      final alumnoConId = alumno.copyWith(idAlumno: nuevoId);

      print('📝 [DEBUG DATASOURCE] Datos a guardar: ${alumnoConId.toJson()}');

      // ── 3. Referencia al documento del tutor ─────────────────────────────
      final tutorRef = _firestore.collection('usuarios').doc(tutorUid);

      // ── 4. WriteBatch atómico ─────────────────────────────────────────────
      final batch = _firestore.batch();

      // Crea el documento del alumno con su ID asignado
      batch.set(nuevoAlumnoRef, alumnoConId.toJson());

      // Añade el nuevo ID al array `hijos` del tutor sin sobrescribir los existentes
      batch.update(tutorRef, {
        'hijos': FieldValue.arrayUnion([nuevoId]),
      });

      await batch.commit();
      print('✅ [DEBUG DATASOURCE] Batch commit exitoso. Hijo guardado.');
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Error de Firestore inesperado.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
