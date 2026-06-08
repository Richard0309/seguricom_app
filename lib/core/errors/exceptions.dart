// Excepciones de la capa de datos.
// Se lanzan desde los DataSources y se capturan en los RepositoryImpl,
// donde se convierten a [Failure] (dominio). Nunca escapan más arriba.

/// Error genérico de comunicación con un servicio remoto (Firestore, API...).
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Error de servidor inesperado.']);

  @override
  String toString() => 'ServerException: $message';
}

/// El documento solicitado no existe en la fuente de datos remota.
/// Se lanza cuando el QR escaneado no corresponde a ningún alumno registrado.
class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Recurso no encontrado.']);

  @override
  String toString() => 'NotFoundException: $message';
}
