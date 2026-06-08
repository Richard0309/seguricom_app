import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso de inicio de sesión.
///
/// Orquesta la autenticación delegando al [AuthRepository].
/// Retorna el `rol` del usuario autenticado o un [Failure].
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, String>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
