import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/historial_asistencia/presentation/pages/historial_page.dart';
import '../../features/portero_scanner/presentation/pages/scanner_page.dart';
import '../../features/tutor_dashboard/presentation/pages/tutor_dashboard_page.dart';
import '../../features/tutor_dashboard/presentation/pages/tutor_historial_page.dart';
import '../../features/permisos_salud/presentation/pages/solicitar_permiso_page.dart';
import '../../features/visualizar_reportes/presentation/pages/reportes_page.dart';

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

    // ── Rutas del módulo Tutor (anidadas bajo /tutor/) ────────────────────
    GoRoute(
      path: '/tutor/dashboard',
      builder: (context, state) => const TutorDashboardPage(),
    ),
    GoRoute(
      path: '/tutor/historial',
      builder: (context, state) => const TutorHistorialPage(),
    ),
    GoRoute(
      path: '/tutor/historial/:idAlumno',
      builder: (context, state) => HistorialPage(
        idAlumno: state.pathParameters['idAlumno']!,
      ),
    ),
    GoRoute(
      path: '/tutor/solicitar-permiso',
      builder: (context, state) => const SolicitarPermisoPage(),
    ),
    GoRoute(
      path: '/tutor/reportes/:idAlumno',
      builder: (context, state) => ReportesPage(
        idAlumno: state.pathParameters['idAlumno']!,
      ),
    ),
  ],
);
