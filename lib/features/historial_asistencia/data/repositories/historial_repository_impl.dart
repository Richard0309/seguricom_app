import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/asistencia_entity.dart';
import '../../domain/repositories/historial_repository.dart';
import '../datasources/historial_remote_data_source.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialRemoteDataSource _dataSource;

  const HistorialRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AsistenciaEntity>>> getHistorial(
      String idAlumno) async {
    try {
      final registros = await _dataSource.getHistorial(idAlumno);
      return Right(registros);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
