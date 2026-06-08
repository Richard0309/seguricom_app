part of 'historial_bloc.dart';

abstract class HistorialEvent extends Equatable {
  const HistorialEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita la carga del historial de asistencias del alumno [idAlumno].
class CargarHistorialEvent extends HistorialEvent {
  final String idAlumno;

  const CargarHistorialEvent(this.idAlumno);

  @override
  List<Object?> get props => [idAlumno];
}
