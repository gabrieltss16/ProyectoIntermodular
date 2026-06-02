import 'package:firebase_core/firebase_core.dart';

// FirebaseBootstrap gestiona la inicialización de Firebase de forma segura.
// Patrón: si Firebase no está configurado (sin google-services.json),
// la app sigue funcionando en modo demo en lugar de romperse.
// Esto permite desarrollar y probar sin credenciales reales.
class FirebaseBootstrap {
  // Campos estáticos: pertenecen a la clase, no a una instancia.
  // _attempted evita llamar a Firebase.initializeApp() más de una vez.
  static bool _attempted = false;
  // _ready indica si Firebase se inicializó correctamente.
  static bool _ready = false;

  // Getter público de solo lectura. El resto de la app consulta esto
  // antes de usar Firestore o Auth para saber si están disponibles.
  static bool get isReady => _ready;

  /// Intenta inicializar Firebase si la configuración nativa existe.
  /// Devuelve true si Firebase está listo; false si no (sin romper la app).
  static Future<bool> tryInit() async {
    // Protección: si ya se intentó, devuelve el resultado anterior.
    if (_attempted) return _ready;
    _attempted = true;

    try {
      // Firebase.initializeApp() lee google-services.json (Android) o
      // GoogleService-Info.plist (iOS) y conecta con los servicios de Firebase.
      await Firebase.initializeApp();
      _ready = true;
    } catch (_) {
      // Si el archivo de configuración no existe o está mal formado,
      // capturamos la excepción silenciosamente → la app corre en modo demo.
      _ready = false;
    }

    return _ready;
  }
}
