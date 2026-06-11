import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/reporte_entity.dart';
import '../../domain/usecases/get_reportes_usecase.dart';

part 'reportes_event.dart';
part 'reportes_state.dart';

class ReportesBloc extends Bloc<ReportesEvent, ReportesState> {
  final GetReportesUseCase _getReportesUseCase;

  ReportesBloc({required GetReportesUseCase getReportesUseCase})
      : _getReportesUseCase = getReportesUseCase,
        super(ReportesInitial()) {
    on<CargarReportesEvent>(_onCargarReportes);
  }

  Future<void> _onCargarReportes(
    CargarReportesEvent event,
    Emitter<ReportesState> emit,
  ) async {
    emit(ReportesLoading());

    final result = await _getReportesUseCase(event.idAlumno);

    result.fold(
      (failure) => emit(ReportesError(failure.message)),
      (reportes) => emit(ReportesLoaded(reportes)),
    );
  }
}