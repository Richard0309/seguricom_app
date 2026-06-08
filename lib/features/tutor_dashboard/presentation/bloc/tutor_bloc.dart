import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alumno_entity.dart';
import '../../domain/usecases/get_hijos_usecase.dart';
import '../../domain/usecases/registrar_hijo_usecase.dart';

part 'tutor_event.dart';
part 'tutor_state.dart';

class TutorBloc extends Bloc<TutorEvent, TutorState> {
  final GetHijosUseCase _getHijosUseCase;
  final RegistrarHijoUseCase _registrarHijoUseCase;

  TutorBloc(this._getHijosUseCase, this._registrarHijoUseCase)
      : super(TutorInitial()) {
    on<CargarHijosEvent>(_onCargarHijos);
    on<RegistrarNuevoHijoEvent>(_onRegistrarNuevoHijo);
  }

  Future<void> _onCargarHijos(
      CargarHijosEvent event, Emitter<TutorState> emit) async {
    if (kDebugMode) {
      debugPrint('[TutorBloc] CargarHijosEvent received: tutorUid=${event.tutorUid}');
    }
    emit(TutorLoading());

    final result = await _getHijosUseCase(event.tutorUid);

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[TutorBloc] GetHijosUseCase result: failure=${failure.message}');
        }
        emit(TutorError(failure.message));
      },
      (hijos) {
        if (kDebugMode) {
          debugPrint('[TutorBloc] GetHijosUseCase result: success=true, hijosCount=${hijos.length}');
        }
        emit(TutorLoaded(hijos));
      },
    );
  }

  Future<void> _onRegistrarNuevoHijo(
      RegistrarNuevoHijoEvent event, Emitter<TutorState> emit) async {
    if (kDebugMode) {
      debugPrint('[TutorBloc] RegistrarNuevoHijoEvent received: tutorUid=${event.tutorUid}, alumno=${event.nuevoAlumno}');
    }
    emit(TutorLoading());

    final result =
        await _registrarHijoUseCase(event.tutorUid, event.nuevoAlumno);

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[TutorBloc] RegistrarHijoUseCase result: failure=${failure.message}');
        }
        emit(TutorError(failure.message));
      },
      // En caso de éxito, recarga la lista automáticamente
      (_) {
        if (kDebugMode) {
          debugPrint('[TutorBloc] RegistrarHijoUseCase result: success=true');
          debugPrint('[TutorBloc] Triggering CargarHijosEvent for tutorUid=${event.tutorUid}');
        }
        add(CargarHijosEvent(event.tutorUid));
      },
    );
  }
}
