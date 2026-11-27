import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/authentication/dev_preview_user.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/api_service.dart';
import 'package:tendryn/services/auth_service.dart' as svc;
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/storage_service.dart';
import 'package:tendryn/widgets/common/doctor_coming_soon_view.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/common/under_development_view.dart';
import 'package:tendryn/widgets/desktop/role_switcher_widget.dart';

class _MemoryStorage implements StorageService {
  final _data = <String, String>{};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

void main() {
  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return <String>['wifi'];
        }
        return null;
      },
    );
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    final storage = Get.put(StorageManager(secure: _MemoryStorage(), preferences: _MemoryStorage()), permanent: true);
    final session = Get.put(SessionService(secureStorage: storage.secure, refreshDio: ApiService.createBaseDio()), permanent: true);
    final api = Get.put(ApiService(session: session), permanent: true);
    final authSvc = Get.put(svc.AuthService(api: api), permanent: true);
    final auth = Get.put(AuthController(authService: authSvc, session: session, previewUser: DevPreviewUser.user), permanent: true);
    await auth.restoreSession();
    Get.put(ConnectivityService(), permanent: true);
    Get.put(RoleController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  test('RoleController starts as receptionist by default and can switch to doctor', () async {
    final controller = RoleController.to;
    expect(controller.currentRole.value, ClinicRole.receptionist);
    expect(controller.currentDestinations.map((d) => d.label).toList(), [
      'Dashboard',
      'Queue',
      'Patients',
      'Appointments',
      'Billing',
    ]);

    await controller.switchRole(ClinicRole.doctor);
    expect(controller.currentRole.value, ClinicRole.doctor);
    expect(controller.currentDestinations.map((d) => d.label).toList(), [
      'Dashboard',
      'Queue',
      'Patients',
      'Consultations',
      'Lab Results',
      'Appointments',
    ]);

    // Badges on Doctor destinations (Queue and Lab Results)
    final queue = controller.currentDestinations.firstWhere((d) => d.label == 'Queue');
    final lab = controller.currentDestinations.firstWhere((d) => d.label == 'Lab Results');
    expect(queue.badgeCount, 3);
    expect(lab.badgeCount, 3);
  });

  testWidgets('RoleSwitcherWidget renders choice chips and switches active role on tap', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: RoleSwitcherWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Reception'), findsOneWidget);

    // Tap Doctor choice chip
    await tester.tap(find.text('Doctor'));
    await tester.pumpAndSettle();

    expect(RoleController.to.currentRole.value, ClinicRole.doctor);
    expect(Get.find<AuthController>().user?.jobTitle, 'Doctor');
    expect(Get.find<AuthController>().user?.name, 'Dr Thandi Nkosi');
  });

  testWidgets('UnderDevelopmentView renders clean UI with Back to Dashboard action', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: UnderDevelopmentView(title: 'Consultations'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(UnderDevelopmentView), findsOneWidget);
    expect(find.text('Consultations Module'), findsOneWidget);
    expect(find.text('UNDER DEVELOPMENT'), findsOneWidget);
    expect(find.text('Back to Dashboard'), findsOneWidget);
  });

  testWidgets('DoctorComingSoonView renders top-left heading and centered Coming Soon', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DoctorComingSoonView(title: 'Dashboard'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(DoctorComingSoonView), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);
  });

  test('NavDestinations for doctor mobile bottom navigation has 5 tabs and maps More correctly', () {
    final bottomDestinations = NavDestinations.forRoleBottom(ClinicRole.doctor);
    expect(bottomDestinations.map((d) => d.label).toList(), [
      'Dashboard',
      'Queue',
      'Patients',
      'Appointments',
      'More',
    ]);

    // Primary routes
    expect(NavDestinations.indexOf(AppRoutes.dashboard, bottomDestinations), 0);
    expect(NavDestinations.indexOf(AppRoutes.queue, bottomDestinations), 1);
    expect(NavDestinations.indexOf(AppRoutes.patients, bottomDestinations), 2);
    expect(NavDestinations.indexOf(AppRoutes.appointments, bottomDestinations), 3);

    // Overflow routes mapped to 'More' (index 4)
    expect(NavDestinations.indexOf(AppRoutes.consultations, bottomDestinations), 4);
    expect(NavDestinations.indexOf(AppRoutes.labResults, bottomDestinations), 4);
  });
}
