part of 'scanner_bloc.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

/// Disparado cuando el escáner detecta un código QR válido.
/// [idAlumno] es el valor raw leído del código.
class EscanearQREvent extends ScannerEvent {
  final String idAlumno;

  const EscanearQREvent(this.idAlumno);

  @override
  List<Object> get props => [idAlumno];
}

/// Restablece el BLoC a [ScannerInitial] para permitir el siguiente escaneo.
class ResetScannerEvent extends ScannerEvent {}
