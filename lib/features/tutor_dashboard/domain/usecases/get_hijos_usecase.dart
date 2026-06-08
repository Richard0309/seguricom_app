import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alumno_entity.dart';
import '../repositories/tutor_repository.dart';

/// Caso de uso: obtiene la lista de hijos registrados de un tutor.
///
/// Retorna [List<AlumnoEntity>] (puede ser vacía) o un [Failure].
class GetHijosUseCase {
  final TutorRepository _repository;

  const GetHijosUseCase(this._repository);

  Future<Either<Failure, List<AlumnoEntity>>> call(String tutorUid) {
    return _repository.getHijos(tutorUid);
  }
}
