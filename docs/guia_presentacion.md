# 🎓 Guía Completa de Presentación — FisioIA

> **Objetivo de este documento:** Que puedas entender CADA línea de código del proyecto, saber explicar cualquier decisión técnica y responder con seguridad a las preguntas del tribunal.

---

## 📑 ÍNDICE

1. [¿Qué es FisioIA?](#1-qué-es-fisioia)
2. [Tecnologías y por qué se eligieron](#2-tecnologías-y-por-qué-se-eligieron)
3. [Arquitectura del proyecto](#3-arquitectura-del-proyecto)
4. [Conceptos de Dart que DEBES saber](#4-conceptos-de-dart-que-debes-saber)
5. [Conceptos de Flutter que DEBES saber](#5-conceptos-de-flutter-que-debes-saber)
6. [Análisis archivo por archivo](#6-análisis-archivo-por-archivo)
7. [Flujo completo de la app (de principio a fin)](#7-flujo-completo-de-la-app)
8. [Patrones de diseño usados](#8-patrones-de-diseño-usados)
9. [Firebase: Auth + Firestore](#9-firebase-auth--firestore)
10. [Integración con Azure OpenAI](#10-integración-con-azure-openai)
11. [Seguridad](#11-seguridad)
12. [Preguntas frecuentes del tribunal](#12-preguntas-frecuentes-del-tribunal)
13. [Glosario rápido](#13-glosario-rápido)
14. [Chuleta de última hora](#14-chuleta-de-última-hora)

---

## 1. ¿Qué es FisioIA?

**FisioIA** es una aplicación móvil de fisioterapia asistida por inteligencia artificial. Permite al usuario:

- 📋 **Explorar ejercicios** organizados por zona corporal (rodilla, hombro, lumbar, etc.)
- 🏋️ **Crear y gestionar rutinas** de ejercicios (manuales o generadas por IA)
- 🤖 **Chatear con un asistente de IA** (Azure OpenAI) que recomienda ejercicios personalizados según la dolencia del usuario
- 👤 **Gestionar su perfil** (nombre, edad, nivel de experiencia, zona principal, objetivos)
- 🔐 **Autenticarse** con email/contraseña o Google Sign-In
- 💾 **Sincronizar datos en la nube** (Firestore) o usar modo local/invitado

**Público objetivo:** Personas con molestias musculoesqueléticas que buscan ejercicios de rehabilitación guiados.

---

## 2. Tecnologías y por qué se eligieron

| Tecnología | Qué es | Por qué se usa |
|---|---|---|
| **Flutter** | Framework de Google para apps multiplataforma | Una sola base de código para Android, iOS y Web |
| **Dart** | Lenguaje de programación de Flutter | Tipado fuerte, null-safety, compilación nativa |
| **Firebase Auth** | Servicio de autenticación de Google | Login con email y Google Sign-In sin backend propio |
| **Cloud Firestore** | Base de datos NoSQL en la nube | Sincronización en tiempo real, escalable, serverless |
| **Azure OpenAI** | API de inteligencia artificial de Microsoft | Chat inteligente con GPT para recomendaciones personalizadas |
| **SharedPreferences** | Almacenamiento clave-valor local | Persistencia offline, historial de chat, rutinas locales |
| **Material Design 3** | Sistema de diseño de Google | Interfaz moderna, coherente, accesible |

### ¿Por qué Flutter y no Android nativo?

- **Multiplataforma**: Con un solo código funciona en Android, iOS, Web, Windows, Linux y macOS.
- **Hot Reload**: Cambios en el código se ven en tiempo real sin recompilar.
- **Declarativo**: La UI se describe como un árbol de widgets (como React), no como XML + código como en Android.
- **Rendimiento**: Se compila a código nativo ARM (no usa WebView ni puente JavaScript).

---

## 3. Arquitectura del proyecto

### Estructura de carpetas

```
app/
├── lib/
│   ├── main.dart              ← Punto de entrada de la app
│   ├── models/                ← Clases de datos (Exercise, Routine, UserProfile, Zone)
│   ├── screens/               ← Pantallas de la UI (11 pantallas)
│   ├── services/              ← Lógica de negocio y acceso a datos (9 servicios)
│   └── utils/                 ← Utilidades (asset_helper)
├── assets/
│   ├── exercises.json         ← Catálogo completo de ejercicios y zonas
│   └── images/                ← Iconos e imágenes de la app
├── pubspec.yaml               ← Dependencias y configuración del proyecto
└── firestore.rules            ← Reglas de seguridad de Firestore
```

### Diagrama de capas

```
┌─────────────────────────────────────────┐
│            PANTALLAS (screens/)          │  ← Lo que ve el usuario
│   HomeScreen, LoginScreen, ChatScreen...│
├─────────────────────────────────────────┤
│            SERVICIOS (services/)         │  ← Lógica de negocio
│   AuthService, CatalogService,          │
│   RoutineRepository, AzureOpenAI...     │
├─────────────────────────────────────────┤
│            MODELOS (models/)             │  ← Estructura de datos
│   Exercise, Routine, UserProfile, Zone  │
├─────────────────────────────────────────┤
│      ALMACENAMIENTO EXTERNO             │  ← Donde se guardan los datos
│   Firebase (Auth + Firestore)           │
│   SharedPreferences (local)             │
│   Azure OpenAI (IA)                     │
└─────────────────────────────────────────┘
```

---

## 4. Conceptos de Dart que DEBES saber

### 4.1 Variables y tipos

```dart
final String nombre = 'FisioIA';  // final = se asigna una vez y no cambia
const int limite = 10;            // const = constante de compilación (más estricto que final)
String? email;                    // ? = puede ser null (null-safety)
```

- **`final`**: Se asigna una vez en RUNTIME y no cambia después.
- **`const`**: Se conoce en COMPILACIÓN (antes de ejecutar). Es más eficiente.
- **`String?`**: El `?` significa que la variable puede ser `null`. Sin `?`, NUNCA puede ser null.

### 4.2 Null-safety (seguridad contra nulos)

Dart obliga a manejar los nulos explícitamente:

```dart
String? email;           // Puede ser null
String email = 'a@b.com'; // NUNCA puede ser null

// Operadores:
email ?? 'sin email'     // Si email es null, usa 'sin email'
email?.length            // Si email es null, devuelve null (no explota)
email!                   // Prometo que NO es null (peligroso, puede explotar)
```

### 4.3 Clases y constructores

```dart
class Exercise {
  final String id;          // Campo inmutable
  final String nombre;

  // Constructor con parámetros nombrados obligatorios
  Exercise({required this.id, required this.nombre});

  // Factory constructor: método estático que devuelve una instancia
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
    );
  }
}
```

- **`required`**: Obliga a pasar el parámetro. Sin él, es opcional.
- **`factory`**: Constructor especial que puede devolver instancias ya existentes o hacer lógica extra antes de crear el objeto. Es como un método estático de creación en Java/Kotlin.
- **`this.id`**: Atajo de Dart. En el constructor, `this.id` asigna directamente el parámetro al campo `id`.

### 4.4 `async` / `await` (programación asíncrona)

```dart
Future<void> main() async {      // async = esta función tiene operaciones asíncronas
  await Firebase.initializeApp(); // await = espera a que termine antes de continuar
}
```

- **`Future<T>`**: Promesa de que en el futuro habrá un valor de tipo T. Equivale a `Promise` en JavaScript o `Deferred` en Kotlin.
- **`async`**: Marca la función como asíncrona.
- **`await`**: Pausa la ejecución hasta que el Future se complete.

### 4.5 Colecciones y operaciones funcionales

```dart
final lista = [1, 2, 3, 4, 5];

lista.map((x) => x * 2)         // Transforma cada elemento: [2, 4, 6, 8, 10]
lista.where((x) => x > 3)       // Filtra: [4, 5]
lista.firstWhere((x) => x > 3)  // Primer elemento que cumple: 4
lista.take(3)                    // Primeros 3: [1, 2, 3]
lista.join(', ')                 // Une como String: "1, 2, 3, 4, 5"

// Map (diccionario):
Map<String, dynamic> json = {'nombre': 'FisioIA', 'edad': 25};
json['nombre']  // Accede al valor: 'FisioIA'
```

### 4.6 Cascadas (`..`)

```dart
_messages
  ..clear()                      // Primero limpia la lista
  ..add(initialMessage);         // Luego añade un elemento
// Equivale a:
// _messages.clear();
// _messages.add(initialMessage);
```

Las cascadas ejecutan varias operaciones sobre el mismo objeto sin repetirlo.

### 4.7 `String.fromEnvironment` (variables de compilación)

```dart
static const endpoint = String.fromEnvironment('AZURE_OPENAI_ENDPOINT');
```

Lee valores pasados con `--dart-define` al compilar:
```bash
flutter run --dart-define=AZURE_OPENAI_ENDPOINT=https://...
```
Son **constantes de compilación**: se incrustan en el binario. No se pueden cambiar en runtime.

---

## 5. Conceptos de Flutter que DEBES saber

### 5.1 Widget: la unidad básica

**TODO en Flutter es un widget**: textos, botones, layouts, pantallas enteras. Es como un componente de React.

Hay dos tipos fundamentales:

| Tipo | Cuándo usar | Estado | Ejemplo |
|---|---|---|---|
| **StatelessWidget** | No cambia después de crearse | Inmutable | `ZonesScreen`, `RoutineDetailScreen` |
| **StatefulWidget** | Cambia según interacciones | Tiene `State` mutable | `ChatScreen`, `LoginScreen` |

### 5.2 StatelessWidget

```dart
class ZonesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);  // Devuelve el árbol de widgets
  }
}
```

- Solo tiene `build()`. Flutter lo llama cuando necesita pintar.
- No puede guardar datos que cambien.

### 5.3 StatefulWidget

```dart
class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _sending = false;  // Estado mutable

  @override
  void initState() {
    super.initState();
    // Se ejecuta UNA VEZ al crear el widget (como onCreate en Android)
  }

  @override
  void dispose() {
    // Se ejecuta al destruir el widget (liberar recursos)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

**Ciclo de vida:**
1. `createState()` → Crea el objeto State
2. `initState()` → Se ejecuta una vez al inicio (cargar datos, configurar)
3. `build()` → Pinta la UI. Se llama CADA VEZ que cambia el estado
4. `setState(() { ... })` → Modifica el estado y dispara un nuevo `build()`
5. `dispose()` → Limpieza final (cerrar controladores, cancelar suscripciones)

### 5.4 `setState()` — Cómo se actualiza la UI

```dart
setState(() {
  _sending = true;  // Cambia el estado
});
// Flutter llama automáticamente a build() para redibujar la UI
```

**MUY IMPORTANTE**: Solo se puede llamar `setState()` si el widget sigue montado en el árbol. Por eso siempre se comprueba `if (mounted)` antes.

### 5.5 `BuildContext`

Es el "contexto" del widget en el árbol. Sirve para:
- Acceder al tema: `Theme.of(context)`
- Navegar: `Navigator.push(context, ...)`
- Mostrar SnackBars: `ScaffoldMessenger.of(context)`
- Acceder al tamaño de pantalla: `MediaQuery.of(context)`

### 5.6 Navegación

```dart
// Ir a otra pantalla (push = apilar encima)
Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));

// Ir a otra pantalla y eliminar todas las anteriores (no se puede volver atrás)
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => MainMenuScreen()),
  (route) => false,  // Elimina TODAS las rutas anteriores
);

// Volver atrás
Navigator.pop(context);

// Volver con un resultado
Navigator.pop(context, routine);  // Devuelve 'routine' a la pantalla anterior
```

### 5.7 Widgets de layout más usados en el proyecto

| Widget | Qué hace | Equivalente Android |
|---|---|---|
| `Scaffold` | Estructura de pantalla (appBar, body, bottomNav) | CoordinatorLayout |
| `Column` | Apila hijos verticalmente | LinearLayout vertical |
| `Row` | Apila hijos horizontalmente | LinearLayout horizontal |
| `ListView` | Lista con scroll | RecyclerView |
| `Container` | Caja con padding, color, bordes | FrameLayout con decoración |
| `Padding` | Añade espacio interior | padding en XML |
| `SizedBox` | Espacio fijo | Space o View con tamaño |
| `Expanded` | Ocupa todo el espacio disponible | layout_weight=1 |
| `Card` | Tarjeta con sombra | CardView |
| `SafeArea` | Evita el notch y la barra del sistema | fitsSystemWindows |

### 5.8 `FutureBuilder` — Mostrar datos asíncronos

```dart
FutureBuilder<UserProfile>(
  future: _load(),                    // El Future que esperamos
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator(); // Cargando...
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    final profile = snapshot.data!;
    return Text(profile.nombre ?? 'Sin nombre');
  },
)
```

`FutureBuilder` construye la UI según el estado del Future:
- **waiting**: Aún cargando → muestra spinner
- **done con error**: Falló → muestra error
- **done con datos**: Listo → muestra datos

### 5.9 `MaterialApp` y `ThemeData`

```dart
MaterialApp(
  title: 'FisioIA',
  theme: _buildTheme(),      // Tema global (colores, fuentes, formas)
  home: const HomeScreen(),   // Pantalla inicial
)
```

`ThemeData` centraliza TODOS los estilos. Cualquier widget puede acceder con:
```dart
Theme.of(context).colorScheme.primary  // Color primario
Theme.of(context).textTheme.titleMedium // Estilo de texto
```

---

## 6. Análisis archivo por archivo

### 6.1 `main.dart` — Punto de entrada

**¿Qué hace?** Arranca la app, inicializa Firebase y define el tema visual.

**Líneas clave:**
- `WidgetsFlutterBinding.ensureInitialized()` → **OBLIGATORIO** antes de cualquier `await` en `main()`. Inicializa el motor de Flutter.
- `await FirebaseBootstrap.tryInit()` → Intenta conectar con Firebase. Si falla, la app sigue en modo demo.
- `runApp(const MyApp())` → Lanza el widget raíz de la app.
- `_buildTheme()` → Crea la paleta de colores usando Material Design 3. `ColorScheme.fromSeed()` genera una paleta completa a partir de un color semilla.

**Si te preguntan:**
> "¿Por qué defines los colores como constantes globales?"
> Porque son `const` (constantes de compilación). El compilador las genera una sola vez, sin coste en runtime. Es más eficiente que crearlas cada vez que se pinta la UI.

---

### 6.2 MODELOS (`models/`)

#### `exercise.dart` — Modelo de ejercicio

```dart
class Exercise {
  final String id;           // ID único del ejercicio
  final String zonaId;       // A qué zona pertenece (FK lógica)
  final String nombre;       // Nombre del ejercicio
  final String descripcion;  // Descripción detallada
  final int series;          // Número de series
  final int repeticiones;    // Número de repeticiones por serie
  final String? imagen;      // Ruta a la imagen (puede ser null)
  final List<String> tags;   // Etiquetas clínicas (ej: "tendinitis", "agudo")
}
```

- `fromJson()` convierte un Map JSON en un objeto Exercise.
- `(json['series'] as num).toInt()` → Cast seguro: el JSON puede tener `int` o `double`, `num` cubre ambos.
- `tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const []` → Si no hay tags, usa lista vacía inmutable.

#### `routine.dart` — Modelo de rutina

Este es el modelo más completo. Tiene:

- **Constructor normal** (`Routine({...})`): Para crear instancias con todos los campos explícitos.
- **Factory `Routine.create()`**: Genera automáticamente el ID y valida el nombre.
  - ID = microsegundos desde epoch → prácticamente imposible que colisionen.
  - Si el nombre está vacío, usa `'Rutina sin nombre'` como fallback.
  - `List.unmodifiable()` → Crea una lista de solo lectura para evitar modificaciones accidentales.
- **`copyWith()`**: Patrón estándar para "modificar" objetos inmutables. Crea un nuevo objeto con los campos que quieras cambiar, sin tocar el original.
- **`toJson()` / `fromJson()`**: Serialización/deserialización para guardar en Firestore o SharedPreferences.

**Si te preguntan:**
> "¿Por qué los campos son `final`?"
> Porque el modelo es inmutable. Esto evita bugs por modificaciones accidentales y hace el código más predecible. Para "modificar" un campo, usamos `copyWith()` que crea un nuevo objeto.

#### `user_profile.dart` — Perfil del usuario

Campos opcionales (`String?`, `int?`) porque el usuario puede no haber rellenado su perfil aún. `UserProfile.empty()` crea un perfil vacío con todos los campos a null.

#### `zone.dart` — Zona corporal

El modelo más simple: solo `id` y `nombre`. Cada zona agrupa un conjunto de ejercicios.

---

### 6.3 SERVICIOS (`services/`)

#### `firebase_bootstrap.dart` — Inicialización segura de Firebase

**Patrón clave: degradación elegante (graceful degradation).**

```dart
static bool _attempted = false;  // ¿Ya se intentó inicializar?
static bool _ready = false;      // ¿Se inicializó correctamente?

static Future<bool> tryInit() async {
  if (_attempted) return _ready;  // No intentar dos veces
  _attempted = true;
  try {
    await Firebase.initializeApp();
    _ready = true;
  } catch (_) {
    _ready = false;  // Falla silenciosamente → modo demo
  }
  return _ready;
}
```

**¿Por qué?** Si el desarrollador no tiene `google-services.json` configurado (o no hay internet), la app no se rompe. Simplemente funciona sin las features de Firebase.

Toda la app consulta `FirebaseBootstrap.isReady` antes de usar Auth o Firestore.

#### `auth_service.dart` — Autenticación

Encapsula **todas** las operaciones de autenticación. La app nunca toca `FirebaseAuth` directamente.

- **`AppUser`**: Clase wrapper que expone solo `uid` y `email`. Evita exponer el objeto `User` de Firebase (encapsulamiento).
- **`_ensureUserDoc()`**: Crea o actualiza el documento del usuario en Firestore al loguearse. Usa `FieldValue.serverTimestamp()` (reloj del servidor, no del móvil).
- **`authStateChanges()`**: Stream que emite eventos cuando el usuario inicia/cierra sesión. Si Firebase no está listo, devuelve `Stream.empty()`.
- **`signIn()`**: Login con email/password vía `FirebaseAuth`.
- **`register()`**: Registro con email/password.
- **`signInWithGoogle()`**: OAuth 2.0 con Google. Pide solo el scope `email`.
- **`sendEmailVerification()`**: Envía email de verificación.
- **`isCurrentUserEmailVerified()`**: Comprueba si el email está verificado. Usa `user.reload()` para forzar la recarga desde Firebase (sin esto, el estado puede estar cacheado).
- **`signOut()`**: Cierra sesión tanto de Google como de Firebase.

**Si te preguntan:**
> "¿Por qué llamas a `_ensureUserDoc` en cada login?"
> Para mantener actualizado el campo `lastLoginAt` y asegurar que el documento existe en Firestore. Es "best-effort": si falla, no bloquea el login.

#### `catalog_service.dart` — Carga del catálogo

```dart
Future<CatalogData> load() async {
  final raw = await rootBundle.loadString('assets/exercises.json');
  final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
  // ... parsea zonas y ejercicios
}
```

- **`rootBundle.loadString()`**: Lee un archivo empaquetado en los assets de la app. Es como `context.assets.open()` en Android.
- `CatalogData` agrupa zonas + ejercicios en un solo objeto para pasarlo fácilmente entre pantallas.

#### `azure_openai_service.dart` — Integración con IA

**Configuración** (variables de compilación):
```dart
static const endpoint = String.fromEnvironment('AZURE_OPENAI_ENDPOINT');
static const apiKey = String.fromEnvironment('AZURE_OPENAI_API_KEY');
```
Se pasan al compilar con `--dart-define`. Si no se pasan, la app funciona en modo demo.

**Método `reply()`:**
1. Construye la URL del endpoint de Azure OpenAI.
2. Genera el **system prompt**: un mensaje largo que define la personalidad del asistente (empático, cercano, en español) y le da el catálogo completo de ejercicios como contexto.
3. Envía el historial de mensajes + mensaje actual como POST HTTP.
4. Parsea la respuesta JSON y devuelve el texto.

**System prompt**: Instruye a la IA para que:
- Sea empática y motivadora
- Responda en 3 partes: empatía + justificación + pregunta
- NUNCA liste ejercicios en texto (la app lo hace con tarjetas)
- Detecte condiciones clínicas (tendinitis, hernia, etc.) y use las etiquetas del catálogo
- Advierta sobre señales de alarma SOLO una vez

#### `chat_usage_limiter.dart` — Rate limiting

Limita las consultas diarias a la IA (por defecto 10/día):

```dart
static const int defaultDailyLimit =
    int.fromEnvironment('CHAT_DAILY_LIMIT', defaultValue: 10);
```

- La clave de SharedPreferences incluye la fecha: `chat_usage_2025-06-11_<uid>`.
- Se reinicia automáticamente al día siguiente (no necesita cron ni cleanup).
- `tryConsume()` devuelve `true` si hay cupo y lo incrementa; `false` si se agotó.

**Si te preguntan:**
> "¿Por qué limitar las consultas?"
> Para evitar facturas sorpresa de Azure OpenAI. Cada petición tiene un coste por tokens. El límite protege el presupuesto.

#### `email_validator.dart` — Validación de email

- Valida formato con RegExp.
- **Detecta errores de dominio comunes**: `gmial.com` → "¿Querías decir gmail.com?".
- Comprueba que hay exactamente un `@` y que las partes no están vacías.

#### `routine_repository.dart` — Repositorio de rutinas (patrón Repository)

**Patrón dual-path:**
```
¿Hay sesión activa Y Firebase está listo?
   SÍ → Firestore (nube)
   NO → SharedPreferences (local)
```

La app NUNCA sabe dónde se guardan los datos. Solo llama a `repository.list()`, `repository.upsert()`, `repository.deleteById()`.

- **Firestore**: Colección anidada `users/{uid}/routines/{routineId}`, ordenada por `createdAt` descendente.
- **Local**: `RoutineStorage` con SharedPreferences.

#### `routine_storage.dart` — Almacenamiento local

Guarda TODAS las rutinas como un JSON string bajo la clave `routines_v1`:
- `list()`: Lee, parsea, ordena por fecha.
- `upsert()`: Si el ID ya existe, reemplaza; si no, añade.
- `deleteById()`: Filtra y reescribe sin la rutina eliminada.

Protecciones ante datos corruptos: `whereType<Map>()` filtra entradas que no sean Map.

#### `user_profile_repository.dart` — Repositorio del perfil

- `getByUid()`: Lee el documento del usuario de Firestore. Si no existe, devuelve `UserProfile.empty()`.
- `upsert()`: Guarda el perfil con `SetOptions(merge: true)` → solo actualiza los campos indicados sin borrar el resto.

---

### 6.4 PANTALLAS (`screens/`)

#### `home_screen.dart` — Pantalla de bienvenida

- **StatefulWidget** porque comprueba sesión activa en `initState()`.
- Si ya hay sesión, salta directamente a `MainMenuScreen` con `pushAndRemoveUntil`.
- Dos botones: "Entrar como invitado" y "Iniciar sesión".
- Muestra logo, nombre de la app y descripción.

#### `login_screen.dart` — Login

- Formulario con `Form` + `GlobalKey<FormState>` para validación.
- `TextEditingController` para leer los campos (email y contraseña).
- Tres opciones: login email/password, Google, o invitado.
- **Flujo de login**:
  1. Valida el formulario (`_formKey.currentState!.validate()`)
  2. Intenta inicializar Firebase
  3. Llama a `AuthService().signIn()`
  4. Comprueba email verificado → si no está verificado, reenvía el email y cierra sesión
  5. Navega a `MainMenuScreen`
- `_loading` bloquea los botones mientras espera (UX: evita doble clic).

#### `register_screen.dart` — Registro

Similar a LoginScreen pero con campo de confirmación de contraseña.
- Tras registro exitoso: envía email de verificación, cierra sesión, y muestra diálogo pidiendo que verifique antes de iniciar sesión.

#### `main_menu_screen.dart` — Menú principal (NavigationBar)

**Patrón**: `NavigationBar` + `PageView` → navegación entre pestañas con animación.

- **Modo usuario autenticado**: 5 pestañas → Explorar, Rutinas, IA, Perfil, Salir
- **Modo invitado**: 3 pestañas → Explorar, Rutinas, Salir (sin IA ni perfil)
- `PageController` controla la animación entre páginas.
- `NeverScrollableScrollPhysics()` desactiva el swipe entre páginas (solo se cambia con la navbar).
- `_confirmLogout()` muestra diálogo de confirmación antes de cerrar sesión.

#### `zones_screen.dart` — Explorar zonas

- **StatelessWidget** (no tiene estado que cambie).
- Muestra una lista de zonas con iconos personalizados.
- `_zoneIcon` mapea el ID de la zona a su icono correspondiente.
- `TweenAnimationBuilder` añade una animación de entrada escalonada (fade + slide up).
- Al pulsar una zona, navega a `ZoneExercisesScreen`.

#### `zone_exercises_screen.dart` — Ejercicios por zona

- Filtra ejercicios: `data.exercises.where((e) => e.zonaId == zoneId)`.
- Al pulsar un ejercicio, abre un `BottomSheet` con imagen, descripción, series/reps.
- Botón "Crear rutina con este ejercicio" → abre `RoutineEditorScreen` con ese ejercicio preseleccionado.

#### `routines_screen.dart` — Mis rutinas

La pantalla más compleja después del chat. Tiene:

- **TabBar** con 2 pestañas:
  1. "Mis rutinas" → Rutinas del usuario (guardadas en Firestore/local)
  2. "Predeterminadas" → Rutinas base generadas automáticamente por zona

- **Funcionalidades CRUD completas**:
  - Crear rutina manual (FAB)
  - Editar rutina existente
  - Duplicar rutina
  - Eliminar con confirmación

- **RefreshIndicator** → Pull-to-refresh en la lista de rutinas.
- **PopupMenuButton** → Menú contextual (editar/duplicar/eliminar) en cada tarjeta.
- **`_presetRoutineForZone()`**: Genera una rutina con los primeros 5 ejercicios de la zona.
- `TickerProviderStateMixin` es necesario para el `TabController` (proporciona el `vsync`).

#### `routine_detail_screen.dart` — Detalle de rutina

Muestra la rutina completa con:
- Nombre, descripción, número de ejercicios, etiqueta (IA/Manual/Predeterminada).
- Lista de ejercicios con miniatura, nombre y series×reps.
- Al pulsar un ejercicio, abre BottomSheet con detalle.

#### `routine_editor_screen.dart` — Editor de rutinas

Pantalla para crear o editar una rutina:
- Campos: nombre (obligatorio, ≥3 chars) y descripción (opcional).
- Dropdown para filtrar ejercicios por zona.
- Checkboxes para seleccionar ejercicios.
- Sección de reordenación (flechas arriba/abajo).
- Devuelve la rutina editada con `Navigator.pop(context, routine)`.

#### `chat_screen.dart` — Asistente de IA (~1060 líneas)

**El archivo más complejo del proyecto.** Gestiona:

1. **Historial de mensajes**: Se persisten en SharedPreferences (últimos 120 mensajes).
2. **Envío de mensajes**: Validación (no vacío, ≤500 chars), rate limiting, llamada a Azure OpenAI.
3. **Detección de zonas e intenciones**: Analiza el texto del usuario para detectar:
   - Zonas corporales (nombre directo o condición clínica → zona)
   - Intención de rutina (palabras clave: "rutina", "dolor", "lesion", etc.)
4. **Generación de rutinas**: Selecciona ejercicios aleatorios de las zonas detectadas.
5. **Tarjetas de rutina**: Muestra una tarjeta visual debajo del mensaje de la IA con botones "Guardar" y "Editar".
6. **Modo dual**: Si Azure OpenAI está configurado → llama a la IA. Si no → modo demo con respuestas locales predefinidas.
7. **Aviso de seguridad**: Se muestra una sola vez al abrir el chat por primera vez.

**Flujo de un mensaje:**
```
Usuario escribe → _send() → _respondAsync()
                                  ↓
                    ¿Azure configurado?
                    SÍ → rate limit OK? → llamar Azure OpenAI → respuesta IA
                    NO → _respondDemo() → respuesta local predefinida
                                  ↓
                    ¿Detecta zona + intención de rutina?
                    SÍ → _buildPendingRoutineForZones() → muestra tarjeta
                    NO → solo muestra texto
```

**Clases auxiliares:**
- `_ChatMessage`: Mensaje del chat con datos extra (zoneId, suggestedExerciseIds).
- `_PendingRoutine`: Rutina propuesta pero no guardada aún.

---

### 6.5 UTILIDADES (`utils/`)

#### `asset_helper.dart`

```dart
String assetKey(String path) {
  if (kIsWeb) {
    return path.replaceFirst(RegExp(r'^assets/'), '');
  }
  return path.startsWith('assets/') ? path : 'assets/$path';
}
```

Flutter Web necesita las rutas sin el prefijo `assets/`, pero mobile/desktop sí lo necesita. Esta función normaliza las rutas según la plataforma.

---

### 6.6 ARCHIVOS DE CONFIGURACIÓN

#### `pubspec.yaml` — Dependencias

| Dependencia | Versión | Para qué |
|---|---|---|
| `firebase_core` | ^3.6.0 | Inicialización de Firebase |
| `firebase_auth` | ^5.3.1 | Autenticación (email, Google) |
| `cloud_firestore` | ^5.5.0 | Base de datos en la nube |
| `google_sign_in` | ^6.2.1 | Login con Google |
| `shared_preferences` | ^2.3.2 | Almacenamiento local clave-valor |
| `http` | ^1.2.2 | Peticiones HTTP (para Azure OpenAI) |
| `cupertino_icons` | ^1.0.8 | Iconos estilo iOS |

El `^` antes de la versión significa "compatible con": acepta actualizaciones menores pero no mayores.

#### `firestore.rules` — Reglas de seguridad

```
function isOwner(userId) {
  return isSignedIn() && request.auth.uid == userId;
}

match /users/{userId} {
  allow create, read, update, delete: if isOwner(userId);
  match /routines/{routineId} {
    allow create, read, update, delete: if isOwner(userId);
  }
}
```

**Principio: cada usuario SOLO puede acceder a SUS propios datos.** Un usuario con uid "A" NO puede leer las rutinas del usuario "B".

#### `exercises.json` — Catálogo de ejercicios

JSON con 9 zonas y ~127 ejercicios. Cada ejercicio tiene:
- `id`, `zonaId`, `nombre`, `descripcion`, `series`, `repeticiones`, `imagen`, `tags`
- Los `tags` se usan para que la IA seleccione ejercicios según la condición (ej: `["tendinitis", "cronico"]`).

---

## 7. Flujo completo de la app

### 7.1 Arranque
```
main() → ensureInitialized() → FirebaseBootstrap.tryInit() → runApp(MyApp)
  → MyApp.build() → MaterialApp(home: HomeScreen)
    → HomeScreen._checkSession()
      → ¿Hay sesión activa?
         SÍ → Navegar a MainMenuScreen
         NO → Mostrar pantalla de bienvenida
```

### 7.2 Login con email
```
LoginScreen → Introduce email + contraseña → _login()
  → Valida formulario → Firebase Auth signIn
    → ¿Email verificado?
       SÍ → Navegar a MainMenuScreen
       NO → Reenviar email de verificación → Cerrar sesión → Mostrar aviso
```

### 7.3 Registro
```
RegisterScreen → Introduce email + contraseña + confirmación → _register()
  → Valida formulario → Firebase Auth createUserWithEmailAndPassword
    → Enviar email de verificación → Cerrar sesión
    → Mostrar diálogo "verifica tu correo"
    → Volver a LoginScreen
```

### 7.4 Explorar ejercicios
```
MainMenuScreen (pestaña Explorar)
  → ZonesScreen → Lista de zonas con iconos
    → Pulsar una zona → ZoneExercisesScreen → Lista de ejercicios
      → Pulsar un ejercicio → BottomSheet con detalle
        → Botón "Crear rutina" → RoutineEditorScreen
```

### 7.5 Chat con IA
```
MainMenuScreen (pestaña IA) → ChatScreen
  → Primer acceso: muestra aviso de seguridad
  → Escribe mensaje → _send()
    → Rate limit OK? → Llama a Azure OpenAI (o modo demo)
      → ¿Detecta zona + intención de rutina?
         SÍ → Muestra tarjeta con rutina sugerida
           → Botón "Guardar" → Guarda en Firestore/local
           → Botón "Editar" → RoutineEditorScreen → Guarda
         NO → Solo muestra texto de respuesta
```

### 7.6 Gestión de rutinas
```
MainMenuScreen (pestaña Rutinas) → RoutinesScreen
  → "Mis rutinas" (usuario autenticado):
    → Ver detalle → RoutineDetailScreen
    → Editar → RoutineEditorScreen
    → Duplicar → Crea copia con "(copia)"
    → Eliminar → Diálogo de confirmación
    → Crear nueva (FAB) → RoutineEditorScreen
  → "Predeterminadas" (base de la app):
    → Ver rutinas base por zona
```

---

## 8. Patrones de diseño usados

### 8.1 Repository Pattern

**`RoutineRepository`** y **`UserProfileRepository`** abstraen el acceso a datos.

```
Pantalla → Repository → ¿Firebase listo y sesión activa?
                            SÍ → Firestore (nube)
                            NO → SharedPreferences (local)
```

**Ventaja**: La pantalla no sabe ni le importa dónde están los datos. Si mañana cambias Firestore por otra BD, solo cambias el repositorio.

### 8.2 Dual-path (ruta dual)

La app funciona en **3 modos**:
1. **Autenticado + Firebase**: Todo en la nube.
2. **Invitado**: Almacenamiento local, sin IA, sin perfil.
3. **Sin Firebase**: Modo demo total.

### 8.3 Factory Pattern

Los `factory constructors` en los modelos (`Routine.create()`, `Exercise.fromJson()`) centralizan la creación de objetos con validación.

### 8.4 Graceful Degradation (degradación elegante)

Si un servicio falla (Firebase, Azure OpenAI), la app no se rompe:
- Sin Firebase → modo demo/local
- Sin Azure OpenAI → respuestas locales predefinidas
- Sin internet → SharedPreferences

### 8.5 Inmutabilidad

Todos los modelos usan `final` fields + `copyWith()`. Esto:
- Previene bugs por modificaciones accidentales
- Hace el código más predecible
- Facilita el testing

### 8.6 Encapsulamiento

- `AppUser` oculta el `User` de Firebase.
- `FirebaseBootstrap.isReady` es un getter público, pero `_ready` es privado.
- Los servicios exponen métodos simples, ocultando la complejidad interna.

---

## 9. Firebase: Auth + Firestore

### 9.1 Firebase Auth

**Métodos de autenticación implementados:**
1. **Email/Password**: Registro + verificación por correo + login
2. **Google Sign-In**: OAuth 2.0

**Flujo de verificación de email:**
```
Registro → Crear usuario → Enviar email verificación → Cerrar sesión
  → Usuario verifica desde su email
  → Login → ¿emailVerified? SÍ → acceso. NO → reenviar email.
```

### 9.2 Cloud Firestore (NoSQL)

**Estructura de datos:**
```
users (colección)
  └── {userId} (documento)
      ├── email: "user@email.com"
      ├── nombre: "Juan"
      ├── edad: 30
      ├── zonaPrincipalId: "hombro"
      ├── nivelExperiencia: "intermedio"
      ├── objetivos: "Recuperar movilidad"
      ├── createdAt: Timestamp
      ├── lastLoginAt: Timestamp
      ├── updatedAt: Timestamp
      └── routines (subcolección)
          └── {routineId} (documento)
              ├── id: "1718900000000000"
              ├── nombre: "Rutina de hombro"
              ├── descripcion: "..."
              ├── creadaPorIA: true
              ├── createdAt: "2025-06-11T..."
              └── exerciseIds: ["ex1", "ex2", "ex3"]
```

**¿Por qué NoSQL y no SQL?**
- No hay relaciones complejas entre tablas
- Las rutinas son subcolecciones del usuario (acceso directo sin JOINs)
- Escalable y serverless (no necesitamos gestionar un servidor)
- Tiempo real y offline integrado

### 9.3 Reglas de seguridad

```javascript
function isOwner(userId) {
  return isSignedIn() && request.auth.uid == userId;
}
```

**Solo el propietario** puede leer/escribir sus datos. Esto se aplica tanto al documento del usuario como a sus rutinas.

---

## 10. Integración con Azure OpenAI

### ¿Cómo funciona?

1. La app envía un **POST HTTP** al endpoint de Azure OpenAI.
2. El cuerpo incluye:
   - **System prompt**: Define la personalidad del asistente + catálogo completo de ejercicios
   - **Historial**: Últimos ~10 mensajes de la conversación
   - **Mensaje del usuario**: Lo que acaba de escribir
3. Azure OpenAI devuelve una respuesta JSON con el texto generado.
4. La app analiza la respuesta para detectar zonas mencionadas y construir la tarjeta de rutina.

### Seguridad

- Las credenciales (endpoint, API key, deployment) se inyectan en **compilación** con `--dart-define`. NO están en el código fuente.
- Si no se proporcionan, `AzureOpenAIConfig.isConfigured` es `false` y la app funciona en modo demo.
- Límite diario de 10 consultas para controlar costes.

---

## 11. Seguridad

### 11.1 Autenticación
- Email verificado obligatorio antes de acceder
- Google OAuth 2.0 con scope mínimo (solo email)
- Tokens gestionados por Firebase SDK (no manejamos tokens manualmente)

### 11.2 Autorización (Firestore Rules)
- Cada usuario solo accede a sus propios datos
- No hay endpoints públicos de lectura

### 11.3 Validación de datos
- Email validado con RegExp + detección de typos de dominio
- Contraseña mínimo 6 caracteres
- Nombre de rutina mínimo 3 caracteres
- Mensajes de chat máximo 500 caracteres

### 11.4 API keys
- Credenciales de Azure OpenAI inyectadas en compilación (no hardcodeadas)
- Rate limiting para evitar abuso

### 11.5 Aviso médico
- Disclaimer obligatorio la primera vez que se abre el chat
- La IA nunca da diagnósticos, solo sugerencias educativas

---

## 12. Preguntas frecuentes del tribunal

### Sobre Flutter/Dart

**P: ¿Qué diferencia hay entre StatelessWidget y StatefulWidget?**
> StatelessWidget es inmutable: se construye una vez y no cambia. StatefulWidget tiene un objeto State con datos mutables; cuando llamas a `setState()`, Flutter reconstruye la UI automáticamente.

**P: ¿Qué es el BuildContext?**
> Es la referencia del widget dentro del árbol de widgets de Flutter. Sirve para acceder al tema (`Theme.of(context)`), navegar entre pantallas (`Navigator.push(context, ...)`), y obtener información del entorno.

**P: ¿Qué es el widget `Scaffold`?**
> Es el esqueleto de una pantalla Material Design. Proporciona estructura para `appBar` (barra superior), `body` (contenido), `bottomNavigationBar`, `floatingActionButton`, etc.

**P: ¿Cómo manejas la navegación entre pantallas?**
> Con `Navigator.push()` para ir a una pantalla y `Navigator.pop()` para volver. Uso `pushAndRemoveUntil()` cuando quiero limpiar toda la pila (por ejemplo, después del login, para que no se pueda volver atrás).

**P: ¿Qué es un FutureBuilder?**
> Un widget que construye la UI según el estado de un Future (operación asíncrona). Mientras espera muestra un spinner; cuando termina muestra los datos o un error.

**P: ¿Qué es `mounted` y por qué lo compruebas?**
> `mounted` indica si el widget sigue en el árbol de Flutter. Si el usuario navega fuera mientras hay una operación asíncrona en curso, el widget se desmonta. Llamar a `setState()` en un widget desmontado lanza una excepción. Por eso siempre compruebo `if (mounted)` antes.

**P: ¿Por qué usas `dispose()`?**
> Para liberar recursos cuando el widget se destruye. Los `TextEditingController`, `ScrollController`, `TabController`, etc. reservan memoria que hay que liberar explícitamente para evitar fugas de memoria (memory leaks).

**P: ¿Qué es un `const` constructor?**
> Un constructor que garantiza que el widget es una constante de compilación. Flutter puede reutilizar la misma instancia sin reconstruirla, mejorando el rendimiento.

---

### Sobre la arquitectura

**P: ¿Qué patrón de arquitectura sigues?**
> Uso una arquitectura por capas: Pantallas (UI) → Servicios (lógica de negocio) → Modelos (datos). Los repositorios implementan el patrón Repository para abstraer el acceso a datos. La app no depende directamente de Firestore ni SharedPreferences.

**P: ¿Por qué separas modelos, servicios y pantallas?**
> Separación de responsabilidades. Los modelos definen la estructura de datos. Los servicios contienen la lógica de negocio y acceso a datos. Las pantallas solo se encargan de la UI. Esto facilita el mantenimiento, testing y reutilización.

**P: ¿Qué es el patrón Repository?**
> Es un patrón que abstrae el origen de los datos. `RoutineRepository` decide si usar Firestore o SharedPreferences según haya sesión activa. Las pantallas no saben ni les importa de dónde vienen los datos.

**P: ¿Cómo funciona el modo invitado?**
> El usuario puede usar la app sin cuenta. En modo invitado: ve el catálogo de ejercicios y las rutinas predeterminadas. No puede usar la IA, guardar rutinas en la nube ni tener perfil. Los datos se guardan localmente en SharedPreferences.

**P: ¿Qué pasa si no hay internet?**
> La app funciona en modo degradado. Firebase Bootstrap detecta que no puede conectar y activa el modo demo. Las rutinas se guardan localmente. El chat funciona con respuestas predefinidas (sin IA).

---

### Sobre Firebase

**P: ¿Por qué elegiste Firestore y no una base de datos SQL?**
> Porque los datos del proyecto no tienen relaciones complejas. Cada usuario tiene sus rutinas como subcolección. Firestore es NoSQL, serverless (no necesito gestionar servidores), escala automáticamente y tiene soporte offline nativo.

**P: ¿Cómo proteges los datos en Firestore?**
> Con Security Rules. La regla `isOwner(userId)` asegura que solo el usuario autenticado puede leer y escribir sus propios datos. Nadie más puede acceder a las rutinas de otro usuario.

**P: ¿Qué es `FieldValue.serverTimestamp()`?**
> Es una marca de tiempo generada por el servidor de Firebase, no por el dispositivo del usuario. Es más fiable porque el usuario podría tener el reloj mal configurado.

**P: ¿Qué es `SetOptions(merge: true)`?**
> Le dice a Firestore que haga un merge parcial: actualiza solo los campos que le pasas sin borrar los demás. Sin `merge: true`, un `set()` reemplazaría todo el documento.

**P: ¿Por qué verificas el email?**
> Para asegurar que el usuario tiene acceso real al email que usó para registrarse. Evita registros con emails falsos o de terceros. Es una buena práctica de seguridad.

---

### Sobre la IA

**P: ¿Cómo funciona el asistente de IA?**
> Usamos Azure OpenAI (modelo GPT). La app envía el mensaje del usuario junto con un system prompt que define la personalidad del asistente y le proporciona todo el catálogo de ejercicios. La IA genera una respuesta personalizada y la app detecta las zonas mencionadas para construir una tarjeta con la rutina sugerida.

**P: ¿Qué es el system prompt?**
> Es un mensaje especial que define cómo debe comportarse la IA. Le damos instrucciones sobre su tono (empático, en español), estructura de respuesta (empatía + justificación + pregunta), y le pasamos el catálogo completo de ejercicios como contexto para que pueda hacer recomendaciones informadas.

**P: ¿Qué pasa si Azure OpenAI no está disponible?**
> La app cambia automáticamente a modo demo. Analiza el texto del usuario localmente para detectar zonas y ejercicios del catálogo, y devuelve respuestas predefinidas. No es tan inteligente como la IA, pero la app no se rompe.

**P: ¿Cómo evitas que la IA dé diagnósticos médicos?**
> En el system prompt instruimos explícitamente a la IA para que dé solo información educativa general, nunca diagnósticos concretos. Además, ante señales de alarma (dolor intenso, hormigueo, pérdida de fuerza), recomienda acudir al médico. La app también muestra un disclaimer de seguridad la primera vez.

**P: ¿Cómo controlas los costes de la IA?**
> Con un rate limiter (`ChatUsageLimiter`) que permite máximo 10 consultas por usuario por día. El contador se guarda en SharedPreferences con una clave que incluye la fecha, así se reinicia solo al día siguiente.

**P: ¿Dónde están las credenciales de Azure OpenAI?**
> Se inyectan en tiempo de compilación con `--dart-define`. No están hardcodeadas en el código. Si no se proporcionan, la app funciona en modo demo.

---

### Sobre el código

**P: ¿Por qué usas `final` en todos los campos de los modelos?**
> Para hacerlos inmutables. Un objeto inmutable no puede ser modificado después de crearse, lo que previene bugs por cambios accidentales. Para "modificar" algo, uso `copyWith()` que crea un nuevo objeto.

**P: ¿Qué es un `factory constructor`?**
> Es un constructor especial en Dart que puede ejecutar lógica antes de devolver una instancia. A diferencia de un constructor normal, un factory puede devolver instancias ya existentes, hacer validaciones, o elegir qué subclase instanciar. En el proyecto, `Routine.create()` genera el ID automáticamente y valida el nombre.

**P: ¿Qué es `List.unmodifiable()`?**
> Crea una lista de solo lectura. Si alguien intenta hacer `.add()`, `.remove()`, etc., lanza una excepción. Se usa en `Routine` para proteger `exerciseIds` de modificaciones externas.

**P: ¿Para qué sirve `_normalize()`?**
> Convierte texto a minúsculas y elimina tildes para hacer comparaciones insensibles a mayúsculas y acentos. Así "Hombro", "hombro" y "hómbro" se tratan igual.

**P: ¿Qué es `WidgetsBinding.instance.addPostFrameCallback()`?**
> Registra un callback que se ejecuta DESPUÉS de que Flutter haya pintado el frame actual. Se usa para acciones que necesitan que la UI esté completamente construida, como mostrar un diálogo o hacer scroll al final de una lista.

**P: ¿Por qué usas SharedPreferences para el historial del chat y no Firestore?**
> Porque el historial del chat es local al dispositivo. No tiene sentido sincronizarlo en la nube (es más privado y ahorra lecturas de Firestore). Además, persiste rápido sin necesitar conexión a internet.

---

### Preguntas de diseño/UX

**P: ¿Por qué usas Material Design 3?**
> Es el sistema de diseño más actual de Google. Ofrece componentes modernos, tokens de diseño consistentes, y soporte nativo en Flutter con `useMaterial3: true`. Garantiza una interfaz coherente y accesible.

**P: ¿Por qué las animaciones de entrada escalonadas?**
> Uso `TweenAnimationBuilder` con delays incrementales (`index * 40ms`) para que los elementos de la lista aparezcan uno tras otro. Es un patrón UX llamado "staggered animation" que guía la atención del usuario y da sensación de fluidez.

**P: ¿Por qué el aviso de seguridad se muestra solo una vez?**
> Para no molestar al usuario recurrente. Se guarda en SharedPreferences (`chat_safety_warning_v1`) que ya se mostró. Es un requisito legal/ético: informar de que la IA no sustituye a un profesional médico.

---

## 13. Glosario rápido

| Término | Significado |
|---|---|
| **Widget** | Unidad básica de UI en Flutter. Todo es un widget. |
| **State** | Objeto que guarda datos mutables de un StatefulWidget |
| **setState()** | Notifica a Flutter que el estado cambió y debe redibujar la UI |
| **BuildContext** | Referencia del widget en el árbol. Para acceder al tema, navegar, etc. |
| **Scaffold** | Estructura base de una pantalla (appBar + body + bottomNav) |
| **Navigator** | Gestiona la pila de pantallas (push/pop) |
| **Future** | Valor que estará disponible en el futuro (operación asíncrona) |
| **async/await** | Sintaxis para esperar operaciones asíncronas |
| **Stream** | Secuencia de eventos asíncronos (como un río de datos) |
| **final** | Variable que se asigna una vez y no cambia |
| **const** | Constante conocida en compilación (más eficiente que final) |
| **required** | Parámetro obligatorio en un constructor |
| **factory** | Constructor especial que puede hacer lógica antes de devolver instancia |
| **copyWith** | Método para crear una copia modificada de un objeto inmutable |
| **null-safety** | Sistema de tipos que distingue valores nullables (?) de no-nullables |
| **mounted** | Indica si el widget sigue en el árbol de Flutter |
| **dispose()** | Método para liberar recursos cuando el widget se destruye |
| **rootBundle** | Acceso a archivos empaquetados en la app (assets) |
| **SharedPreferences** | Almacenamiento local clave-valor (persiste al cerrar la app) |
| **Firestore** | Base de datos NoSQL en la nube de Google Firebase |
| **UID** | User ID único generado por Firebase Auth |
| **OAuth 2.0** | Protocolo estándar de autorización (usado por Google Sign-In) |
| **System prompt** | Instrucciones iniciales que definen el comportamiento de la IA |
| **Rate limiting** | Control de frecuencia de uso (máx. N peticiones/período) |
| **Serialización** | Convertir un objeto a formato transportable (JSON) |
| **Deserialización** | Convertir JSON de vuelta a un objeto Dart |

---

## 14. Chuleta de última hora

### Los 10 puntos clave que debes saber decir

1. **"FisioIA es una app de fisioterapia con IA"**: Catálogo de ejercicios por zona + rutinas personalizadas + asistente inteligente.

2. **"Uso Flutter porque es multiplataforma"**: Un solo código para Android, iOS y Web.

3. **"La arquitectura es por capas"**: Modelos → Servicios/Repositorios → Pantallas. Separación de responsabilidades.

4. **"Los datos se guardan en Firestore o en local"**: Patrón Repository con ruta dual. Si hay sesión, nube. Si no, SharedPreferences.

5. **"La seguridad es por usuario"**: Firestore Rules + email verificado + credenciales en compilación.

6. **"El asistente usa Azure OpenAI"**: System prompt con el catálogo completo + historial de mensajes + rate limiting.

7. **"Si algo falla, la app no se rompe"**: Degradación elegante. Sin Firebase → modo demo. Sin Azure → respuestas locales.

8. **"StatelessWidget vs StatefulWidget"**: Inmutable vs mutable. `setState()` redibuja la UI.

9. **"Los modelos son inmutables"**: Campos `final` + `copyWith()` + `List.unmodifiable()`.

10. **"El chat persiste en SharedPreferences"**: Historial local, limitado a 120 mensajes, separado por usuario.

### Errores comunes que evitar en la presentación

- ❌ No digas "no sé" si te preguntan algo de este documento. Repasa los conceptos clave.
- ❌ No confundas `final` con `const` (final es runtime, const es compilación).
- ❌ No digas que Flutter usa "HTML" o "WebView". Se compila a código nativo.
- ❌ No digas que Firestore es SQL. Es NoSQL documental.
- ❌ No digas que las credenciales de Azure están en el código. Se inyectan en compilación.

### Frase para empezar la presentación

> "FisioIA es una aplicación móvil multiplataforma desarrollada con Flutter que ayuda a personas con molestias musculoesqueléticas. Combina un catálogo de más de 120 ejercicios de fisioterapia organizados por zona corporal, un sistema de rutinas personalizadas, y un asistente de inteligencia artificial basado en Azure OpenAI que recomienda ejercicios adaptados a cada condición del usuario."

---

> 💡 **Consejo final**: Lee este documento al menos 2 veces antes de la presentación. La primera para entender, la segunda para memorizar las palabras clave. Si te hacen una pregunta que no está aquí, respira y explica lo que sí sabes. Es mejor dar una respuesta parcial que quedarse en blanco.
