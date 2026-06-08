part of 'permisos_bloc.dart';

abstract class PermisosEvent extends Equatable {
  const PermisosEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita el envío de un permiso de salud (justificante médico).
/// Recibe la [PermisoEntity] completa construida desde la UI.
class EnviarPermisoEvent extends PermisosEvent {
  final PermisoEntity permiso;

  const EnviarPermisoEvent(this.permiso);

  @override
  List<Object?> get props => [permiso];
}
