import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/permiso_entity.dart';
import '../../domain/usecases/solicitar_permiso_usecase.dart';
import '../../../tutor_dashboard/domain/usecases/get_hijos_usecase.dart';
import '../../../tutor_dashboard/domain/entities/alumno_entity.dart';

part 'solicitar_permiso_event.dart';
part 'solicitar_permiso_state.dart';

/// BLoC que gestiona el formulario de solicitud de permiso.
/// Carga los hijos del tutor y maneja el envío del justificante.
class SolicitarPermisoBloc
    extends Bloc<SolicitarPermisoEvent, SolicitarPermisoState> {
  final GetHijosUseCase _getHijosUseCase;
  final SolicitarPermisoUseCase _solicitarPermisoUseCase;

  SolicitarPermisoBloc({
    required GetHijosUseCase getHijosUseCase,
    required SolicitarPermisoUseCase solicitarPermisoUseCase,
  })  : _getHijosUseCase = getHijosUseCase,
        _solicitarPermisoUseCase = solicitarPermisoUseCase,
        super(SolicitarPermisoInitial()) {
    on<CargarHijosEvent>(_onCargarHijos);
    on<EnviarPermisoEvent>(_onEnviarPermiso);
  }

  Future<void> _onCargarHijos(
      CargarHijosEvent event, Emitter<SolicitarPermisoState> emit) async {
    emit(SolicitarPermisoLoading());

    final result = await _getHijosUseCase(event.tutorUid);

    result.fold(
      (failure) => emit(SolicitarPermisoError(failure.message)),
      (hijos) => emit(SolicitarPermisoHijosLoaded(hijos)),
    );
  }

  Future<void> _onEnviarPermiso(
      EnviarPermisoEvent event, Emitter<SolicitarPermisoState> emit) async {
    emit(SolicitarPermisoSubmitting());

    final result = await _solicitarPermisoUseCase(event.permiso);

    result.fold(
      (failure) => emit(SolicitarPermisoError(failure.message)),
      (id) => emit(SolicitarPermisoSuccess(id)),
    );
  }
}
