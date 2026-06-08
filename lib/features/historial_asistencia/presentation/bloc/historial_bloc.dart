import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/asistencia_entity.dart';
import '../../domain/usecases/get_historial_usecase.dart';

part 'historial_event.dart';
part 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final GetHistorialUseCase _getHistorialUseCase;

  HistorialBloc({required GetHistorialUseCase getHistorialUseCase})
      : _getHistorialUseCase = getHistorialUseCase,
        super(HistorialInitial()) {
    on<CargarHistorialEvent>(_onCargarHistorial);
  }

  Future<void> _onCargarHistorial(
      CargarHistorialEvent event, Emitter<HistorialState> emit) async {
    emit(HistorialLoading());

    final result = await _getHistorialUseCase(event.idAlumno);

    result.fold(
      (failure) => emit(HistorialError(failure.message)),
      (asistencias) => emit(HistorialLoaded(asistencias)),
    );
  }
}
