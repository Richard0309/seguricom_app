import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/historial_asistencia/presentation/pages/historial_page.dart';
import '../../features/portero_scanner/presentation/pages/scanner_page.dart';
import '../../features/tutor_dashboard/domain/entities/alumno_entity.dart';
import '../../features/tutor_dashboard/presentation/pages/tutor_dashboard_page.dart';
import '../../features/permisos_salud/presentation/pages/solicitar_permiso_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/portero',
      builder: (context, state) => const ScannerPage(),
    ),
    GoRoute(
      path: '/tutor',
      builder: (context, state) => const TutorDashboardPage(),
    ),
    GoRoute(
      path: '/historial/:idAlumno',
      builder: (context, state) => HistorialPage(
        idAlumno: state.pathParameters['idAlumno']!,
      ),
    ),
    GoRoute(
      path: '/solicitar-permiso',
      builder: (context, state) {
        final hijos = state.extra as List<AlumnoEntity>;
        return SolicitarPermisoPage(hijos: hijos);
      },
    ),
  ],
);
