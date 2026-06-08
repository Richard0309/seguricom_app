import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alumno_entity.dart';

/// Contrato del repositorio de tutor para la capa de dominio.
/// La implementación concreta vive en la capa de datos.
abstract class TutorRepository {
  /// Retorna la lista de hijos del tutor identificado por [tutorUid].
  /// Retorna una lista vacía si el tutor no tiene hijos registrados.
  Future<Either<Failure, List<AlumnoEntity>>> getHijos(String tutorUid);

  /// Registra un nuevo [alumno] y lo vincula al tutor [tutorUid].
  /// La operación es atómica: crea el documento del alumno y actualiza
  /// el array `hijos` del tutor en una sola transacción.
  Future<Either<Failure, void>> registrarHijo(
      String tutorUid, AlumnoEntity alumno);
}
