part of 'solicitar_permiso_bloc.dart';

abstract class SolicitarPermisoState extends Equatable {
  const SolicitarPermisoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cualquier operación.
class SolicitarPermisoInitial extends SolicitarPermisoState {}

/// Cargando la lista de hijos.
class SolicitarPermisoLoading extends SolicitarPermisoState {}

/// Hijos cargados exitosamente, listos para el selector.
class SolicitarPermisoHijosLoaded extends SolicitarPermisoState {
  final List<AlumnoEntity> hijos;

  const SolicitarPermisoHijosLoaded(this.hijos);

  @override
  List<Object?> get props => [hijos];
}

/// Enviando el justificante.
class SolicitarPermisoSubmitting extends SolicitarPermisoState {}

/// Justificante enviado exitosamente. Contiene el ID del documento.
class SolicitarPermisoSuccess extends SolicitarPermisoState {
  final String permisoId;

  const SolicitarPermisoSuccess(this.permisoId);

  @override
  List<Object?> get props => [permisoId];
}

/// Ocurrió un error; [message] contiene la descripción legible.
class SolicitarPermisoError extends SolicitarPermisoState {
  final String message;

  const SolicitarPermisoError(this.message);

  @override
  List<Object?> get props => [message];
}
