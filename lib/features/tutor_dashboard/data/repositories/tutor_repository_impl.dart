import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/alumno_entity.dart';
import '../../domain/repositories/tutor_repository.dart';
import '../datasources/tutor_remote_data_source.dart';
import '../models/alumno_model.dart';

class TutorRepositoryImpl implements TutorRepository {
  final TutorRemoteDataSource _dataSource;

  const TutorRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AlumnoEntity>>> getHijos(
      String tutorUid) async {
    try {
      final alumnos = await _dataSource.getHijos(tutorUid);
      return Right(alumnos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> registrarHijo(
      String tutorUid, AlumnoEntity alumno) async {
    try {
      final model = AlumnoModel.fromEntity(alumno);
      await _dataSource.registrarHijo(tutorUid, model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
