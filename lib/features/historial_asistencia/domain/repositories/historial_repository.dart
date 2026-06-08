import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/asistencia_entity.dart';

/// Contrato del repositorio de historial para la capa de dominio.
/// La implementación concreta vive en la capa de datos.
abstract class HistorialRepository {
  /// Retorna el historial de asistencias del alumno identificado por [idAlumno],
  /// ordenado cronológicamente de forma descendente (más reciente primero).
  /// Retorna una lista vacía si el alumno no tiene registros.
  Future<Either<Failure, List<AsistenciaEntity>>> getHistorial(
      String idAlumno);
}
