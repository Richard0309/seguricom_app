part of 'reportes_bloc.dart';

abstract class ReportesState extends Equatable {
  const ReportesState();

  @override
  List<Object?> get props => [];
}

class ReportesInitial extends ReportesState {}

class ReportesLoading extends ReportesState {}

class ReportesLoaded extends ReportesState {
  final List<ReporteEntity> reportes;

  const ReportesLoaded(this.reportes);

  @override
  List<Object?> get props => [reportes];
}

class ReportesError extends ReportesState {
  final String message;

  const ReportesError(this.message);

  @override
  List<Object?> get props => [message];
}