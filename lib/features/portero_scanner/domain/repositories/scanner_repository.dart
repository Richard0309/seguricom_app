import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/asistencia_entity.dart';

/// Contrato que define las operaciones de escaneo y registro de asistencia.
///
/// La implementación concreta vive en la capa de datos
/// (`scanner_repository_impl.dart`). Al depender de esta abstracción,
/// la capa de dominio permanece desacoplada de Firebase.
abstract class ScannerRepository {
  /// Valida que el [idAlumno] exista en la colección `alumnos` de Firestore,
  /// determina el tipo de registro (`entrada` o `salida`) según el historial
  /// del día y escribe el nuevo documento en la colección `asistencias`.
  ///
  /// Retorna:
  /// - [Right<AsistenciaEntity>]  con los datos del registro creado.
  /// - [Left<NotFoundFailure>]    si el QR no corresponde a ningún alumno.
  /// - [Left<ServerFailure>]      ante cualquier error de comunicación con Firestore.
  Future<Either<Failure, AsistenciaEntity>> validarYRegistrarAsistencia(
    String idAlumno,
  );
}
