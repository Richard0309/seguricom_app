import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/permiso_entity.dart';
import '../../domain/usecases/solicitar_permiso_usecase.dart';

part 'permisos_event.dart';
part 'permisos_state.dart';

class PermisosBloc extends Bloc<PermisosEvent, PermisosState> {
  final SolicitarPermisoUseCase _solicitarPermisoUseCase;

  PermisosBloc({required SolicitarPermisoUseCase solicitarPermisoUseCase})
      : _solicitarPermisoUseCase = solicitarPermisoUseCase,
        super(PermisosInitial()) {
    on<EnviarPermisoEvent>(_onEnviarPermiso);
  }

  Future<void> _onEnviarPermiso(
      EnviarPermisoEvent event, Emitter<PermisosState> emit) async {
    emit(PermisosLoading());

    final result = await _solicitarPermisoUseCase(event.permiso);

    result.fold(
      (failure) => emit(PermisosError(failure.message)),
      (id) => emit(PermisosSuccess(id)),
    );
  }
}
