import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../injection_container.dart';
import '../../../shared/widgets/app_sidebar.dart';
import '../../../tutor_dashboard/domain/entities/alumno_entity.dart';
import '../../../tutor_dashboard/presentation/bloc/tutor_bloc.dart';

/// Pantalla de selección de alumno para ver su historial de asistencias.
/// Accedida desde el Sidebar en "Historial de Asistencias".
class TutorHistorialPage extends StatelessWidget {
  const TutorHistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TutorBloc>(),
      child: const _TutorHistorialView(),
    );
  }
}

// ── Vista interna con estado ───────────────────────────────────────────────

class _TutorHistorialView extends StatefulWidget {
  const _TutorHistorialView();

  @override
  State<_TutorHistorialView> createState() => _TutorHistorialViewState();
}

class _TutorHistorialViewState extends State<_TutorHistorialView> {
  late final String _tutorUid;

  @override
  void initState() {
    super.initState();
    _tutorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<TutorBloc>().add(CargarHijosEvent(_tutorUid));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Historial de Asistencias'),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      drawer: const AppSidebar(),
      body: BlocBuilder<TutorBloc, TutorState>(
        builder: (context, state) {
          return switch (state) {
            TutorLoading() => const Center(child: CircularProgressIndicator()),
            TutorLoaded(hijos: final hijos) when hijos.isEmpty =>
              const _EmptyState(),
            TutorLoaded(hijos: final hijos) =>
              _AlumnoList(alumnos: hijos),
            TutorError() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    const Text('No se pudieron cargar los hijos.'),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<TutorBloc>()
                          .add(CargarHijosEvent(_tutorUid)),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ── Widget: lista de alumnos ───────────────────────────────────────────────

class _AlumnoList extends StatelessWidget {
  final List<AlumnoEntity> alumnos;

  const _AlumnoList({required this.alumnos});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: alumnos.length,
      itemBuilder: (context, index) {
        final alumno = alumnos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                alumno.nombre.isNotEmpty
                    ? alumno.nombre[0].toUpperCase()
                    : '?',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              alumno.nombre,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${alumno.grado} — Grupo ${alumno.grupo}',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () =>
                context.push('/tutor/historial/${alumno.idAlumno}'),
          ),
        );
      },
    );
  }
}

// ── Widget: estado vacío ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 20),
            Text(
              'No tienes hijos registrados',
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registra un hijo desde el Panel Principal para ver su historial.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
