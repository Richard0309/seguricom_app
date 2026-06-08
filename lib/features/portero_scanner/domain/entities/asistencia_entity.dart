import 'package:equatable/equatable.dart';

/// Representa un registro de asistencia en el sistema CESC.
///
/// [idAlumno]  — identificador único del alumno (ID del documento en Firestore).
/// [fecha]     — fecha del registro en formato `AAAA-MM-DD` (ej. `2026-06-08`).
/// [hora]      — hora del registro en formato `HH:MM:SS`   (ej. `07:45:30`).
/// [tipo]      — `'entrada'` o `'salida'`.
///
/// Esta entidad es puramente de dominio: no tiene dependencias de Firebase
/// ni de ningún framework externo.
class AsistenciaEntity extends Equatable {
  final String idAlumno;
  final String fecha;
  final String hora;
  final String tipo;

  const AsistenciaEntity({
    required this.idAlumno,
    required this.fecha,
    required this.hora,
    required this.tipo,
  });

  @override
  List<Object> get props => [idAlumno, fecha, hora, tipo];
}
