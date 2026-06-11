# CES'C — Administración Escolar Móvil

Aplicación móvil multiplataforma para la gestión de asistencia y permisos en instituciones educativas. Permite a los **porteros** registrar la entrada/salida de alumnos mediante escaneo de QR, y a los **tutores/padres** consultar historial, gestionar hijos y solicitar justificantes médicos.

---

## Roles

### Portero
- Escanea códigos QR de los alumnos para registrar asistencia.
- El sistema determina automáticamente si es **entrada** o **salida**.
- Visualiza feedback inmediato (acceso permitido / denegado).

### Tutor (Padre/Madre)
- Visualiza el panel con sus hijos registrados.
- Registra nuevos hijos vinculándolos a su cuenta.
- Consulta el historial de asistencias de cada hijo.
- Solicita justificantes médicos (permisos de salud) adjuntando evidencia.

---

## Funcionalidades

### Autenticación (`auth`)
- Login con correo electrónico y contraseña vía Firebase Auth.
- Routing automático según el rol del usuario (`portero` → escáner, `tutor` → panel).
- Mapeo de errores de Firebase a mensajes en español.

### Escáner QR — Portero (`portero_scanner`)
- Cámara en tiempo real usando `mobile_scanner`.
- Validación del código QR contra la colección `alumnos` en Firestore.
- Registro automático de entrada o salida según el historial del día.
- Diálogo modal con resultado visual (verde/rojo) y cierre automático.

### Historial de Asistencia (`historial_asistencia`)
- Lista cronológica de registros de asistencia de un alumno.
- Tarjetas coloreadas por tipo (verde = entrada, naranja = salida).
- Consulta ordenada por marca de tiempo del servidor (más reciente primero).

### Permisos de Salud (`permisos_salud`)
- Formulario para solicitar justificantes médicos.
- Selector del alumno (hijos del tutor).
- Campos: motivo y URL del archivo adjunto.
- Escritura atómica en Firestore con marca de tiempo.

### Visualización de Reportes (`visualizar_reportes`)
- Lectura de reportes generados por el administrador desde la colección `reportes`.
- Filtrado por alumno (`idAlumno`) y ordenados por fecha descendente.
- Tarjetas con tipo, descripción, estado (badge coloreado) y fecha formateada en locale `es_MX`.
- Estados de carga, vacío y error con reintento.

### Panel del Tutor (`tutor_dashboard`)
- Lista de hijos registrados con nombre, grado y grupo.
- Registro de hijos con formulario modal (bottom sheet deslizable).
- Operación atómica: crea documento del alumno y actualiza array `hijos` del tutor.
- Navegación rápida al historial de cada hijo.

### Navegación Compartida (`shared`)
- Sidebar reutilizable (`AppSidebar`) con menú de navegación.
- Header con información del usuario autenticado.
- Resaltado de la ruta activa.
- Cierre de sesión.

---

## Stack Tecnológico

| Componente | Tecnología |
|------------|------------|
| Framework | Flutter 3.x |
| Lenguaje | Dart SDK ^3.11.4 |
| Autenticación | Firebase Auth 5.x |
| Base de datos | Cloud Firestore 5.x |
| Gestión de estado | flutter_bloc 9.x |
| Manejo de errores | dartz 0.10.x (Either) |
| Inyección de dependencias | get_it 9.x |
| Navegación | go_router 17.x |
| Escaneo QR | mobile_scanner 7.x |
| Igualdad de valores | equatable 2.x |
| Formateo de fechas | intl 0.20.x |

---

## Estructura del Proyecto

```
lib/
├── main.dart                              # Entry point
├── injection_container.dart               # Service Locator (get_it)
├── firebase_options.dart                  # Configuración Firebase
├── core/
│   ├── errors/
│   │   ├── exceptions.dart                # Excepciones de la capa de datos
│   │   └── failures.dart                  # Fallos del dominio
│   └── router/
│       └── app_router.dart                # Rutas con go_router
└── features/
    ├── auth/                              # Autenticación (8 archivos)
    ├── portero_scanner/                   # Escáner QR (10 archivos)
    ├── historial_asistencia/              # Historial (10 archivos)
    ├── permisos_salud/                    # Permisos de salud (13 archivos)
    ├── tutor_dashboard/                   # Panel del tutor (14 archivos)
    ├── visualizar_reportes/               # Visualización de reportes (8 archivos)
    └── shared/                            # Widgets reutilizables (1 archivo)
```

Cada feature sigue la estructura **Clean Architecture**:

```
feature/
├── data/
│   ├── datasources/     # Acceso a Firebase/Firestore
│   ├── models/          # Serialización JSON
│   └── repositories/    # Implementación de contratos de dominio
├── domain/
│   ├── entities/        # Modelos de negocio puros
│   ├── repositories/    # Contratos abstractos
│   └── usecases/        # Orquestación de lógica
└── presentation/
    ├── bloc/            # Events, States, BLoC
    ├── pages/           # Pantallas principales
    └── widgets/         # Componentes de UI
```

---

## Rutas de Navegación

| Ruta | Descripción | Rol |
|------|-------------|-----|
| `/` | Login | Todos |
| `/portero` | Escáner QR | Portero |
| `/tutor/dashboard` | Panel principal del tutor | Tutor |
| `/tutor/historial` | Selección de alumno para historial | Tutor |
| `/tutor/historial/:idAlumno` | Historial de asistencia del alumno | Tutor |
| `/tutor/solicitar-permiso` | Formulario de justificante médico | Tutor |
| `/tutor/reportes/:idAlumno` | Visualización de reportes del alumno | Tutor |

---

## Getting Started

### Prerrequisitos

- Flutter SDK ^3.11.4
- Cuenta de Firebase configurada
- Proyecto Firebase con Auth y Firestore habilitados

### Instalación

```bash
# Clonar el repositorio
git clone <url_del_repositorio>

# Instalar dependencias
flutter pub get

# Configurar Firebase (si no está configurado)
flutterfire configure

# Ejecutar la aplicación
flutter run
```

### Configuración de Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com/).
2. Habilitar **Firebase Authentication** con proveedor de Email/Password.
3. Crear **Cloud Firestore** en modo de prueba o producción.
4. Ejecutar `flutterfire configure` para generar `lib/firebase_options.dart`.
5. Configurar las reglas de Firestore según el entorno.

### Colecciones Firestore Requeridas

| Colección | Descripción |
|-----------|-------------|
| `usuarios` | Perfiles de usuario con campo `rol` ('portero' o 'tutor') y array `hijos` |
| `alumnos` | Registros de alumnos (nombre, grado, grupo) |
| `asistencias` | Registros de entrada/salida con fecha, hora y tipo |
| `permisos` | Solicitudes de justificantes médicos |
| `reportes` | Reportes generados por admin (tipo, descripción, estado, fecha, idAlumno, creadoPor) |

### Datos de Prueba

Para probar la aplicación, crear documentos en Firestore:

**Usuario Portero:**
```
usuarios/{uid-del-portero}
  rol: "portero"
```

**Usuario Tutor:**
```
usuarios/{uid-del-tutor}
  rol: "tutor"
  hijos: ["id-alumno-1", "id-alumno-2"]
```

**Alumno:**
```
alumnos/{id-auto-generado}
  idAlumno: "{id-auto-generado}"
  nombre: "Juan Pérez"
  grado: "3°"
  grupo: "A"
```

---

## Comandos Útiles

```bash
# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS
flutter run -d ios

# Ejecutar en Chrome (web)
flutter run -d chrome

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Build de producción
flutter build apk --release
flutter build ios --release
```

---

## Arquitectura

Para información detallada sobre la arquitectura del proyecto, consultar [Arquitectura.md](Arquitectura.md).

---

## Licencia

Proyecto privado — CESC Administración Escolar.
