part of 'permisos_bloc.dart';

abstract class PermisosState extends Equatable {
  const PermisosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cualquier operación.
class PermisosInitial extends PermisosState {}

/// Envío en curso.
class PermisosLoading extends PermisosState {}

/// Permiso enviado exitosamente. Contiene el ID del documento creado.
class PermisosSuccess extends PermisosState {
  final String permisoId;

  const PermisosSuccess(this.permisoId);

  @override
  List<Object?> get props => [permisoId];
}

/// Ocurrió un error; [message] contiene la descripción legible.
class PermisosError extends PermisosState {
  final String message;

  const PermisosError(this.message);

  @override
  List<Object?> get props => [message];
}
