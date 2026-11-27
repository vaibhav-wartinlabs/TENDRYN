import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/authentication/dev_preview_user.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/role/role_guard.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/core/utils/loadable_mixin.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/views/queue_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/routes/route_names.dart';
import 'package:tendryn/services/api_service.dart';
import 'package:tendryn/services/auth_service.dart' as svc;
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/queue_service.dart';
import 'package:tendryn/services/storage_service.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';

class _MemoryStorage implements StorageService {
  final _data = <String, String>{};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

List<String> _labels(List<NavDestination> d) => d.map((e) => e.label).toList();

/// Flutter tests draw unloaded fonts as wide boxes; load the app fonts so text
/// is measured like on a device and overflow checks mean something.
Future<void> _loadAppFonts() async {
  for (final (family, path) in [
    ('Inter', 'assets/fonts/Inter.ttf'),
    ('Plus Jakarta Sans', 'assets/fonts/PlusJakartaSans.ttf'),
  ]) {
    final loader = FontLoader(family)..addFont(rootBundle.load(path));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadAppFonts);

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async => methodCall.method == 'check' ? <String>['wifi'] : null,
    );
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    final storage = Get.put(
      StorageManager(secure: _MemoryStorage(), preferences: _MemoryStorage()),
      permanent: true,
    );
    final session = Get.put(
      SessionService(secureStorage: storage.secure, refreshDio: ApiService.createBaseDio()),
      permanent: true,
    );
    final api = Get.put(ApiService(session: session), permanent: true);
    final authSvc = Get.put(svc.AuthService(api: api), permanent: true);
    final auth = Get.put(
      AuthController(authService: authSvc, session: session, previewUser: DevPreviewUser.user),
      permanent: true,
    );
    await auth.restoreSession();
    Get.put(ConnectivityService(), permanent: true);
    Get.put(RoleController(), permanent: true);
    Get.lazyPut(() => QueueService(api: Get.find<ApiService>()), fenix: true);
  });

  tearDown(() {
    ResponsiveHelper.debugIsDesktopPlatformOverride = null;
    Get.reset();
  });

  group('Nurse navigation', () {
    test('Nurse has exactly Queue, Patients and Vitals / Triage, opening on Queue', () {
      expect(_labels(NavDestinations.forRole(ClinicRole.nurse)), ['Queue', 'Patients', 'Vitals / Triage']);
      expect(_labels(NavDestinations.forRoleBottom(ClinicRole.nurse)), ['Queue', 'Patients', 'Vitals / Triage']);
      expect(NavDestinations.nurse.map((d) => d.route), [
        AppRoutes.queue,
        AppRoutes.patients,
        AppRoutes.vitalsTriage,
      ]);
      expect(RouteNames.titleOf(AppRoutes.vitalsTriage), 'Vitals / Triage');

      final bottom = NavDestinations.forRoleBottom(ClinicRole.nurse);
      expect(NavDestinations.indexOf(AppRoutes.queue, bottom), 0);
      expect(NavDestinations.indexOf(AppRoutes.patients, bottom), 1);
      expect(NavDestinations.indexOf(AppRoutes.vitalsTriage, bottom), 2);
    });

    test('Receptionist and Doctor navigation is unchanged', () {
      expect(_labels(NavDestinations.forRole(ClinicRole.receptionist)), [
        'Dashboard', 'Queue', 'Patients', 'Appointments', 'Billing',
      ]);
      expect(_labels(NavDestinations.forRoleBottom(ClinicRole.receptionist)), [
        'Dashboard', 'Queue', 'Patients', 'Appointments', 'Billing',
      ]);
      expect(_labels(NavDestinations.forRole(ClinicRole.doctor)), [
        'Dashboard', 'Queue', 'Patients', 'Consultations', 'Lab Results', 'Appointments',
      ]);
      expect(_labels(NavDestinations.forRoleBottom(ClinicRole.doctor)), [
        'Dashboard', 'Queue', 'Patients', 'Appointments', 'More',
      ]);
    });
  });

  group('Switching roles', () {
    test('Receptionist -> Nurse -> Doctor -> Nurse -> Receptionist restores each role', () async {
      final roles = RoleController.to;
      final auth = Get.find<AuthController>();
      expect(roles.currentRole.value, ClinicRole.receptionist);
      expect(roles.homeRoute, AppRoutes.dashboard);

      await roles.switchRole(ClinicRole.nurse);
      expect(roles.currentRole.value, ClinicRole.nurse);
      expect(roles.homeRoute, AppRoutes.queue);
      expect(_labels(roles.currentDestinations), ['Queue', 'Patients', 'Vitals / Triage']);
      expect(_labels(roles.currentBottomDestinations), ['Queue', 'Patients', 'Vitals / Triage']);
      expect(auth.user?.jobTitle, 'Nurse');
      expect(auth.user?.name, 'Sister Naledi Naidoo');

      await roles.switchRole(ClinicRole.doctor);
      expect(roles.homeRoute, AppRoutes.dashboard);
      expect(_labels(roles.currentBottomDestinations).last, 'More');
      expect(auth.user?.jobTitle, 'Doctor');

      await roles.switchRole(ClinicRole.nurse);
      await roles.switchRole(ClinicRole.receptionist);
      expect(_labels(roles.currentBottomDestinations), [
        'Dashboard', 'Queue', 'Patients', 'Appointments', 'Billing',
      ]);
      expect(auth.user?.jobTitle, 'Receptionist');
    });

    test('The Nurse role is saved with the selected role', () async {
      await RoleController.to.switchRole(ClinicRole.nurse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tendryn_active_role'), 'nurse');
    });
  });

  group('RoleGuard', () {
    test('Nurse can open only its own destinations', () async {
      await RoleController.to.switchRole(ClinicRole.nurse);
      final guard = RoleGuard();
      for (final route in [AppRoutes.queue, AppRoutes.patients, AppRoutes.vitalsTriage]) {
        expect(guard.redirect(route), isNull, reason: route);
      }
      for (final route in [
        AppRoutes.dashboard,
        AppRoutes.appointments,
        AppRoutes.billing,
        AppRoutes.consultations,
        AppRoutes.labResults,
      ]) {
        expect(guard.redirect(route)?.name, AppRoutes.queue, reason: route);
      }
    });

    test('Doctor and Receptionist keep their routes but cannot open Vitals / Triage', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.dashboard), isNull);
      expect(guard.redirect(AppRoutes.billing), isNull);
      expect(guard.redirect(AppRoutes.vitalsTriage)?.name, AppRoutes.dashboard);

      await RoleController.to.switchRole(ClinicRole.doctor);
      expect(guard.redirect(AppRoutes.consultations), isNull);
      expect(guard.redirect(AppRoutes.vitalsTriage)?.name, AppRoutes.dashboard);
    });
  });

  group('Formatters', () {
    test('staffInitials skips a leading title', () {
      expect(Formatters.staffInitials('Sister Naledi Naidoo'), 'NN');
      expect(Formatters.staffInitials('Dr Thandi Nkosi'), 'TN');
      expect(Formatters.staffInitials('Lerato Mokoena'), 'LM');
    });

    test('waitingTime', () {
      expect(Formatters.waitingTime(24), '24 min');
      expect(Formatters.waitingTime(60), '1 h');
      expect(Formatters.waitingTime(70), '1 h 10 min');
    });
  });

  group('Nurse Queue layouts', () {
    Future<void> pumpNurseQueue(
      WidgetTester tester, {
      required Size size,
      required bool desktopPlatform,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      ResponsiveHelper.debugIsDesktopPlatformOverride = desktopPlatform;

      await RoleController.to.switchRole(ClinicRole.nurse);
      Get.put(QueueController(service: Get.find<QueueService>()));

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: const AppShell(route: AppRoutes.queue, child: QueueView()),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    testWidgets('desktop: side navigation, top bar and the queue table', (tester) async {
      await pumpNurseQueue(tester, size: const Size(1280, 970), desktopPlatform: true);

      expect(tester.takeException(), isNull);
      // Side navigation: three destinations, no Dashboard.
      expect(find.text('Queue'), findsWidgets);
      expect(find.text('Patients'), findsWidgets);
      expect(find.text('Vitals / Triage'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      // Top bar.
      expect(find.text('Soweto Community Health Centre'), findsOneWidget);
      expect(find.text('Sister Naledi Naidoo'), findsOneWidget);
      expect(find.text('Nurse · Switch user'), findsOneWidget);
      expect(find.text('NN'), findsOneWidget);
      // Page.
      expect(find.text('Triage queue'), findsOneWidget);
      expect(find.text('Call next'), findsOneWidget);
      expect(find.text('Today’s queue'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('tablet portrait: header, card grid and a three-item bottom bar', (tester) async {
      await pumpNurseQueue(tester, size: const Size(744, 1222), desktopPlatform: false);

      expect(tester.takeException(), isNull);
      expect(find.text('Sister Naledi Naidoo'), findsOneWidget);
      expect(find.text('Nurse · Switch user'), findsOneWidget);
      expect(find.text('Triage queue'), findsOneWidget);
      expect(find.text('Call next'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsOneWidget);
      expect(find.text('Priority'), findsNothing); // cards, not a table
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Vitals / Triage'), findsOneWidget);
    });

    testWidgets('tablet landscape: uses the width without overflow', (tester) async {
      await pumpNurseQueue(tester, size: const Size(1194, 744), desktopPlatform: false);

      expect(tester.takeException(), isNull);
      expect(find.text('Triage queue'), findsOneWidget);
      expect(find.text('Vitals / Triage'), findsOneWidget);
    });

    testWidgets('mobile: single column cards, Previous / Next and a full-width Call next', (tester) async {
      await pumpNurseQueue(tester, size: const Size(393, 852), desktopPlatform: false);

      expect(tester.takeException(), isNull);
      expect(find.text('Triage queue'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsOneWidget);
      expect(find.text('Vitals / Triage'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      await tester.dragUntilVisible(find.text('Call next'), find.byType(ListView), const Offset(0, -300));
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Call next'), findsOneWidget);
    });

    for (final (name, size, desktop) in [
      ('small phone 360x640', const Size(360, 640), false),
      ('large phone 430x932', const Size(430, 932), false),
      ('small tablet 600x960', const Size(600, 960), false),
      ('tablet 820x1180', const Size(820, 1180), false),
      ('large tablet landscape 1366x1024', const Size(1366, 1024), false),
      ('large tablet portrait 1024x1366', const Size(1024, 1366), false),
      ('narrow Windows window 1200x800', const Size(1200, 800), true),
    ]) {
      testWidgets('lays out without overflow: $name', (tester) async {
        await pumpNurseQueue(tester, size: size, desktopPlatform: desktop);
        expect(tester.takeException(), isNull);
        expect(find.text('Triage queue'), findsOneWidget);
        expect(find.text('Vitals / Triage'), findsOneWidget);
      });
    }

    testWidgets('a failed update keeps the saved queue and shows the banner', (tester) async {
      await pumpNurseQueue(tester, size: const Size(1280, 970), desktopPlatform: true);
      expect(find.text('Queue couldn’t be updated'), findsNothing);

      final controller = Get.find<QueueController>();
      controller.status.value = LoadStatus.error;
      await tester.pump();

      expect(find.text('Queue couldn’t be updated'), findsOneWidget);
      expect(
        find.text('Check your connection and try again. Showing the last saved queue.'),
        findsOneWidget,
      );
      expect(find.text('Thabo Nkosi'), findsOneWidget);
    });
  });
}
