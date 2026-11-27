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
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/features/queue/views/nurse_patient_profile_view.dart';
import 'package:tendryn/features/vitals_triage/controllers/vitals_triage_controller.dart';
import 'package:tendryn/features/vitals_triage/views/record_vitals_triage_view.dart';
import 'package:tendryn/features/vitals_triage/views/vitals_triage_view.dart';
import 'package:tendryn/features/vitals_triage/widgets/vitals_triage_widgets.dart';
import 'package:tendryn/routes/app_pages.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
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

  Future<void> pumpVitalsTriage(
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
        initialRoute: AppRoutes.vitalsTriage,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Vitals & Triage mobile renders cards and pagination', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(393, 852), desktop: false);

    expect(find.text('Vitals & Triage'), findsWidgets);
    expect(
      find.text('Patients waiting for or currently in triage. Select a patient to record observations.'),
      findsOneWidget,
    );
    expect(find.text('Search patients by name or ID'), findsOneWidget);
    expect(find.text('Awaiting triage'), findsOneWidget);

    // Patient card 1
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('TND-000124 · M · 42 yrs'), findsOneWidget);
    expect(find.text('Q-012'), findsOneWidget);
    expect(find.text('24 min'), findsOneWidget);
    expect(find.text('Headache'), findsOneWidget);
    expect(find.text('Waiting'), findsWidgets);
    expect(find.text('Routine'), findsWidgets);

    // Other patients
    expect(find.text('Kabelo Mokoena'), findsOneWidget);
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Naledi Molefe'), findsOneWidget);

    // Mobile pagination buttons
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Vitals & Triage tablet renders 2-col grid and header counts', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(744, 954), desktop: false);

    expect(find.text('Vitals & Triage'), findsWidgets);
    expect(find.text("Today's queue"), findsOneWidget);
    expect(find.text('6 patients · 2 awaiting triage'), findsOneWidget);

    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Kabelo Mokoena'), findsOneWidget);

    expect(find.text('Showing 1–5 of 24 patients'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Vitals & Triage desktop renders table layout', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(1280, 800), desktop: true);

    expect(find.text('Vitals & Triage'), findsWidgets);
    expect(find.text('Awaiting triage'), findsOneWidget);

    // Table columns
    expect(find.widgetWithText(VitalsTriageTable, 'Queue'), findsOneWidget);
    expect(find.widgetWithText(VitalsTriageTable, 'Patient'), findsOneWidget);
    expect(find.text('Waiting'), findsWidgets);
    expect(find.widgetWithText(VitalsTriageTable, 'Reason'), findsOneWidget);
    expect(find.widgetWithText(VitalsTriageTable, 'Status'), findsOneWidget);
    expect(find.widgetWithText(VitalsTriageTable, 'Priority'), findsOneWidget);
    expect(find.widgetWithText(VitalsTriageTable, 'Actions'), findsOneWidget);

    // Table rows
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('TND-000124 · M · 42 yrs'), findsOneWidget);
    expect(find.text('Q-012'), findsOneWidget);

    expect(find.text('Showing 1–5 of 24 patients'), findsOneWidget);
  });

  testWidgets('Vitals & Triage action menu opens patient profile', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(1280, 800), desktop: true);

    // Find the first 3-dots icon button
    final moreButtons = find.byIcon(Icons.more_vert);
    expect(moreButtons, findsWidgets);

    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();

    // Verify popup menu options
    expect(find.text('View Patient'), findsOneWidget);
    expect(find.text('Begin Triage'), findsOneWidget);

    // Tap View Patient
    await tester.tap(find.text('View Patient'));
    await tester.pumpAndSettle();

    // Should open NursePatientProfileView
    expect(find.byType(NursePatientProfileView), findsOneWidget);
    expect(find.text('Back to Vitals / Triage'), findsOneWidget);
  });

  testWidgets('Vitals & Triage action menu opens begin triage page', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(1280, 800), desktop: true);

    // Find the first 3-dots icon button
    final moreButtons = find.byIcon(Icons.more_vert);
    expect(moreButtons, findsWidgets);

    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();

    // Tap Begin Triage
    expect(find.text('Begin Triage'), findsOneWidget);
    await tester.tap(find.text('Begin Triage'));
    await tester.pumpAndSettle();

    // Should open RecordVitalsTriageView
    expect(find.byType(RecordVitalsTriageView), findsOneWidget);
    expect(find.text('Back to Patient profile'), findsOneWidget);
    expect(find.text('A Presenting complaint'), findsOneWidget);
    expect(find.text('C Triage priority'), findsOneWidget);

    // Scroll to see B, D and review triage
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('B Vital signs'), findsOneWidget);
    expect(find.text('D Triage notes'), findsOneWidget);
    expect(find.text('Review triage'), findsOneWidget);
  });

  testWidgets('Search filters patients reactively', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(1280, 800), desktop: true);

    final controller = Get.find<VitalsTriageController>();
    controller.search('Chest');
    await tester.pumpAndSettle();

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('John Smith'), findsNothing);

    controller.search('');
    await tester.pumpAndSettle();
    expect(find.text('John Smith'), findsOneWidget);
  });

  testWidgets('Begin triage mobile hides bottom nav and displays boxed back button', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(393, 852), desktop: false);

    // Initial mobile vitals page shows bottom navigation
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    final moreButtons = find.byIcon(Icons.more_vert);
    expect(moreButtons, findsWidgets);

    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Begin Triage'), findsOneWidget);
    await tester.tap(find.text('Begin Triage'));
    await tester.pumpAndSettle();

    // Now in RecordVitalsTriageView
    expect(find.byType(RecordVitalsTriageView), findsOneWidget);
    // Bottom navigation MUST be hidden on mobile
    expect(find.byType(AppBottomNavigation), findsNothing);
    // Boxed back button with 'Back' tooltip is present
    expect(find.byTooltip('Back'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Returns to VitalsTriageView with bottom navigation restored
    expect(find.byType(VitalsTriageView), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
  });

  testWidgets('Begin triage tablet hides bottom nav and displays boxed back button', (tester) async {
    await pumpVitalsTriage(tester, size: const Size(744, 954), desktop: false);

    // Initial tablet vitals page shows bottom navigation
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    final moreButtons = find.byIcon(Icons.more_vert);
    expect(moreButtons, findsWidgets);

    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Begin Triage'), findsOneWidget);
    await tester.tap(find.text('Begin Triage'));
    await tester.pumpAndSettle();

    // Now in RecordVitalsTriageView
    expect(find.byType(RecordVitalsTriageView), findsOneWidget);
    // Bottom navigation MUST be hidden on tablet
    expect(find.byType(AppBottomNavigation), findsNothing);
    // Boxed back button with 'Back' tooltip is present
    expect(find.byTooltip('Back'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Returns to VitalsTriageView with bottom navigation restored
    expect(find.byType(VitalsTriageView), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
  });
}
