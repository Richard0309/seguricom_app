import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../injection_container.dart';
import '../../domain/entities/permiso_entity.dart';
import '../../../tutor_dashboard/domain/entities/alumno_entity.dart';
import '../bloc/permisos_bloc.dart';

/// Punto de entrada del módulo Permisos de Salud.
/// Recibe la lista de hijos del tutor para el selector.
class SolicitarPermisoPage extends StatelessWidget {
  final List<AlumnoEntity> hijos;

  const SolicitarPermisoPage({super.key, required this.hijos});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PermisosBloc>(),
      child: _SolicitarPermisoView(hijos: hijos),
    );
  }
}

// ── Vista interna con estado ───────────────────────────────────────────────

class _SolicitarPermisoView extends StatefulWidget {
  final List<AlumnoEntity> hijos;

  const _SolicitarPermisoView({required this.hijos});

  @override
  State<_SolicitarPermisoView> createState() => _SolicitarPermisoViewState();
}

class _SolicitarPermisoViewState extends State<_SolicitarPermisoView> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _archivoUrlController = TextEditingController();
  AlumnoEntity? _alumnoSeleccionado;

  String get _tutorUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _nombreTutor => FirebaseAuth.instance.currentUser?.displayName ?? '';

  @override
  void dispose() {
    _motivoController.dispose();
    _archivoUrlController.dispose();
    super.dispose();
  }

  void _onEnviar() {
    if (!_formKey.currentState!.validate()) return;
    if (_alumnoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un alumno.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final permiso = PermisoEntity(
      id: '',
      idAlumno: _alumnoSeleccionado!.idAlumno,
      nombreAlumno: _alumnoSeleccionado!.nombre,
      tutorUid: _tutorUid,
      nombreTutor: _nombreTutor,
      motivo: _motivoController.text.trim(),
      archivoUrl: _archivoUrlController.text.trim(),
    );

    context.read<PermisosBloc>().add(EnviarPermisoEvent(permiso));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Solicitar Permiso'),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      body: BlocConsumer<PermisosBloc, PermisosState>(
        listener: (context, state) {
          if (state is PermisosSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Justificante enviado exitosamente.'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Timer(const Duration(milliseconds: 1500), () {
              if (context.mounted) Navigator.of(context).pop();
            });
          } else if (state is PermisosError) {
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Selector de alumno ─────────────────────────────────
                  Text(
                    'Alumno',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona el hijo al que deseas enviar el justificante.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AlumnoEntity>(
                    initialValue: _alumnoSeleccionado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar alumno',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                    ),
                    items: widget.hijos.map((alumno) {
                      return DropdownMenuItem<AlumnoEntity>(
                        value: alumno,
                        child: Text(alumno.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _alumnoSeleccionado = value);
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un alumno';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Título del formulario ──────────────────────────────
                  Text(
                    'Justificante Médico',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Describe el motivo del permiso y adjunta la evidencia.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // ── Campo: Motivo ──────────────────────────────────────
                  TextFormField(
                    controller: _motivoController,
                    validator: _requerido,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Motivo del justificante',
                      hintText: 'Ej: El alumno presenta cuadro gripal...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Campo: URL del archivo ─────────────────────────────
                  TextFormField(
                    controller: _archivoUrlController,
                    validator: _requerido,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'URL del archivo adjunto',
                      hintText: 'https://drive.google.com/...',
                      prefixIcon: Icon(Icons.attach_file_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Botón Enviar ───────────────────────────────────────
                  FilledButton.icon(
                    onPressed: state is PermisosLoading ? null : _onEnviar,
                    icon: state is PermisosLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      state is PermisosLoading
                          ? 'Enviando...'
                          : 'Enviar Justificante',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }
}
