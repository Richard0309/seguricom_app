part of 'scanner_bloc.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object> get props => [];
}

/// Estado inicial: la cámara está activa y esperando un QR.
class ScannerInitial extends ScannerState {}

/// La validación en Firebase está en curso. La cámara está pausada.
class ScannerLoading extends ScannerState {}

/// La asistencia fue registrada con éxito.
/// [asistencia] contiene los datos del registro creado.
class ScannerSuccess extends ScannerState {
  final AsistenciaEntity asistencia;

  const ScannerSuccess(this.asistencia);

  @override
  List<Object> get props => [asistencia];
}

/// El escaneo o el registro fallaron.
/// [message] es el mensaje legible para mostrar al usuario.
class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object> get props => [message];
}
