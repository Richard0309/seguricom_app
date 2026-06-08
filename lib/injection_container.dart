import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/portero_scanner/data/datasources/scanner_remote_data_source.dart';
import 'features/portero_scanner/data/repositories/scanner_repository_impl.dart';
import 'features/portero_scanner/domain/repositories/scanner_repository.dart';
import 'features/portero_scanner/domain/usecases/registrar_asistencia_usecase.dart';
import 'features/portero_scanner/presentation/bloc/scanner_bloc.dart';
import 'features/tutor_dashboard/data/datasources/tutor_remote_data_source.dart';
import 'features/tutor_dashboard/data/repositories/tutor_repository_impl.dart';
import 'features/tutor_dashboard/domain/repositories/tutor_repository.dart';
import 'features/tutor_dashboard/domain/usecases/get_hijos_usecase.dart';
import 'features/tutor_dashboard/domain/usecases/registrar_hijo_usecase.dart';
import 'features/tutor_dashboard/presentation/bloc/tutor_bloc.dart';
import 'features/historial_asistencia/presentation/bloc/historial_bloc.dart';
import 'features/historial_asistencia/data/datasources/historial_remote_data_source.dart';
import 'features/historial_asistencia/domain/usecases/get_historial_usecase.dart';
import 'features/historial_asistencia/data/repositories/historial_repository_impl.dart';
import 'features/historial_asistencia/domain/repositories/historial_repository.dart';
import 'features/permisos_salud/presentation/bloc/permisos_bloc.dart';
import 'features/permisos_salud/presentation/bloc/solicitar_permiso_bloc.dart';
import 'features/permisos_salud/data/datasources/permisos_remote_data_source.dart';
import 'features/permisos_salud/domain/usecases/solicitar_permiso_usecase.dart';
import 'features/permisos_salud/data/repositories/permisos_repository_impl.dart';
import 'features/permisos_salud/domain/repositories/permisos_repository.dart';


/// Instancia global del Service Locator.
final sl = GetIt.instance;

/// Registra todas las dependencias de la aplicación.
/// Debe llamarse en [main] antes de [runApp], después de [Firebase.initializeApp].
Future<void> init() async {
  // ─────────────────────────────────────────────────────────────────────────
  // FEATURE: AUTH
  // ─────────────────────────────────────────────────────────────────────────

  sl.registerFactory(
    () => AuthBloc(sl<LoginUseCase>()),
  );

  sl.registerLazySingleton(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // FEATURE: PORTERO SCANNER
  // ─────────────────────────────────────────────────────────────────────────

  // 1. PRESENTATION — BLoC
  // registerFactory crea una nueva instancia por cada pantalla, evitando que
  // un estado previo contamine la próxima apertura del escáner.
  sl.registerFactory(
    () => ScannerBloc(sl<RegistrarAsistenciaUseCase>()),
  );

  // 2. DOMAIN — Casos de uso
  // LazySingleton: se instancia sólo cuando se pide por primera vez.
  sl.registerLazySingleton(
    () => RegistrarAsistenciaUseCase(sl<ScannerRepository>()),
  );

  // 3. DATA — Repositorio (registrado bajo la interfaz de dominio)
  sl.registerLazySingleton<ScannerRepository>(
    () => ScannerRepositoryImpl(sl<ScannerRemoteDataSource>()),
  );

  // 4. DATA — DataSource
  sl.registerLazySingleton<ScannerRemoteDataSource>(
    () => ScannerRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // EXTERNAL — Paquetes de terceros
  // ─────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);




  // ---------------------------------------------------------------------------
  // FEATURE: TUTOR DASHBOARD
  // ---------------------------------------------------------------------------
  // FEATURE: TUTOR DASHBOARD
  // ---------------------------------------------------------------------------

  // 1. PRESENTATION — BLoC (nueva instancia por pantalla)
  sl.registerFactory(
    () => TutorBloc(sl<GetHijosUseCase>(), sl<RegistrarHijoUseCase>()),
  );

  // 2. DOMAIN — Casos de uso
  sl.registerLazySingleton(() => GetHijosUseCase(sl<TutorRepository>()));
  sl.registerLazySingleton(() => RegistrarHijoUseCase(sl<TutorRepository>()));

  // 3. DATA — Repositorio (registrado bajo la interfaz de dominio)
  sl.registerLazySingleton<TutorRepository>(
    () => TutorRepositoryImpl(sl<TutorRemoteDataSource>()),
  );

  // 4. DATA — DataSource
  sl.registerLazySingleton<TutorRemoteDataSource>(
    () => TutorRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );

  // ---------------------------------------------------------------------------
  // FEATURE: HISTORIAL ASISTENCIA
  // ---------------------------------------------------------------------------
  
  // BLoC
  sl.registerFactory(() => HistorialBloc(getHistorialUseCase: sl()));

  // Casos de Uso
  sl.registerLazySingleton(() => GetHistorialUseCase(sl()));

  // Repositorio
  sl.registerLazySingleton<HistorialRepository>(
    () => HistorialRepositoryImpl(sl()),
  );

  // Data Source
  sl.registerLazySingleton<HistorialRemoteDataSource>(
    () => HistorialRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );

  // ---------------------------------------------------------------------------
  // FEATURE: PERMISOS SALUD
  // ---------------------------------------------------------------------------

  // 1. PRESENTATION — BLoC
  sl.registerFactory(
    () => PermisosBloc(solicitarPermisoUseCase: sl()),
  );

  sl.registerFactory(
    () => SolicitarPermisoBloc(
          getHijosUseCase: sl(),
          solicitarPermisoUseCase: sl(),
        ),
  );

  // 2. DOMAIN — Casos de uso
  sl.registerLazySingleton(() => SolicitarPermisoUseCase(sl()));

  // 3. DATA — Repositorio (registrado bajo la interfaz de dominio)
  sl.registerLazySingleton<PermisosRepository>(
    () => PermisosRepositoryImpl(sl()),
  );

  // 4. DATA — DataSource
  sl.registerLazySingleton<PermisosRemoteDataSource>(
    () => PermisosRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
}
