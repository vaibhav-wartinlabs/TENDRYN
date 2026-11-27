import 'package:flutter/foundation.dart';

/// Build-time configuration from `--dart-define`; nothing environment-specific lives in source.
///
///   flutter run -d windows --dart-define=API_BASE_URL=https://api.example.com --dart-define=USE_MOCK_API=false
class AppConfig {
  AppConfig._();

  static const String appName = 'Tendryn';
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Serves canned responses in-process so the app runs without a backend.
  static const bool useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: true);

  /// Development preview: skip the login screen and open the Dashboard as a
  /// fixed demo user. On by default in debug builds only (`flutter run`);
  /// profile and release builds always use the normal authentication flow.
  /// Turn it off to exercise login in debug:
  ///   flutter run --dart-define=DEV_OPEN_DASHBOARD=false
  static const bool devOpenDashboard = bool.fromEnvironment('DEV_OPEN_DASHBOARD', defaultValue: kDebugMode);

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
