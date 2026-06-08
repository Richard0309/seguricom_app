part of 'tutor_bloc.dart';

abstract class TutorState extends Equatable {
  const TutorState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cualquier operación.
class TutorInitial extends TutorState {}

/// Operación en curso (carga o registro).
class TutorLoading extends TutorState {}

/// Lista de hijos obtenida exitosamente (puede ser vacía).
class TutorLoaded extends TutorState {
  final List<AlumnoEntity> hijos;

  const TutorLoaded(this.hijos);

  @override
  List<Object?> get props => [hijos];
}

/// Ocurrió un error; [message] contiene la descripción legible.
class TutorError extends TutorState {
  final String message;

  const TutorError(this.message);

  @override
  List<Object?> get props => [message];
}
