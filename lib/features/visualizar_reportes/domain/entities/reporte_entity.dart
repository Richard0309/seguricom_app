import 'package:equatable/equatable.dart';

class ReporteEntity extends Equatable {
  final String creadoPor;
  final String descripcion;
  final String estado;
  final DateTime fecha;
  final String idAlumno;
  final String tipo;

  const ReporteEntity({
    required this.creadoPor,
    required this.descripcion,
    required this.estado,
    required this.fecha,
    required this.idAlumno,
    required this.tipo,
  });

  @override
  List<Object?> get props => [creadoPor, descripcion, estado, fecha, idAlumno, tipo];
}