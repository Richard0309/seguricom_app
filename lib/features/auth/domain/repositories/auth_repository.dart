import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

/// Contrato de autenticación para la capa de dominio.
/// La implementación concreta vive en la capa de datos.
abstract class AuthRepository {
  /// Autentica al usuario con [email] y [password].
  /// Retorna el `rol` del usuario ('portero' | 'tutor') o un [Failure].
  Future<Either<Failure, String>> login(String email, String password);
}
