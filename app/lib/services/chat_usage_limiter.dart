import 'package:shared_preferences/shared_preferences.dart';

// ChatUsageLimiter implementa el rate limiting de las consultas al chat IA.
// Objetivo: evitar facturas sorpresa de Azure OpenAI limitando a N peticiones/día.
// El contador se guarda en SharedPreferences con una clave que incluye la fecha,
// por lo que se reinicia automáticamente al día siguiente sin lógica adicional.
class ChatUsageLimiter {
  // int.fromEnvironment lee el valor pasado en --dart-define al compilar.
  // Si no se pasa CHAT_DAILY_LIMIT en el build, usa 10 como valor por defecto.
  // Esto es una constante de compilación (compile-time constant), NO de runtime.
  static const int defaultDailyLimit =
      int.fromEnvironment('CHAT_DAILY_LIMIT', defaultValue: 10);

  // Construye la parte de la clave que corresponde al día actual: YYYY-MM-DD
  String _dayKey(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // Construye la clave completa: chat_usage_YYYY-MM-DD_<uid|guest>
  // Incluir el uid permite tener contadores separados por usuario en el mismo dispositivo.
  String _key({required String userKey, required DateTime now}) {
    return 'chat_usage_${_dayKey(now)}_$userKey';
  }

  // Devuelve el número de consultas realizadas hoy por el usuario.
  Future<int> getCount({required String userKey, DateTime? now}) async {
    final n = now ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(userKey: userKey, now: n)) ?? 0;
  }

  // Intenta "consumir" una consulta del cupo diario.
  // Devuelve true si hay cupo y lo incrementa; false si ya se agotó el límite.
  // Es atómico en cuanto a SharedPreferences (no hay condiciones de carrera en mobile).
  Future<bool> tryConsume({
    required String userKey,
    int dailyLimit = defaultDailyLimit,
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final k = _key(userKey: userKey, now: n);
    final current = prefs.getInt(k) ?? 0;
    if (current >= dailyLimit) return false; // Límite alcanzado

    await prefs.setInt(k, current + 1); // Incrementa el contador
    return true;
  }
}
