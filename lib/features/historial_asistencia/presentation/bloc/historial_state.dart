part of 'historial_bloc.dart';

abstract class HistorialState extends Equatable {
  const HistorialState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cualquier operación.
class HistorialInitial extends HistorialState {}

/// Carga en curso.
class HistorialLoading extends HistorialState {}

/// Historial obtenido exitosamente (puede ser una lista vacía).
class HistorialLoaded extends HistorialState {
  final List<AsistenciaEntity> asistencias;

  const HistorialLoaded(this.asistencias);

  @override
  List<Object?> get props => [asistencias];
}

/// Ocurrió un error; [message] contiene la descripción legible.
class HistorialError extends HistorialState {
  final String message;

  const HistorialError(this.message);

  @override
  List<Object?> get props => [message];
}
