import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/permiso_entity.dart';
import '../../domain/repositories/permisos_repository.dart';
import '../datasources/permisos_remote_data_source.dart';
import '../models/permiso_model.dart';

class PermisosRepositoryImpl implements PermisosRepository {
  final PermisosRemoteDataSource _dataSource;

  const PermisosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> solicitarPermiso(
      PermisoEntity permiso) async {
    try {
      final model = PermisoModel.fromEntity(permiso);
      final id = await _dataSource.enviarPermiso(model);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
