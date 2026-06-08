import '../../domain/entities/asistencia_entity.dart';

/// Modelo de datos de la capa de datos para un registro de asistencia.
/// Extiende [AsistenciaEntity] y añade serialización JSON para Firestore.
class AsistenciaModel extends AsistenciaEntity {
  const AsistenciaModel({
    required super.idAlumno,
    required super.fecha,
    required super.hora,
    required super.tipo,
  });

  /// Crea un [AsistenciaModel] a partir de un mapa JSON de Firestore.
  /// El campo `serverTimestamp` no se incluye en el modelo porque solo
  /// se utiliza para ordenar la consulta, no como dato de negocio.
  factory AsistenciaModel.fromJson(Map<String, dynamic> json) {
    return AsistenciaModel(
      idAlumno: json['idAlumno'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
      hora: json['hora'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
    );
  }

  /// Serializa el modelo a un mapa para escribir en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'idAlumno': idAlumno,
      'fecha': fecha,
      'hora': hora,
      'tipo': tipo,
    };
  }

  /// Convierte una [AsistenciaEntity] de dominio en un [AsistenciaModel] de datos.
  factory AsistenciaModel.fromEntity(AsistenciaEntity entity) {
    return AsistenciaModel(
      idAlumno: entity.idAlumno,
      fecha: entity.fecha,
      hora: entity.hora,
      tipo: entity.tipo,
    );
  }
}
