import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/asistencia_entity.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_remote_data_source.dart';

/// Implementación concreta de [ScannerRepository].
///
/// Actúa como frontera entre la capa de datos y la de dominio:
/// - Llama al [ScannerRemoteDataSource] para ejecutar la lógica de Firestore.
/// - Captura las excepciones de datos y las convierte en [Failure],
///   garantizando que la capa de dominio nunca reciba excepciones crudas.
class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource _dataSource;

  const ScannerRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AsistenciaEntity>> validarYRegistrarAsistencia(
    String idAlumno,
  ) async {
    try {
      final asistencia = await _dataSource.registrarAsistencia(idAlumno);
      return Right(asistencia);
    } on NotFoundException catch (e) {
      // QR inválido o alumno inexistente
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      // Error de red, Firestore, permisos, etc.
      return Left(ServerFailure(e.message));
    }
  }
}
