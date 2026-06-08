import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/asistencia_entity.dart';
import '../repositories/scanner_repository.dart';

/// Caso de uso principal del módulo `portero_scanner`.
///
/// Orquesta la validación del QR y el registro de asistencia delegando
/// toda la lógica de acceso a datos al [ScannerRepository]. De esta forma
/// el UseCase permanece testeable de forma unitaria mediante un mock del
/// repositorio, sin tocar Firebase.
///
/// ### Flujo
/// 1. Recibe el [idAlumno] proveniente del escaneo de QR.
/// 2. Delega al repositorio, que internamente:
///    - Verifica que el alumno exista en la colección `alumnos`.
///    - Determina si corresponde registrar `entrada` o `salida`.
///    - Persiste el documento en la colección `asistencias`.
/// 3. Retorna `Right<AsistenciaEntity>` o `Left<Failure>` al llamante (BLoC).
///
/// ### Uso
/// ```dart
/// final result = await registrarAsistenciaUseCase(idAlumno);
/// result.fold(
///   (failure) => // manejar error,
///   (asistencia) => // manejar éxito,
/// );
/// ```
class RegistrarAsistenciaUseCase {
  final ScannerRepository _repository;

  const RegistrarAsistenciaUseCase(this._repository);

  /// Punto de entrada del caso de uso.
  ///
  /// [idAlumno] — valor leído desde el código QR (es el ID del documento
  /// en la colección `alumnos` de Firestore).
  Future<Either<Failure, AsistenciaEntity>> call(String idAlumno) {
    return _repository.validarYRegistrarAsistencia(idAlumno);
  }
}
