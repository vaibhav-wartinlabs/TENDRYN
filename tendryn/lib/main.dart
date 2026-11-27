import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/app_config.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/core/utils/app_logger.dart';
import 'package:tendryn/routes/app_pages.dart';
import 'package:tendryn/routes/initial_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Last-resort error reporting.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(error, stack);
    return true;
  };

  runApp(const TendrynApp());
}

class TendrynApp extends StatelessWidget {
  const TendrynApp({super.key, this.initialBinding});

  /// Override to inject fakes in tests.
  final Bindings? initialBinding;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      // Light mode only: the system (Android/Windows) dark setting is ignored.
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      initialBinding: initialBinding ?? InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
    );
  }
}
