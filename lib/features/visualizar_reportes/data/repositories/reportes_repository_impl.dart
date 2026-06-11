import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reporte_entity.dart';
import '../../domain/repositories/reportes_repository.dart';
import '../datasources/reportes_remote_data_source.dart';

class ReportesRepositoryImpl implements ReportesRepository {
  final ReportesRemoteDataSource _dataSource;

  const ReportesRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ReporteEntity>>> getReportes(String idAlumno) async {
    try {
      final reportes = await _dataSource.getReportes(idAlumno);
      return Right(reportes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}