part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Estado inicial: el formulario de login está vacío y listo.
class AuthInitial extends AuthState {}

/// Autenticación en curso (llamada a Firebase en proceso).
class AuthLoading extends AuthState {}

/// Autenticación exitosa. [rol] indica el perfil del usuario.
class Authenticated extends AuthState {
  final String rol;

  const Authenticated(this.rol);

  @override
  List<Object> get props => [rol];
}

/// La autenticación falló. [message] es legible para el usuario.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
