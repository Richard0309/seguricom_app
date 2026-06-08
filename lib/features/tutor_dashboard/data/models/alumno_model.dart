import '../../domain/entities/alumno_entity.dart';

/// Modelo de datos de la capa de datos para un alumno.
/// Extiende [AlumnoEntity] y añade serialización JSON para Firestore.
class AlumnoModel extends AlumnoEntity {
  const AlumnoModel({
    required super.idAlumno,
    required super.nombre,
    required super.grado,
    required super.grupo,
  });

  /// Crea un [AlumnoModel] a partir de un mapa JSON de Firestore.
  /// El [id] se pasa por separado porque es el ID del documento,
  /// no un campo dentro del documento.
  factory AlumnoModel.fromJson(String id, Map<String, dynamic> json) {
    try{
      return AlumnoModel(
      idAlumno: id,
      nombre: json['nombre'] as String? ?? '',
      grado: json['grado'] as String? ?? '',
      grupo: json['grupo'] as String? ?? '',
    );
    }catch(e,stackTrace){
      print(' [ERROR MODELO] Falló al parsear AlumnoModel: $e');
      print(' [STACKTRACE]: $stackTrace');
      rethrow;
    }
    
  }

  /// Serializa el modelo a un mapa para escribir en Firestore.
  /// Incluye `idAlumno` dentro del documento para facilitar lecturas
  /// sin necesidad de conocer el ID externamente.
  Map<String, dynamic> toJson() {
    return {
      'idAlumno': idAlumno,
      'nombre': nombre,
      'grado': grado,
      'grupo': grupo,
    };
  }

  /// Crea una copia del modelo con el [idAlumno] actualizado.
  /// Útil al asignar el ID auto-generado por Firestore antes del batch.
  AlumnoModel copyWith({
    String? idAlumno,
    String? nombre,
    String? grado,
    String? grupo,
  }) {
    return AlumnoModel(
      idAlumno: idAlumno ?? this.idAlumno,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      grupo: grupo ?? this.grupo,
    );
  }

  /// Convierte una [AlumnoEntity] de dominio en un [AlumnoModel] de datos.
  factory AlumnoModel.fromEntity(AlumnoEntity entity) {
    return AlumnoModel(
      idAlumno: entity.idAlumno,
      nombre: entity.nombre,
      grado: entity.grado,
      grupo: entity.grupo,
    );
  }
}
