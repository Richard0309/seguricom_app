import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/asistencia_entity.dart';

/// Contrato del origen de datos remoto para el módulo portero_scanner.
abstract class ScannerRemoteDataSource {
  /// Valida al alumno, determina el tipo de registro y escribe en Firestore.
  ///
  /// Lanza [NotFoundException] si [idAlumno] no existe en `alumnos`.
  /// Lanza [ServerException] ante cualquier fallo de Firestore / red.
  Future<AsistenciaEntity> registrarAsistencia(String idAlumno);
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final FirebaseFirestore _firestore;

  const ScannerRemoteDataSourceImpl(this._firestore);

  @override
  Future<AsistenciaEntity> registrarAsistencia(String idAlumno) async {
    try {
      // ── (a) Verificar que el alumno exista ───────────────────────────────
      final alumnoDoc =
          await _firestore.collection('alumnos').doc(idAlumno).get();

      if (!alumnoDoc.exists) {
        throw const NotFoundException('QR Inválido o Alumno no encontrado');
      }

      // ── (b) Determinar tipo: 'entrada' o 'salida' ────────────────────────
      final fechaHoy = _fechaHoy();

      final snapshot = await _firestore
          .collection('asistencias')
          .where('idAlumno', isEqualTo: idAlumno)
          .where('fecha', isEqualTo: fechaHoy)
          .get();

      final tieneEntrada =
          snapshot.docs.any((doc) => doc.data()['tipo'] == 'entrada');
      final tipo = tieneEntrada ? 'salida' : 'entrada';

      // ── (c) Registrar el nuevo documento ─────────────────────────────────
      final horaActual = _horaActual();

      await _firestore.collection('asistencias').add({
        'idAlumno': idAlumno,
        'fecha': fechaHoy,
        'hora': horaActual,
        'tipo': tipo,
        'serverTimestamp': FieldValue.serverTimestamp(),
      });

      return AsistenciaEntity(
        idAlumno: idAlumno,
        fecha: fechaHoy,
        hora: horaActual,
        tipo: tipo,
      );
    } on NotFoundException {
      // Se relanza para que RepositoryImpl la mapee a NotFoundFailure
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Error de Firestore desconocido.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Helpers de fecha/hora ─────────────────────────────────────────────────

  /// Retorna la fecha de hoy como `AAAA-MM-DD` (ej. `2026-06-08`).
  String _fechaHoy() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Retorna la hora actual como `HH:MM:SS` (ej. `07:45:30`).
  String _horaActual() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }
}
