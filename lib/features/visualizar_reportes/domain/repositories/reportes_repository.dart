import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reporte_entity.dart';

abstract class ReportesRepository {
  Future<Either<Failure, List<ReporteEntity>>> getReportes(String idAlumno);
}