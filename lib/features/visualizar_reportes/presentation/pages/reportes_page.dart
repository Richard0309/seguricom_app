import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../injection_container.dart';
import '../../../shared/widgets/app_sidebar.dart';
import '../../domain/entities/reporte_entity.dart';
import '../bloc/reportes_bloc.dart';

class ReportesPage extends StatelessWidget {
  final String idAlumno;

  const ReportesPage({super.key, required this.idAlumno});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportesBloc>(),
      child: _ReportesView(idAlumno: idAlumno),
    );
  }
}

class _ReportesView extends StatefulWidget {
  final String idAlumno;

  const _ReportesView({required this.idAlumno});

  @override
  State<_ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<_ReportesView> {
  @override
  void initState() {
    super.initState();
    context.read<ReportesBloc>().add(CargarReportesEvent(widget.idAlumno));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat("dd 'de' MMMM, yyyy - hh:mm a", "es_MX");

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Reportes del Alumno'),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      drawer: const AppSidebar(),
      body: BlocBuilder<ReportesBloc, ReportesState>(
        builder: (context, state) {
          return switch (state) {
            ReportesLoading() => const Center(child: CircularProgressIndicator()),
            ReportesLoaded(reportes: final reportes) when reportes.isEmpty =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay reportes disponibles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ReportesLoaded(reportes: final reportes) =>
              _ReportesList(reportes: reportes, dateFormat: dateFormat),
            ReportesError(message: final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => context
                            .read<ReportesBloc>()
                            .add(CargarReportesEvent(widget.idAlumno)),
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

class _ReportesList extends StatelessWidget {
  final List<ReporteEntity> reportes;
  final DateFormat dateFormat;

  const _ReportesList({required this.reportes, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: reportes.length,
      itemBuilder: (context, index) =>
          _ReporteCard(reporte: reportes[index], dateFormat: dateFormat),
    );
  }
}

class _ReporteCard extends StatelessWidget {
  final ReporteEntity reporte;
  final DateFormat dateFormat;

  const _ReporteCard({required this.reporte, required this.dateFormat});

  Color _estadoColor(String estado) {
    final lower = estado.toLowerCase();
    if (lower == 'generado' || lower == 'pendiente') return Colors.orange;
    if (lower == 'informativo') return Colors.blue;
    if (lower == 'atendido' || lower == 'leido') return Colors.green;
    if (lower == 'rechazado' || lower == 'cancelado') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(reporte.estado);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reporte.tipo,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reporte.estado.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reporte.descripcion, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(reporte.fecha),
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (reporte.creadoPor.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Generado por: ${reporte.creadoPor}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}