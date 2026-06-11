import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../injection_container.dart';
import '../../../shared/widgets/app_sidebar.dart'
    show AppSidebar;
import '../bloc/tutor_bloc.dart';
import '../widgets/registro_hijo_modal.dart';

/// Punto de entrada del módulo Tutor Dashboard.
/// Provee el [TutorBloc] e inicia la carga de hijos al montarse.
class TutorDashboardPage extends StatelessWidget {
  const TutorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TutorBloc>(),
      child: const _TutorDashboardView(),
    );
  }
}

// ── Vista interna con estado ───────────────────────────────────────────────

class _TutorDashboardView extends StatefulWidget {
  const _TutorDashboardView();

  @override
  State<_TutorDashboardView> createState() => _TutorDashboardViewState();
}

class _TutorDashboardViewState extends State<_TutorDashboardView> {
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
        title: const Text('Panel del Padre'),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => RegistroHijoModal.show(context, _tutorUid),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Añadir hijo'),
      ),
      body: BlocConsumer<TutorBloc, TutorState>(
        listener: (context, state) {
          if (state is TutorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            TutorLoading() => const Center(child: CircularProgressIndicator()),
            TutorLoaded(hijos: final hijos) when hijos.isEmpty =>
              _EmptyState(tutorUid: _tutorUid),
            TutorLoaded(hijos: final hijos) => _HijosList(hijos: hijos),
            TutorError() => _ErrorState(
                onRetry: () =>
                    context.read<TutorBloc>().add(CargarHijosEvent(_tutorUid)),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ── Widget: lista de hijos ─────────────────────────────────────────────────

class _HijosList extends StatelessWidget {
  final List hijos;

  const _HijosList({required this.hijos});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: hijos.length,
      itemBuilder: (context, index) {
        final alumno = hijos[index];
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
                    CircleAvatar(
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alumno.nombre,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${alumno.grado} — Grupo ${alumno.grupo}',
                            style: textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context
                            .push('/tutor/historial/${alumno.idAlumno}'),
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('Historial'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            context.push('/tutor/reportes/${alumno.idAlumno}'),
                        icon: const Icon(Icons.assignment_rounded, size: 18),
                        label: const Text('Reportes'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Widget: estado vacío ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String tutorUid;

  const _EmptyState({required this.tutorUid});

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
              'Presiona el botón "Añadir hijo" para comenzar.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.tonalIcon(
              onPressed: () => RegistroHijoModal.show(context, tutorUid),
              icon: const Icon(Icons.add),
              label: const Text('Añadir primer hijo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: estado de error ────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

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
            Icon(Icons.wifi_off_rounded,
                size: 64, color: colorScheme.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la información',
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
