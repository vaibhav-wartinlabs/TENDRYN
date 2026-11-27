import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/authentication/dev_preview_user.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/queue/views/nurse_patient_profile_view.dart';
import 'package:tendryn/routes/app_pages.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/api_service.dart';
import 'package:tendryn/services/auth_service.dart' as svc;
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/queue_service.dart';
import 'package:tendryn/services/storage_service.dart';

class _MemoryStorage implements StorageService {
  final _data = <String, String>{};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async =>
          methodCall.method == 'check' ? <String>['wifi'] : null,
    );
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    final storage = Get.put(
      StorageManager(secure: _MemoryStorage(), preferences: _MemoryStorage()),
      permanent: true,
    );
    final session = Get.put(
      SessionService(
          secureStorage: storage.secure, refreshDio: ApiService.createBaseDio()),
      permanent: true,
    );
    final api = Get.put(ApiService(session: session), permanent: true);
    final authSvc = Get.put(svc.AuthService(api: api), permanent: true);
    final auth = Get.put(
      AuthController(
          authService: authSvc,
          session: session,
          previewUser: DevPreviewUser.user),
      permanent: true,
    );
    await auth.restoreSession();
    Get.put(ConnectivityService(), permanent: true);
    Get.put(RoleController(), permanent: true);
    Get.lazyPut(() => QueueService(api: Get.find<ApiService>()), fenix: true);
    await RoleController.to.switchRole(ClinicRole.nurse);
  });

  tearDown(() {
    ResponsiveHelper.debugIsDesktopPlatformOverride = null;
    Get.reset();
  });

  Future<void> pumpPatients(
    WidgetTester tester, {
    required Size size,
    required bool desktop,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ResponsiveHelper.debugIsDesktopPlatformOverride = desktop;

    await RoleController.to.switchRole(ClinicRole.nurse);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        getPages: AppPages.pages,
        initialRoute: AppRoutes.patients,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Nurse Patients directory mobile renders correctly', (tester) async {
    await pumpPatients(tester, size: const Size(393, 852), desktop: false);

    expect(find.text('Patients'), findsWidgets);
    expect(find.text('Search patient records and open a profile.'), findsOneWidget);
    expect(find.text('Search name, ID or queue number'), findsOneWidget);
    expect(find.text('All patients'), findsOneWidget);
    expect(find.text('5 patients'), findsOneWidget);

    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('TND-000124 · Male · 42 yrs'), findsOneWidget);
    expect(find.text('Last visit'), findsWidgets);
    expect(find.text('Today · Headache'), findsWidgets);
    expect(find.text('View profile'), findsWidgets);

    expect(find.text('Kabelo Mokoena'), findsOneWidget);
    expect(find.text('TND-000131 · Male · 36 yrs'), findsOneWidget);

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Naledi Molefe'), findsOneWidget);
    expect(find.text('Sipho Dlamini'), findsOneWidget);

    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Nurse Patients directory desktop renders table layout', (tester) async {
    await pumpPatients(tester, size: const Size(1280, 800), desktop: true);

    expect(find.text('Patients'), findsWidgets);
    expect(find.text('Search patient records and open a profile.'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Patient ID'), findsOneWidget);
    expect(find.text('Sex · Age'), findsOneWidget);
    expect(find.text('Last visit'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);

    expect(find.text('Showing 1–5 of 24 patients'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Nurse Patients directory tablet renders 2-column grid', (tester) async {
    await pumpPatients(tester, size: const Size(744, 1024), desktop: false);

    expect(find.text('Patients'), findsWidgets);
    expect(find.text('All patients'), findsOneWidget);
    expect(find.text('5 patients'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Showing 1–5 of 24 patients'), findsOneWidget);
  });

  testWidgets('Tapping View profile opens NursePatientProfileView with TND-000124 and Back to Patients', (tester) async {
    await pumpPatients(tester, size: const Size(1280, 800), desktop: true);

    // Tap first 'View profile' link (John Smith)
    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    expect(find.byType(NursePatientProfileView), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.textContaining('TND-000124'), findsWidgets);
    expect(find.text('Reason for visit'), findsWidgets);
    expect(find.text('Headache'), findsWidgets);

    // Desktop chip explicitly shows 'Back to Patients' per Figma
    expect(find.text('Back to Patients'), findsOneWidget);

    // Tapping Back to Patients returns to Patients directory
    await tester.tap(find.text('Back to Patients'));
    await tester.pumpAndSettle();

    expect(find.byType(NursePatientProfileView), findsNothing);
    expect(find.text('Showing 1–5 of 24 patients'), findsOneWidget);
  });

  testWidgets('Searching filters nurse patients reactively', (tester) async {
    await pumpPatients(tester, size: const Size(393, 852), desktop: false);

    final controller = Get.find<PatientsController>();
    controller.search('Kabelo');
    await tester.pumpAndSettle();

    expect(find.text('Kabelo Mokoena'), findsOneWidget);
    expect(find.text('John Smith'), findsNothing);
    expect(find.text('1 patients'), findsOneWidget);
  });

  testWidgets('Nurse Patients directory mobile: Tapping patient card opens profile without bottom nav and Back returns', (tester) async {
    await pumpPatients(tester, size: const Size(393, 852), desktop: false);

    // Tap first patient card (John Smith)
    await tester.tap(find.text('John Smith'));
    await tester.pumpAndSettle();

    expect(find.byType(NursePatientProfileView), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);

    // Bottom nav is hidden when viewing profile on mobile
    expect(find.text('Queue'), findsNothing);
    expect(find.text('Vitals / Triage'), findsNothing);

    // Tapping back returns to Patients and restores bottom nav
    await tester.tap(find.byTooltip('Back to Patients'));
    await tester.pumpAndSettle();

    expect(find.byType(NursePatientProfileView), findsNothing);
    expect(find.text('5 patients'), findsOneWidget);
    expect(find.text('Queue'), findsOneWidget);
  });
}
