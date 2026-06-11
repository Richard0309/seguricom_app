import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reporte_entity.dart';

class ReporteModel extends ReporteEntity {
  const ReporteModel({
    required super.creadoPor,
    required super.descripcion,
    required super.estado,
    required super.fecha,
    required super.idAlumno,
    required super.tipo,
  });

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      creadoPor: json['creadoPor'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      fecha: (json['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      idAlumno: json['idAlumno'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creadoPor': creadoPor,
      'descripcion': descripcion,
      'estado': estado,
      'fecha': Timestamp.fromDate(fecha),
      'idAlumno': idAlumno,
      'tipo': tipo,
    };
  }

  factory ReporteModel.fromEntity(ReporteEntity entity) {
    return ReporteModel(
      creadoPor: entity.creadoPor,
      descripcion: entity.descripcion,
      estado: entity.estado,
      fecha: entity.fecha,
      idAlumno: entity.idAlumno,
      tipo: entity.tipo,
    );
  }
}