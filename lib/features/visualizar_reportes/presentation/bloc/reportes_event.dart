part of 'reportes_bloc.dart';

abstract class ReportesEvent extends Equatable {
  const ReportesEvent();

  @override
  List<Object?> get props => [];
}

class CargarReportesEvent extends ReportesEvent {
  final String idAlumno;

  const CargarReportesEvent(this.idAlumno);

  @override
  List<Object?> get props => [idAlumno];
}