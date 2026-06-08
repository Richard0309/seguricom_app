import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/asistencia_entity.dart';
import '../repositories/historial_repository.dart';

/// Caso de uso: obtiene el historial de asistencias de un alumno.
///
/// Retorna [List<AsistenciaEntity>] ordenada por fecha descendente,
/// o un [Failure] si ocurre un error en la fuente de datos.
class GetHistorialUseCase {
  final HistorialRepository _repository;

  const GetHistorialUseCase(this._repository);

  Future<Either<Failure, List<AsistenciaEntity>>> call(String idAlumno) {
    return _repository.getHistorial(idAlumno);
  }
}
