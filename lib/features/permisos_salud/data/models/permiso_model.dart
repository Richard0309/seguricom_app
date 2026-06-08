import '../../domain/entities/permiso_entity.dart';

/// Modelo de datos de la capa de datos para un permiso de salud.
/// Extiende [PermisoEntity] y añade serialización JSON para Firestore.
class PermisoModel extends PermisoEntity {
  const PermisoModel({
    required super.id,
    required super.idAlumno,
    required super.nombreAlumno,
    required super.tutorUid,
    required super.nombreTutor,
    required super.motivo,
    required super.archivoUrl,
    super.estado = 'pendiente',
  });

  /// Crea un [PermisoModel] a partir de un mapa JSON de Firestore.
  /// El [id] se pasa por separado porque es el ID del documento,
  /// no un campo dentro del documento.
  factory PermisoModel.fromJson(String id, Map<String, dynamic> json) {
    return PermisoModel(
      id: id,
      idAlumno: json['idAlumno'] as String? ?? '',
      nombreAlumno: json['nombreAlumno'] as String? ?? '',
      tutorUid: json['tutorUid'] as String? ?? '',
      nombreTutor: json['nombreTutor'] as String? ?? '',
      motivo: json['motivo'] as String? ?? '',
      archivoUrl: json['archivoUrl'] as String? ?? '',
      estado: json['estado'] as String? ?? 'pendiente',
    );
  }

  /// Serializa el modelo a un mapa para escribir en Firestore.
  /// No incluye `fechaSolicitud` porque se inyecta como
  /// [FieldValue.serverTimestamp()] directamente en el DataSource.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idAlumno': idAlumno,
      'nombreAlumno': nombreAlumno,
      'tutorUid': tutorUid,
      'nombreTutor': nombreTutor,
      'motivo': motivo,
      'archivoUrl': archivoUrl,
      'estado': estado,
    };
  }

  /// Convierte una [PermisoEntity] de dominio en un [PermisoModel] de datos.
  factory PermisoModel.fromEntity(PermisoEntity entity) {
    return PermisoModel(
      id: entity.id,
      idAlumno: entity.idAlumno,
      nombreAlumno: entity.nombreAlumno,
      tutorUid: entity.tutorUid,
      nombreTutor: entity.nombreTutor,
      motivo: entity.motivo,
      archivoUrl: entity.archivoUrl,
      estado: entity.estado,
    );
  }
}
