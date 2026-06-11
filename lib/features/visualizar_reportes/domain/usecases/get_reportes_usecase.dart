import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reporte_entity.dart';
import '../repositories/reportes_repository.dart';

class GetReportesUseCase {
  final ReportesRepository _repository;

  const GetReportesUseCase(this._repository);

  Future<Either<Failure, List<ReporteEntity>>> call(String idAlumno) {
    return _repository.getReportes(idAlumno);
  }
}