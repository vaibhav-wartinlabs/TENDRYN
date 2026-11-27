import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/authentication/dev_preview_user.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/constants/app_config.dart';
import 'package:tendryn/services/api_service.dart';
import 'package:tendryn/services/app_service.dart';
import 'package:tendryn/services/auth_service.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/dashboard_service.dart';
import 'package:tendryn/services/leave_service.dart';
import 'package:tendryn/services/queue_service.dart';
import 'package:tendryn/services/storage_service.dart';

/// Registers every app-wide dependency once, in dependency order.
/// Pass a [StorageManager] to substitute storage (tests).
class InitialBinding extends Bindings {
  InitialBinding({this._storage, bool? openDashboardPreview})
      : _openDashboardPreview = openDashboardPreview ?? AppConfig.devOpenDashboard;

  final StorageManager? _storage;

  /// Skip login and open the Dashboard as [DevPreviewUser] (development only).
  final bool _openDashboardPreview;

  @override
  void dependencies() {
    final storage = Get.put(_storage ?? StorageManager(), permanent: true);
    final session = Get.put(
      SessionService(secureStorage: storage.secure, refreshDio: ApiService.createBaseDio()),
      permanent: true,
    );
    final api = Get.put(ApiService(session: session), permanent: true);
    final auth = Get.put(AuthService(api: api), permanent: true);

    Get.put(
      AuthController(
        authService: auth,
        session: session,
        previewUser: _openDashboardPreview ? DevPreviewUser.user : null,
      ),
      permanent: true,
    );
    Get.put(RoleController(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
    Get.put(AppService(), permanent: true);

    // Feature services are created on first use.
    Get.lazyPut(() => DashboardService(api: Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => QueueService(api: Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => LeaveService(client: Get.find<ApiService>().client), fenix: true);
  }
}
