import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sidebar reutilizable para todas las pantallas del módulo Tutor.
/// Usa el [Drawer] de Material Design con [UserAccountsDrawerHeader].
///
/// Uso:
/// ```dart
/// Scaffold(
///   drawer: const AppSidebar(),
///   body: ...,
/// )
/// ```
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = GoRouterState.of(context).uri.path;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── Header: info del usuario ──────────────────────────────────
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'Tutor',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                user?.email ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: Text(
                  _initials(user?.displayName ?? 'T'),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
            ),

            // ── Destinos de navegación ───────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _MenuItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    title: 'Mi Panel',
                    route: '/tutor/dashboard',
                    isSelected: currentPath == '/tutor/dashboard',
                  ),
                  _MenuItem(
                    icon: Icons.history_outlined,
                    selectedIcon: Icons.history_rounded,
                    title: 'Historial de Asistencias',
                    route: '/tutor/historial',
                    isSelected: currentPath.startsWith('/tutor/historial'),
                  ),
                  _MenuItem(
                    icon: Icons.medical_services_outlined,
                    selectedIcon: Icons.medical_services_rounded,
                    title: 'Solicitar Justificante',
                    route: '/tutor/solicitar-permiso',
                    isSelected: currentPath == '/tutor/solicitar-permiso',
                  ),
                ],
              ),
            ),

            // ── Cerrar sesión ────────────────────────────────────────────
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Extrae las iniciales del nombre para el [CircleAvatar].
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

// ── Widget privado: elemento del menú ──────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String route;
  final bool isSelected;

  const _MenuItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.route,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
