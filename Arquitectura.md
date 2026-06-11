# Arquitectura del Proyecto — CES'C

## Visión General

La aplicación **CES'C — Administración Escolar Móvil** está construida siguiendo el patrón **Clean Architecture** con **BLoC** para la gestión de estado. Cada feature se organiza en tres capas independientes que se comunican mediante contratos abstractos.

### Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Framework | Flutter 3.x (Dart SDK ^3.11.4) |
| Autenticación | Firebase Auth |
| Base de datos | Cloud Firestore |
| Gestión de estado | flutter_bloc 9.x |
| Manejo de errores | dartz (Either monad) |
| Inyección de dependencias | get_it 9.x |
| Navegación | go_router 17.x |
| Escaneo QR | mobile_scanner 7.x |
| Igualdad de valores | equatable 2.x |

---

## Arquitectura de Capas

```
┌─────────────────────────────────────────────────┐
│               PRESENTATION                       │
│  (BLoC, Events, States, Pages, Widgets)         │
│                                                  │
│  Depende de → DOMAIN (Use Cases, Entities)      │
├─────────────────────────────────────────────────┤
│                   DOMAIN                         │
│  (Entities, Repository Contracts, Use Cases)     │
│                                                  │
│  Sin dependencias de frameworks externos         │
├─────────────────────────────────────────────────┤
│                    DATA                          │
│  (Models, DataSources, Repository Implementations)│
│                                                  │
│  Depende de → DOMAIN (implementa contratos)     │
│  Usa: Firebase Auth, Cloud Firestore             │
└─────────────────────────────────────────────────┘
```

**Flujo de dependencias:**
- `PRESENTATION` → `DOMAIN` ← `DATA`
- La capa `DOMAIN` no conoce a `DATA` ni a `PRESENTATION`
- La `DATA` implementa los contratos definidos en `DOMAIN`
- La `PRESENTATION` consume casos de uso de `DOMAIN`

### Manejo de Errores

```
DataSource  ──lanza──▶  ServerException / NotFoundException
     │                        │
     ▼                        ▼
RepositoryImpl  ──captura──▶  Failure (ServerFailure / NotFoundFailure)
     │                        │
     ▼                        ▼
UseCase  ──retorna──▶  Either<Failure, T>
     │                        │
     ▼                        ▼
BLoC  ──fold──▶  State success | State error
```

- **Excepciones** (`core/errors/exceptions.dart`): Se lanzan desde los DataSources, nunca escapan del RepositoryImpl.
- **Fallos** (`core/errors/failures.dart`): Clases base con `Equatable` que representan errores de dominio.
- **Either**: Monad funcional de `dartz` que garantiza manejo explícito de éxito/fallo.

---

## Core

### `core/errors/exceptions.dart`

Excepciones de la capa de datos. Se lanzan desde los DataSources y se capturan en los RepositoryImpl.

| Excepción | Uso |
|-----------|-----|
| `ServerException` | Error genérico de comunicación con servicios remotos |
| `NotFoundException` | El documento solicitado no existe en Firestore |

### `core/errors/failures.dart`

Clases de fallo del dominio. Extienden `Equatable` para comparación por valor.

| Fallo | Uso |
|-------|-----|
| `ServerFailure` | Error de servidor (mapeado desde `ServerException`) |
| `NotFoundFailure` | Recurso no encontrado (mapeado desde `NotFoundException`) |
| `ValidationFailure` | Regla de negocio no cumplida |

### `core/router/app_router.dart`

Router declarativo con `go_router`. Rutas planas sin anidamiento.

| Ruta | Página | Feature |
|------|--------|---------|
| `/` | `LoginPage` | auth |
| `/portero` | `ScannerPage` | portero_scanner |
| `/tutor/dashboard` | `TutorDashboardPage` | tutor_dashboard |
| `/tutor/historial` | `TutorHistorialPage` | tutor_dashboard |
| `/tutor/historial/:idAlumno` | `HistorialPage` | historial_asistencia |
| `/tutor/solicitar-permiso` | `SolicitarPermisoPage` | permisos_salud |
| `/tutor/reportes/:idAlumno` | `ReportesPage` | visualizar_reportes |

### Directorios Vacíos (reservados)

`constants/`, `network/`, `theme/`, `utils/` — scaffolding para implementación futura.

---

## Feature: Auth

**Directorio:** `lib/features/auth/`
**Archivos:** 8

### Estructura

```
auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── login_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    └── pages/
        └── login_page.dart
```

### Flujo de Autenticación

```
LoginPage ──dispara──▶ LoginEvent(email, password)
    │
    ▼
AuthBloc ──llama──▶ LoginUseCase
    │
    ▼
AuthRepository (abstracto) ──implementado por──▶ AuthRepositoryImpl
    │
    ▼
AuthRemoteDataSourceImpl
    │
    ├─ 1. Firebase Auth: signInWithEmailAndPassword
    ├─ 2. Firestore: lee colección `usuarios` → documento del UID
    └─ 3. Extrae campo `rol` → retorna 'portero' | 'tutor'
```

### Estados del BLoC

| Estado | Descripción |
|--------|-------------|
| `AuthInitial` | Formulario listo, sin interacción |
| `AuthLoading` | Autenticación en curso |
| `Authenticated(rol)` | Login exitoso, contiene el rol |
| `AuthError(message)` | Fallo en la autenticación |

### Routing por Rol

Tras login exitoso, `LoginPage` redirige según el valor de `rol`:
- `'portero'` → `/portero`
- `'tutor'` → `/tutor/dashboard`

### Mapeo de Errores Firebase

| Código Firebase | Mensaje en Español |
|----------------|-------------------|
| `user-not-found` / `wrong-password` / `invalid-credential` | Correo o contraseña incorrectos |
| `user-disabled` | Esta cuenta ha sido deshabilitada |
| `too-many-requests` | Demasiados intentos fallidos |
| `network-request-failed` | Sin conexión a internet |

---

## Feature: Portero Scanner

**Directorio:** `lib/features/portero_scanner/`
**Archivos:** 10
**Rol requerido:** Portero

### Estructura

```
portero_scanner/
├── data/
│   ├── datasources/
│   │   └── scanner_remote_data_source.dart
│   └── repositories/
│       └── scanner_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── asistencia_entity.dart
│   ├── repositories/
│   │   └── scanner_repository.dart
│   └── usecases/
│       └── registrar_asistencia_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── scanner_bloc.dart
    │   ├── scanner_event.dart
    │   └── scanner_state.dart
    ├── pages/
    │   └── scanner_page.dart
    └── widgets/
        └── resultado_scan_dialog.dart
```

### Flujo de Escaneo QR

```
ScannerPage (cámara activa)
    │
    ▼ detecta QR
EscanearQREvent(idAlumno)
    │
    ▼
ScannerBloc ──llama──▶ RegistrarAsistenciaUseCase
    │
    ▼
ScannerRemoteDataSourceImpl
    │
    ├─ 1. Verifica que el alumno exista en colección `alumnos`
    ├─ 2. Consulta si ya tiene 'entrada' hoy en `asistencias`
    │     ├─ No tiene → tipo = 'entrada'
    │     └─ Ya tiene → tipo = 'salida'
    └─ 3. Crea documento en `asistencias` con fecha, hora, tipo
```

### Lógica de Entrada/Salida

El sistema determina automáticamente si registrar **entrada** o **salida**:
1. Se busca si existe un registro con `tipo == 'entrada'` para el alumno en la fecha actual.
2. Si **no existe** → se registra como `entrada`.
3. Si **ya existe** → se registra como `salida`.

### Estados del BLoC

| Estado | Descripción |
|--------|-------------|
| `ScannerInitial` | Cámara activa, esperando QR |
| `ScannerLoading` | Validando QR en Firebase |
| `ScannerSuccess(asistencia)` | Registro exitoso |
| `ScannerError(message)` | QR inválido o error de Firestore |

### Comportamiento de la UI

1. Al detectar un QR válido, la cámara se **pausa** (`_controller.stop()`).
2. Se muestra un overlay de "Validando..." mientras Firebase procesa.
3. Se muestra un **diálogo modal** de resultado:
   - **Éxito** (fondo verde): "Acceso Permitido" + tipo de registro + hora.
   - **Error** (fondo rojo): "Acceso Denegado" + mensaje.
4. Tras 2 segundos: se cierra el diálogo, se reanuda la cámara y se resetea el BLoC.
5. Se bloquean escaneos múltiples verificando que el estado sea `ScannerInitial`.

### Entidad de Dominio

```dart
AsistenciaEntity {
  String idAlumno;   // ID del documento en Firestore
  String fecha;      // Formato AAAA-MM-DD
  String hora;       // Formato HH:MM:SS
  String tipo;       // 'entrada' | 'salida'
}
```

---

## Feature: Historial de Asistencia

**Directorio:** `lib/features/historial_asistencia/`
**Archivos:** 10
**Rol requerido:** Tutor

### Estructura

```
historial_asistencia/
├── data/
│   ├── datasources/
│   │   └── historial_remote_data_source.dart
│   ├── models/
│   │   └── asistencia_model.dart
│   └── repositories/
│       └── historial_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── asistencia_entity.dart
│   ├── repositories/
│   │   └── historial_repository.dart
│   └── usecases/
│       └── get_historial_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── historial_bloc.dart
    │   ├── historial_event.dart
    │   └── historial_state.dart
    └── pages/
        └── historial_page.dart
```

### Flujo de Consulta

```
HistorialPage(idAlumno)
    │
    ▼ initState
CargarHistorialEvent(idAlumno)
    │
    ▼
HistorialBloc ──llama──▶ GetHistorialUseCase
    │
    ▼
HistorialRemoteDataSourceImpl
    │
    ├─ Consulta colección `asistencias`
    │   .where('idAlumno', isEqualTo: idAlumno)
    │   .orderBy('serverTimestamp', descending: true)
    │
    └─ Retorna List<AsistenciaModel>
```

### Modelo de Datos

`AsistenciaModel` extiende `AsistenciaEntity` y añade:
- `fromJson(Map<String, dynamic>)` — deserialización desde Firestore
- `toJson()` — serialización para escritura
- `fromEntity(AsistenciaEntity)` — conversión desde entidad de dominio

### Estados del BLoC

| Estado | Descripción |
|--------|-------------|
| `HistorialInitial` | Estado inicial |
| `HistorialLoading` | Carga en curso |
| `HistorialLoaded(asistencias)` | Lista de registros (puede estar vacía) |
| `HistorialError(message)` | Error de carga con botón de reintentar |

### UI

- Lista de tarjetas coloreadas por tipo:
  - **Verde** con ícono de entrada (`login_rounded`)
  - **Naranja** con ícono de salida (`logout_rounded`)
- Cada tarjeta muestra: tipo, fecha y hora.
- Estado vacío con mensaje informativo.
- Estado de error con botón "Reintentar".

---

## Feature: Permisos de Salud

**Directorio:** `lib/features/permisos_salud/`
**Archivos:** 13
**Rol requerido:** Tutor

### Estructura

```
permisos_salud/
├── data/
│   ├── datasources/
│   │   └── permisos_remote_data_source.dart
│   ├── models/
│   │   └── permiso_model.dart
│   └── repositories/
│       └── permisos_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── permiso_entity.dart
│   ├── repositories/
│   │   └── permisos_repository.dart
│   └── usecases/
│       └── solicitar_permiso_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── permisos_bloc.dart
    │   ├── permisos_event.dart
    │   ├── permisos_state.dart
    │   ├── solicitar_permiso_bloc.dart
    │   ├── solicitar_permiso_event.dart
    │   └── solicitar_permiso_state.dart
    └── pages/
        └── solicitar_permiso_page.dart
```

### Arquitectura Dual: Dos BLoCs Cooperadores

Este feature utiliza **dos BLoCs** proporcionados vía `MultiBlocProvider`:

| BLoC | Responsabilidad | Casos de Uso |
|------|-----------------|--------------|
| `SolicitarPermisoBloc` | Carga hijos del tutor | `GetHijosUseCase` (de tutor_dashboard) |
| `PermisosBloc` | Envío del justificante | `SolicitarPermisoUseCase` |

**Flujo:**
1. Al montar la página, se dispara `CargarHijosEvent(tutorUid)` → `SolicitarPermisoBloc`.
2. Se carga la lista de hijos del tutor para el selector del formulario.
3. Al enviar, se construye `PermisoEntity` con los datos del formulario.
4. Se dispara `EnviarPermisoEvent(permiso)` → `PermisosBloc`.
5. Tras envío exitoso, se muestra SnackBar y se redirige a `/tutor/dashboard`.

### Entidad de Dominio

```dart
PermisoEntity {
  String id;            // ID auto-generado por Firestore
  String idAlumno;      // Alumno al que se refiere
  String nombreAlumno;  // Nombre desnormalizado
  String tutorUid;      // UID del tutor solicitante
  String nombreTutor;   // Nombre desnormalizado
  String motivo;        // Descripción del justificante
  String archivoUrl;    // URL del archivo adjunto
  String estado;        // 'pendiente' | 'aprobado' | 'rechazado'
}
```

### Escritura en Firestore

El `PermisosRemoteDataSourceImpl`:
1. Genera una referencia con ID auto-generado: `_firestore.collection('permisos').doc()`.
2. Serializa el modelo a JSON.
3. Inyecta `fechaSolicitud: FieldValue.serverTimestamp()`.
4. Escribe con `docRef.set(data)`.

### Dependencia Cross-Feature

`SolicitarPermisoBloc` importa del feature `tutor_dashboard`:
- `GetHijosUseCase` — para cargar los hijos del tutor
- `AlumnoEntity` — para el selector del formulario

---

## Feature: Visualización de Reportes

**Directorio:** `lib/features/visualizar_reportes/`
**Archivos:** 8
**Rol requerido:** Tutor

### Estructura

```
visualizar_reportes/
├── data/
│   ├── datasources/
│   │   └── reportes_remote_data_source.dart
│   ├── models/
│   │   └── reporte_model.dart
│   └── repositories/
│       └── reportes_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── reporte_entity.dart
│   ├── repositories/
│   │   └── reportes_repository.dart
│   └── usecases/
│       └── get_reportes_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── reportes_bloc.dart
    │   ├── reportes_event.dart
    │   └── reportes_state.dart
    └── pages/
        └── reportes_page.dart
```

### Flujo de Consulta

```
ReportesPage(idAlumno)
    │
    ▼ initState
CargarReportesEvent(idAlumno)
    │
    ▼
ReportesBloc ──llama──▶ GetReportesUseCase
    │
    ▼
ReportesRemoteDataSourceImpl
    │
    ├─ Consulta colección `reportes`
    │   .where('idAlumno', isEqualTo: idAlumno)
    │   .orderBy('fecha', descending: true)
    │
    └─ Retorna List<ReporteModel>
```

### Modelo de Datos

`ReporteModel` extiende `ReporteEntity` y añade:
- `fromJson(Map<String, dynamic>)` — deserialización desde Firestore (convierte `Timestamp` a `DateTime`)
- `toJson()` — serialización para escritura
- `fromEntity(ReporteEntity)` — conversión desde entidad de dominio

### Entidad de Dominio

```dart
ReporteEntity {
  String creadoPor;      // Usuario que generó el reporte
  String descripcion;    // Contenido del reporte
  String estado;         // 'generado' | 'pendiente' | 'informativo' | 'atendido' | 'leido' | 'rechazado' | 'cancelado'
  DateTime fecha;        // Fecha y hora del reporte (convertida desde Timestamp)
  String idAlumno;       // ID del alumno referenciado
  String tipo;           // Tipo de reporte (ej. 'citatorio')
}
```

### Estados del BLoC

| Estado | Descripción |
|--------|-------------|
| `ReportesInitial` | Estado inicial |
| `ReportesLoading` | Carga en curso |
| `ReportesLoaded(reportes)` | Lista de reportes (puede estar vacía) |
| `ReportesError(message)` | Error de carga con botón de reintentar |

### UI — Tarjetas de Reporte

Cada reporte se muestra en una `Card` con:

| Elemento | Descripción |
|----------|-------------|
| **Título** | Campo `tipo` (ej. "Citatorio") |
| **Badge Estado** | Color según `estado`: |
| | • Naranja: `generado`, `pendiente` |
| | • Azul: `informativo` |
| | • Verde: `atendido`, `leido` |
| | • Rojo: `rechazado`, `cancelado` |
| **Descripción** | Campo `descripcion` |
| **Fecha** | Formateada con `intl`: `dd 'de' MMMM, yyyy - hh:mm a` (locale `es_MX`) → ej. "10 de junio de 2026 - 03:15 PM" |
| **Creado por** | Campo `creadoPor` (si no vacío) |

### Manejo de Errores Específico

En `ReportesRemoteDataSourceImpl` se detecta el error `failed-precondition` de Firestore (índice compuesto faltante) y se lanza un `ServerException` con mensaje guiado para crear el índice desde la consola de Firebase.

### Integración en Dashboard

Desde `TutorDashboardPage`, cada tarjeta de alumno incluye un botón **"Reportes"** que navega a `/tutor/reportes/:idAlumno` usando `go_router`.

---

## Feature: Tutor Dashboard

## Feature: Tutor Dashboard

**Directorio:** `lib/features/tutor_dashboard/`
**Archivos:** 14
**Rol requerido:** Tutor

### Estructura

```
tutor_dashboard/
├── data/
│   ├── datasources/
│   │   └── tutor_remote_data_source.dart
│   ├── models/
│   │   └── alumno_model.dart
│   └── repositories/
│       └── tutor_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── alumno_entity.dart
│   ├── repositories/
│   │   └── tutor_repository.dart
│   └── usecases/
│       ├── get_hijos_usecase.dart
│       └── registrar_hijo_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── tutor_bloc.dart
    │   ├── tutor_event.dart
    │   └── tutor_state.dart
    ├── pages/
    │   ├── tutor_dashboard_page.dart
    │   └── tutor_historial_page.dart
    └── widgets/
        └── registro_hijo_modal.dart
```

### Casos de Uso

| Use Case | Descripción | Retorno |
|----------|-------------|---------|
| `GetHijosUseCase` | Obtiene hijos del tutor desde Firestore | `Either<Failure, List<AlumnoEntity>>` |
| `RegistrarHijoUseCase` | Registra hijo y lo vincula al tutor | `Either<Failure, void>` |

### Flujo: Obtener Hijos

```
TutorDashboardPage
    │
    ▼ initState
CargarHijosEvent(tutorUid)
    │
    ▼
TutorRemoteDataSourceImpl
    │
    ├─ 1. Lee documento del tutor en `usuarios` → campo `hijos` (array de IDs)
    ├─ 2. Divide en chunks de 30 (límite de Firestore `whereIn`)
    ├─ 3. Consulta colección `alumnos` con `whereIn` por cada chunk
    └─ 4. Retorna List<AlumnoModel>
```

### Flujo: Registrar Hijo

```
RegistroHijoModal → _onRegistrar()
    │
    ▼
RegistrarNuevoHijoEvent(tutorUid, nuevoAlumno)
    │
    ▼
TutorRemoteDataSourceImpl.registrarHijo()
    │
    ├─ 1. Genera referencia con ID auto-generado
    ├─ 2. Crea WriteBatch atómico:
    │     ├─ batch.set(nuevoAlumnoRef, alumnoData)
    │     └─ batch.update(tutorRef, { 'hijos': FieldValue.arrayUnion([nuevoId]) })
    └─ 3. batch.commit() — operación atómica
```

### Entidad de Dominio

```dart
AlumnoEntity {
  String idAlumno;  // ID del documento en Firestore
  String nombre;    // Nombre completo
  String grado;     // Grado escolar (ej. "1°")
  String grupo;     // Grupo/sección (ej. "A")
}
```

### Páginas

| Página | Descripción |
|--------|-------------|
| `TutorDashboardPage` | Lista de hijos registrados con FAB para añadir |
| `TutorHistorialPage` | Selector de alumno para ver historial |
| `RegistroHijoModal` | Bottom sheet deslizable con formulario de registro |

### Estados del BLoC

| Estado | Descripción |
|--------|-------------|
| `TutorInitial` | Estado inicial |
| `TutorLoading` | Operación en curso |
| `TutorLoaded(hijos)` | Lista de hijos obtenida |
| `TutorError(message)` | Error con opción de reintentar |

---

## Feature: Shared

**Directorio:** `lib/features/shared/`
**Archivos:** 1

### `AppSidebar`

Widget `Drawer` reutilizable usado en todas las pantallas del módulo Tutor.

| Elemento | Ruta | Ícono |
|----------|------|-------|
| Mi Panel | `/tutor/dashboard` | `home` |
| Historial de Asistencias | `/tutor/historial` | `history` |
| Solicitar Justificante | `/tutor/solicitar-permiso` | `medical_services` |
| Cerrar Sesión | (signOut + `/`) | `logout` |

Funcionalidades:
- `UserAccountsDrawerHeader` con nombre, email y avatar (iniciales).
- Resaltado del menú activo basado en la ruta actual (`GoRouterState`).
- Cierre de sesión con `FirebaseAuth.signOut()`.

---

## Inyección de Dependencias

**Archivo:** `lib/injection_container.dart`
**Librería:** `get_it`

### Patrones de Registro

| Método | Uso | Ejemplo |
|--------|-----|---------|
| `registerFactory` | Nueva instancia por cada pantalla | `AuthBloc`, `ScannerBloc`, `TutorBloc`, `HistorialBloc`, `PermisosBloc`, `SolicitarPermisoBloc` |
| `registerLazySingleton` | Instancia única, se crea al primer uso | Use Cases, Repositories, DataSources, Firebase instances |

### Orden de Inicialización

```dart
Future<void> init() async {
  // 1. Externos
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // 2. Por feature (de dentro hacia afuera):
  //    DataSource → Repository → UseCase → BLoC
}
```

### Dependencias Externas

```dart
sl.registerLazySingleton(() => FirebaseAuth.instance);
sl.registerLazySingleton(() => FirebaseFirestore.instance);
```

---

## Colecciones Firestore

### `usuarios`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `rol` | `String` | `'portero'` o `'tutor'` |
| `hijos` | `List<String>` | Array de IDs de documentos en `alumnos` (solo tutores) |

**Documento ID:** UID de Firebase Auth.

### `alumnos`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `idAlumno` | `String` | ID del documento (redundante, para lectura externa) |
| `nombre` | `String` | Nombre completo |
| `grado` | `String` | Grado escolar |
| `grupo` | `String` | Grupo/sección |

**Documento ID:** Auto-generado por Firestore.

### `asistencias`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `idAlumno` | `String` | ID del alumno |
| `fecha` | `String` | Formato `AAAA-MM-DD` |
| `hora` | `String` | Formato `HH:MM:SS` |
| `tipo` | `String` | `'entrada'` o `'salida'` |
| `serverTimestamp` | `Timestamp` | Marca de tiempo del servidor (para ordenamiento) |

### `permisos`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `String` | ID del documento |
| `idAlumno` | `String` | Alumno referenciado |
| `nombreAlumno` | `String` | Nombre desnormalizado |
| `tutorUid` | `String` | UID del tutor solicitante |
| `nombreTutor` | `String` | Nombre desnormalizado |
| `motivo` | `String` | Descripción del justificante |
| `archivoUrl` | `String` | URL del archivo adjunto |
| `estado` | `String` | `'pendiente'` / `'aprobado'` / `'rechazado'` |
| `fechaSolicitud` | `Timestamp` | Marca de tiempo del servidor |

### `reportes`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `creadoPor` | `String` | Usuario que generó el reporte |
| `descripcion` | `String` | Contenido del reporte |
| `estado` | `String` | `'generado'` / `'pendiente'` / `'informativo'` / `'atendido'` / `'leido'` / `'rechazado'` / `'cancelado'` |
| `fecha` | `Timestamp` | Fecha y hora de generación |
| `idAlumno` | `String` | ID del alumno referenciado |
| `tipo` | `String` | Tipo de reporte (ej. `'citatorio'`) |

---

## Diagrama de Navegación

```
                    ┌─────────────┐
                    │  LoginPage  │  (/)
                    └──────┬──────┘
                           │
               ┌────────────┴────────────┐
               │                         │
               ▼                         ▼
      ┌────────────────┐      ┌──────────────────┐
      │  ScannerPage   │      │ TutorDashboard   │
      │   (/portero)   │      │(/tutor/dashboard)│
      └────────────────┘      └────────┬─────────┘
                                       │
                           ┌───────────┼───────────┐
                           │           │           │
                           ▼           ▼           ▼
                    ┌──────────┐ ┌──────────┐ ┌──────────────────┐
                    │Historial │ │Historial │ │SolicitarPermiso  │
                    │ Page     │ │ (selec.) │ │     Page         │
                    │(:idAlumno)│ │(/tutor/  │ │(/tutor/solicitar-│
                    └──────────┘ │historial)│ │    permiso)      │
                                 └──────────┘ └──────────────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │Reportes Page     │
                              │(/tutor/reportes/ │
                              │ :idAlumno)       │
                              └──────────────────┘
```
