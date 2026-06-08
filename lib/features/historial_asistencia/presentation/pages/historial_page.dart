import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../injection_container.dart';
import '../../domain/entities/asistencia_entity.dart';
import '../bloc/historial_bloc.dart';

/// Punto de entrada del módulo Historial de Asistencia.
/// Provee el [HistorialBloc] e inicia la carga al montarse.
class HistorialPage extends StatelessWidget {
  final String idAlumno;

  const HistorialPage({super.key, required this.idAlumno});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistorialBloc>(),
      child: _HistorialView(idAlumno: idAlumno),
    );
  }
}

// ── Vista interna con estado ───────────────────────────────────────────────

class _HistorialView extends StatefulWidget {
  final String idAlumno;

  const _HistorialView({required this.idAlumno});

  @override
  State<_HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<_HistorialView> {
  @override
  void initState() {
    super.initState();
    context.read<HistorialBloc>().add(CargarHistorialEvent(widget.idAlumno));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      body: BlocBuilder<HistorialBloc, HistorialState>(
        builder: (context, state) {
          return switch (state) {
            HistorialLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            HistorialLoaded(asistencias: final asistencias)
                when asistencias.isEmpty =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay registros de asistencia aún.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            HistorialLoaded(asistencias: final asistencias) =>
              _AsistenciaList(asistencias: asistencias),
            HistorialError(message: final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => context
                            .read<HistorialBloc>()
                            .add(CargarHistorialEvent(widget.idAlumno)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ── Widget: lista de asistencias ───────────────────────────────────────────

class _AsistenciaList extends StatelessWidget {
  final List<AsistenciaEntity> asistencias;

  const _AsistenciaList({required this.asistencias});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: asistencias.length,
      itemBuilder: (context, index) =>
          _AsistenciaTile(asistencia: asistencias[index]),
    );
  }
}

// ── Widget: tarjeta de una asistencia ─────────────────────────────────────

class _AsistenciaTile extends StatelessWidget {
  final AsistenciaEntity asistencia;

  const _AsistenciaTile({required this.asistencia});

  @override
  Widget build(BuildContext context) {
    final isEntrada = asistencia.tipo == 'entrada';
    final color =
        isEntrada ? Colors.green.shade600 : Colors.orange.shade700;
    final icon =
        isEntrada ? Icons.login_rounded : Icons.logout_rounded;
    final label = isEntrada ? 'Entrada' : 'Salida';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        subtitle: Text('${asistencia.fecha}  •  ${asistencia.hora}'),
      ),
    );
  }
}
