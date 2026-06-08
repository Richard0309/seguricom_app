import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/permiso_entity.dart';
import '../repositories/permisos_repository.dart';

/// Caso de uso: envía un permiso de salud (justificante médico).
///
/// Retorna el ID del documento creado en caso de éxito, o un [Failure].
class SolicitarPermisoUseCase {
  final PermisosRepository _repository;

  const SolicitarPermisoUseCase(this._repository);

  Future<Either<Failure, String>> call(PermisoEntity permiso) {
    return _repository.solicitarPermiso(permiso);
  }
}
