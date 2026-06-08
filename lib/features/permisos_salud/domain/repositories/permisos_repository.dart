import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/permiso_entity.dart';

/// Contrato del repositorio de permisos de salud para la capa de dominio.
/// La implementación concreta vive en la capa de datos.
abstract class PermisosRepository {
  /// Envía un nuevo permiso de salud (justificante médico) a Firestore.
  /// Retorna el ID del documento creado en caso de éxito, o un [Failure].
  Future<Either<Failure, String>> solicitarPermiso(PermisoEntity permiso);
}
