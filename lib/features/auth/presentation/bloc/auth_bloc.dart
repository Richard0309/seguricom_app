import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _loginUseCase(event.email, event.password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (rol) => emit(Authenticated(rol)),
    );
  }
}
