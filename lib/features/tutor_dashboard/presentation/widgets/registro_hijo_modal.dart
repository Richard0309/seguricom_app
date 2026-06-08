import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alumno_entity.dart';
import '../bloc/tutor_bloc.dart';

/// Modal deslizable para registrar un nuevo hijo.
/// Usarlo siempre a través de [RegistroHijoModal.show] para asegurar
/// que el [TutorBloc] esté disponible dentro del modal.
class RegistroHijoModal extends StatefulWidget {
  final String tutorUid;

  const RegistroHijoModal({super.key, required this.tutorUid});

  /// Muestra el modal pasando el [TutorBloc] activo al nuevo contexto.
  static void show(BuildContext context, String tutorUid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TutorBloc>(),
        child: RegistroHijoModal(tutorUid: tutorUid),
      ),
    );
  }

  @override
  State<RegistroHijoModal> createState() => _RegistroHijoModalState();
}

class _RegistroHijoModalState extends State<RegistroHijoModal> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _gradoController = TextEditingController();
  final _grupoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _gradoController.dispose();
    _grupoController.dispose();
    super.dispose();
  }

  void _onRegistrar() {
    if (!_formKey.currentState!.validate()) return;

    final nombreCompleto =
        '${_nombreController.text.trim()} ${_apellidoController.text.trim()}';

    final nuevoAlumno = AlumnoEntity(
      idAlumno: '', // El DataSource genera el ID real con Firestore
      nombre: nombreCompleto,
      grado: _gradoController.text.trim(),
      grupo: _grupoController.text.trim().toUpperCase(),
    );

    context.read<TutorBloc>().add(
          RegistrarNuevoHijoEvent(
            tutorUid: widget.tutorUid,
            nuevoAlumno: nuevoAlumno,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Sube el modal al mostrar el teclado
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Indicador de arrastre ──────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Título ─────────────────────────────────────────────────
              Text(
                'Registrar nuevo hijo',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Completa los datos del alumno.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // ── Nombre ─────────────────────────────────────────────────
              _Campo(
                controller: _nombreController,
                label: 'Nombre(s)',
                icon: Icons.person_outline,
                validator: _requerido,
              ),
              const SizedBox(height: 16),

              // ── Apellido ───────────────────────────────────────────────
              _Campo(
                controller: _apellidoController,
                label: 'Apellido(s)',
                icon: Icons.person_outline,
                validator: _requerido,
              ),
              const SizedBox(height: 16),

              // ── Grado y Grupo en fila ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _Campo(
                      controller: _gradoController,
                      label: 'Grado',
                      icon: Icons.school_outlined,
                      validator: _requerido,
                      hint: 'Ej: 1°',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _Campo(
                      controller: _grupoController,
                      label: 'Grupo',
                      icon: Icons.group_outlined,
                      validator: _requerido,
                      hint: 'Ej: A',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Botón Registrar ────────────────────────────────────────
              FilledButton.icon(
                onPressed: _onRegistrar,
                icon: const Icon(Icons.add),
                label: const Text('Registrar Hijo'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
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

// ── Widget auxiliar para campos del formulario ─────────────────────────────

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final String? hint;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
    );
  }
}
