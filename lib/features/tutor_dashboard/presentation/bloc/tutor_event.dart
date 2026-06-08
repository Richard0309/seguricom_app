part of 'tutor_bloc.dart';

abstract class TutorEvent extends Equatable {
  const TutorEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita la carga de los hijos asociados al tutor [tutorUid].
class CargarHijosEvent extends TutorEvent {
  final String tutorUid;

  const CargarHijosEvent(this.tutorUid);

  @override
  List<Object?> get props => [tutorUid];
}

/// Solicita el registro de un nuevo hijo y su vinculación al tutor [tutorUid].
/// Usa [AlumnoEntity] para mantener la presentación independiente de la capa
/// de datos; el repositorio se encarga de la conversión a [AlumnoModel].
class RegistrarNuevoHijoEvent extends TutorEvent {
  final String tutorUid;
  final AlumnoEntity nuevoAlumno;

  const RegistrarNuevoHijoEvent({
    required this.tutorUid,
    required this.nuevoAlumno,
  });

  @override
  List<Object?> get props => [tutorUid, nuevoAlumno];
}
