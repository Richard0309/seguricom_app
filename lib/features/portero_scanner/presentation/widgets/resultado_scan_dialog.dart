import 'package:flutter/material.dart';

/// Diálogo superpuesto que muestra el resultado del escaneo.
///
/// [isSuccess] determina el color y el icono:
/// - `true`  → fondo verde  (#4CAF50) + icono de check   → "Acceso Permitido"
/// - `false` → fondo rojo   (#F44336) + icono de error   → "Acceso Denegado"
///
/// [mensaje] muestra el detalle (tipo de registro o mensaje de fallo).
/// El cierre del diálogo es responsabilidad del llamante (via Future.delayed).
class ResultadoScanDialog extends StatelessWidget {
  final bool isSuccess;
  final String mensaje;

  const ResultadoScanDialog({
    super.key,
    required this.isSuccess,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final icon =
        isSuccess ? Icons.check_circle_outline : Icons.error_outline;
    final titulo = isSuccess ? 'Acceso Permitido' : 'Acceso Denegado';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(120),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 88),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
