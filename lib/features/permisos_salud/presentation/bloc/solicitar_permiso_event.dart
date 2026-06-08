part of 'solicitar_permiso_bloc.dart';

abstract class SolicitarPermisoEvent extends Equatable {
  const SolicitarPermisoEvent();

  @override
  List<Object?> get props => [];
}

/// Carga la lista de hijos del tutor para el selector.
class CargarHijosEvent extends SolicitarPermisoEvent {
  final String tutorUid;

  const CargarHijosEvent(this.tutorUid);

  @override
  List<Object?> get props => [tutorUid];
}

/// Envía el permiso de salud (justificante médico).
class EnviarPermisoEvent extends SolicitarPermisoEvent {
  final PermisoEntity permiso;

  const EnviarPermisoEvent(this.permiso);

  @override
  List<Object?> get props => [permiso];
}
