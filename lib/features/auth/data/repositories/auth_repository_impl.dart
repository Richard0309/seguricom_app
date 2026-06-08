import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final rol = await _dataSource.login(email, password);
      return Right(rol);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
