import 'package:shared_preferences/shared_preferences.dart';

class ChatUsageLimiter {
  static const int defaultDailyLimit =
      int.fromEnvironment('CHAT_DAILY_LIMIT', defaultValue: 10);

  String _dayKey(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _key({required String userKey, required DateTime now}) {
    return 'chat_usage_${_dayKey(now)}_$userKey';
  }

  Future<int> getCount({required String userKey, DateTime? now}) async {
    final n = now ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(userKey: userKey, now: n)) ?? 0;
  }

  Future<bool> tryConsume({
    required String userKey,
    int dailyLimit = defaultDailyLimit,
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final k = _key(userKey: userKey, now: n);
    final current = prefs.getInt(k) ?? 0;
    if (current >= dailyLimit) return false;

    await prefs.setInt(k, current + 1);
    return true;
  }
}
