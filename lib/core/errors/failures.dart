import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos de la aplicación.
/// Usa [message] para transportar el mensaje legible por el usuario o
/// por la capa de presentación.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Error originado en un servicio remoto (Firestore, REST API, etc.).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error de servidor. Inténtalo de nuevo.']);
}

/// El recurso solicitado no existe en la fuente de datos remota.
/// Se usa, por ejemplo, cuando el `idAlumno` escaneado no existe en Firestore.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado.']);
}

/// Una regla de negocio no se cumplió (validación de dominio).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
