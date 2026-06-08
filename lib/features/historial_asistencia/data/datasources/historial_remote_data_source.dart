import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/asistencia_model.dart';

/// Contrato del origen de datos remoto del historial de asistencias.
abstract class HistorialRemoteDataSource {
  /// Obtiene todos los registros de asistencia del alumno [idAlumno]
  /// ordenados por fecha descendente (más reciente primero).
  /// Lanza [ServerException] ante cualquier error de red o Firestore.
  Future<List<AsistenciaModel>> getHistorial(String idAlumno);
}

class HistorialRemoteDataSourceImpl implements HistorialRemoteDataSource {
  final FirebaseFirestore _firestore;

  const HistorialRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<AsistenciaModel>> getHistorial(String idAlumno) async {
    try {
      final snapshot = await _firestore
          .collection('asistencias')
          .where('idAlumno', isEqualTo: idAlumno)
          .orderBy('serverTimestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AsistenciaModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener el historial: $e');
    }
  }
}
