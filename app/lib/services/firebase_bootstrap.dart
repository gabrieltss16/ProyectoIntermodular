import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  static bool _attempted = false;
  static bool _ready = false;

  static bool get isReady => _ready;

  /// Tries to initialize Firebase if the native config exists.
  ///
  /// This will return false (without crashing) when Firebase is not configured yet.
  static Future<bool> tryInit() async {
    if (_attempted) return _ready;
    _attempted = true;

    try {
      await Firebase.initializeApp();
      _ready = true;
    } catch (_) {
      _ready = false;
    }

    return _ready;
  }
}
