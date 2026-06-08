import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa a un alumno.
/// No tiene dependencias de frameworks ni de infraestructura.
class AlumnoEntity extends Equatable {
  /// Identificador único del alumno (coincide con el ID del documento en Firestore).
  final String idAlumno;

  /// Nombre completo del alumno.
  final String nombre;

  /// Grado escolar (p. ej. "1°", "2°", "3°").
  final String grado;

  /// Grupo o sección (p. ej. "A", "B").
  final String grupo;

  const AlumnoEntity({
    required this.idAlumno,
    required this.nombre,
    required this.grado,
    required this.grupo,
  });

  @override
  List<Object?> get props => [idAlumno, nombre, grado, grupo];
}
