import 'package:flutter/foundation.dart';

String assetKey(String path) {
  // For web, Flutter serves assets under `assets/` already in the built tree,
  // but the runtime expects the key without a leading `assets/` prefix.
  if (kIsWeb) {
    return path.replaceFirst(RegExp(r'^assets/'), '');
  }

  // For mobile/desktop, use the full 'assets/...' path.
  return path.startsWith('assets/') ? path : 'assets/$path';
}
