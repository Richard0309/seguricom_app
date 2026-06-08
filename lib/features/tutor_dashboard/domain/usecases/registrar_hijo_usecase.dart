import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alumno_entity.dart';
import '../repositories/tutor_repository.dart';

/// Caso de uso: registra un nuevo hijo y lo vincula al tutor.
///
/// Retorna [void] en caso de éxito o un [Failure].
class RegistrarHijoUseCase {
  final TutorRepository _repository;

  const RegistrarHijoUseCase(this._repository);

  Future<Either<Failure, void>> call(String tutorUid, AlumnoEntity alumno) {
    return _repository.registrarHijo(tutorUid, alumno);
  }
}
