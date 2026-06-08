import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../injection_container.dart';
import '../bloc/scanner_bloc.dart';
import '../widgets/resultado_scan_dialog.dart';

/// Punto de entrada del módulo portero_scanner.
///
/// El [ScannerBloc] se resuelve desde el Service Locator, manteniendo
/// la presentación desacoplada de la capa de datos.
class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScannerBloc>(),
      child: const _ScannerView(),
    );
  }
}

// ── Vista interna con estado ────────────────────────────────────────────────

class _ScannerView extends StatefulWidget {
  const _ScannerView();

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Manejo del escaneo ──────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // Sólo procesar si estamos en estado inicial (evita escaneos múltiples)
    if (context.read<ScannerBloc>().state is! ScannerInitial) return;

    _controller.stop(); // Pausa la cámara hasta que el flujo termine
    context.read<ScannerBloc>().add(EscanearQREvent(rawValue));
  }

  // ── Resultado del escaneo ───────────────────────────────────────────────

  void _mostrarResultado(ScannerState state) {
    final bool isSuccess;
    final String mensaje;

    if (state is ScannerSuccess) {
      isSuccess = true;
      mensaje =
          '${_capitalize(state.asistencia.tipo)} registrada · ${state.asistencia.hora}';
    } else if (state is ScannerError) {
      isSuccess = false;
      mensaje = state.message;
    } else {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => ResultadoScanDialog(isSuccess: isSuccess, mensaje: mensaje),
    );

    // Tras 2 s: cerrar diálogo, reanudar cámara y resetear el BLoC
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      _controller.start();
      context.read<ScannerBloc>().add(ResetScannerEvent());
    });
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (_, state) {
          if (state is ScannerSuccess || state is ScannerError) {
            _mostrarResultado(state);
          }
        },
        builder: (_, state) {
          return Stack(
            children: [
              // Cámara a pantalla completa
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),

              // Overlay de carga mientras Firebase valida el QR
              if (state is ScannerLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Validando...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              // Etiqueta de instrucción en estado inicial
              if (state is ScannerInitial)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Text(
                      'Apunta la cámara al código QR del alumno',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [Shadow(blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
