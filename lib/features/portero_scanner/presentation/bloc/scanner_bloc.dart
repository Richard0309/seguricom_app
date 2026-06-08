import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/asistencia_entity.dart';
import '../../domain/usecases/registrar_asistencia_usecase.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final RegistrarAsistenciaUseCase _registrarAsistencia;

  ScannerBloc(this._registrarAsistencia) : super(ScannerInitial()) {
    on<EscanearQREvent>(_onEscanearQR);
    on<ResetScannerEvent>(_onReset);
  }

  Future<void> _onEscanearQR(
    EscanearQREvent event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerLoading());

    final result = await _registrarAsistencia(event.idAlumno);

    result.fold(
      (failure) => emit(ScannerError(failure.message)),
      (asistencia) => emit(ScannerSuccess(asistencia)),
    );
  }

  void _onReset(ResetScannerEvent event, Emitter<ScannerState> emit) {
    emit(ScannerInitial());
  }
}
