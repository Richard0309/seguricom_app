import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un permiso de salud (justificante médico).
/// No tiene dependencias de frameworks ni de infraestructura.
class PermisoEntity extends Equatable {
  /// ID auto-generado por Firestore al crear el documento.
  final String id;

  /// Identificador del alumno al que se refiere el permiso.
  final String idAlumno;

  /// Nombre completo del alumno (desnormalizado para mostrar en UI).
  final String nombreAlumno;

  /// UID del tutor que solicita el permiso.
  final String tutorUid;

  /// Nombre completo del tutor (desnormalizado para mostrar en UI).
  final String nombreTutor;

  /// Motivo del justificante médico.
  final String motivo;

  /// URL del archivo adjunto (evidencia médica).
  final String archivoUrl;

  /// Estado actual del permiso: 'pendiente', 'aprobado' o 'rechazado'.
  final String estado;

  const PermisoEntity({
    required this.id,
    required this.idAlumno,
    required this.nombreAlumno,
    required this.tutorUid,
    required this.nombreTutor,
    required this.motivo,
    required this.archivoUrl,
    this.estado = 'pendiente',
  });

  @override
  List<Object?> get props => [
        id,
        idAlumno,
        nombreAlumno,
        tutorUid,
        nombreTutor,
        motivo,
        archivoUrl,
        estado,
      ];
}
