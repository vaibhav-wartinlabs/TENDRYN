import 'package:flutter/foundation.dart';

/// Single hook for diagnostics. Swap the body for Sentry/Crashlytics later.
abstract class AppLogger {
  static void error(Object error, [StackTrace? stack]) {
    if (kDebugMode) debugPrint('ERROR: $error\n${stack ?? ''}');
  }
}
