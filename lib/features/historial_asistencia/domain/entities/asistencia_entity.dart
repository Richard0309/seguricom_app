import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un registro de asistencia.
/// No tiene dependencias de frameworks ni de infraestructura.
/// Es propia del módulo `historial_asistencia` para evitar acoplamiento
/// con el módulo `portero_scanner`.
class AsistenciaEntity extends Equatable {
  /// Identificador del alumno al que pertenece este registro.
  final String idAlumno;

  /// Fecha del registro en formato AAAA-MM-DD.
  final String fecha;

  /// Hora del registro en formato HH:MM:SS.
  final String hora;

  /// Tipo de movimiento: 'entrada' o 'salida'.
  final String tipo;

  const AsistenciaEntity({
    required this.idAlumno,
    required this.fecha,
    required this.hora,
    required this.tipo,
  });

  @override
  List<Object?> get props => [idAlumno, fecha, hora, tipo];
}
