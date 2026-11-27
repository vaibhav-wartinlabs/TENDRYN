import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/authentication/dev_preview_user.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/features/consultation/controllers/consultation_controller.dart';
import 'package:tendryn/features/consultation/views/clinical_consultation_view.dart';
import 'package:tendryn/features/consultation/views/consultation_view.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_pages.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/api_service.dart';
import 'package:tendryn/services/auth_service.dart' as svc;
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/storage_service.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

class _MemoryStorage implements StorageService {
  final _data = <String, String>{};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

class _FakeConnectivityService extends GetxService implements ConnectivityService {
  @override
  final isOnline = true.obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    resetPrescriptionSession();
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
    Get.put<ConnectivityService>(_FakeConnectivityService(), permanent: true);
    final roleController = Get.put(RoleController(), permanent: true);
    roleController.currentRole.value = ClinicRole.doctor;
  });

  tearDown(() {
    resetPrescriptionSession();
    Get.reset();
  });

  testWidgets('Consultations view displays header, Start Consultation button, search bar, and records table', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: ConsultationView()),
      ),
    );
    await tester.pumpAndSettle();

    // Page title and subtitle
    expect(find.text('Consultations'), findsOneWidget);
    expect(find.text('Manage drafts, signed notes, and follow-up actions.'), findsOneWidget);

    // Search bar and placeholder
    expect(find.text('Search Patients or consultation...'), findsOneWidget);

    // Table title and columns
    expect(find.text('Consultation records'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Visit'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Last updated'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);

    // Patient rows from reference
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Today · Queue Q-004'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('12 Oct · 10:34'), findsOneWidget);

    expect(find.text('Nomsa Dlamini'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('12 Oct · 09:18'), findsOneWidget);

    expect(find.text('Sipho Khumalo'), findsOneWidget);
    expect(find.text('09 Oct 2026'), findsOneWidget);
    expect(find.text('Signed'), findsNWidgets(2));
    expect(find.text('09 Oct · 14:20'), findsOneWidget);

    expect(find.text('Lerato Maseko'), findsOneWidget);
    expect(find.text('08 Oct 2026'), findsOneWidget);
    expect(find.text('08 Oct · 11:05'), findsOneWidget);

    // Footer
    expect(find.text('Showing 1–4 of 4 consultations'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Search input filters consultation records dynamically', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: ConsultationView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Nomsa Dlamini'), findsOneWidget);

    // Enter search query
    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'Thabo');
    await tester.pumpAndSettle();

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Nomsa Dlamini'), findsNothing);
    expect(find.text('Showing 1–1 of 1 consultations'), findsOneWidget);

    // Clear search query
    await tester.enterText(searchInput, '');
    await tester.pumpAndSettle();

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Nomsa Dlamini'), findsOneWidget);
  });

  testWidgets('Status filter filters records correctly', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: ConsultationView()),
      ),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<ConsultationController>();
    controller.setFilter('Signed');
    await tester.pumpAndSettle();

    expect(find.text('Sipho Khumalo'), findsOneWidget);
    expect(find.text('Lerato Maseko'), findsOneWidget);
    expect(find.text('Thabo Mokoena'), findsNothing);
    expect(find.text('Nomsa Dlamini'), findsNothing);
    expect(find.text('Showing 1–2 of 2 consultations'), findsOneWidget);
  });

  testWidgets('Routing to AppRoutes.consultations displays consultation page inside app shell', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultations,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultations'), findsNWidgets(2));
    expect(find.text('Consultation records'), findsOneWidget);
    expect(find.text('Thabo Mokoena'), findsOneWidget);
  });

  testWidgets('Three dots action button opens popup menu with View profile and Start consultation without navigating', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.pages,
        home: const Scaffold(body: ConsultationView()),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first three dots icon
    final threeDots = find.byIcon(LucideIcons.ellipsisVertical).first;
    await tester.tap(threeDots);
    await tester.pumpAndSettle();

    // Menu options appear
    expect(find.text('View profile'), findsOneWidget);
    expect(find.text('Start consultation'), findsOneWidget);

    // Tap 'View profile' - opens Doctor Patient Profile
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();

    expect(find.text('Patient profile'), findsOneWidget);
    expect(find.text('Consultation records'), findsNothing);
    expect(find.text('Back to consultations'), findsOneWidget);

    // Tap back button to return to consultation records
    await tester.tap(find.text('Back to consultations'));
    await tester.pumpAndSettle();

    expect(find.text('Consultation records'), findsOneWidget);

    // Tap three dots again and tap 'Start consultation' (navigates to consultation workspace)
    await tester.tap(find.byIcon(LucideIcons.ellipsisVertical).first);
    await tester.pumpAndSettle();

    expect(find.text('Start consultation'), findsOneWidget);
    await tester.tap(find.text('Start consultation'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.consultationWorkspace);
  });

  testWidgets('Start Consultation button inside profile opened from consultations returns to consultations', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultations,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Tap first three dots icon -> View profile
    final threeDots = find.byIcon(LucideIcons.ellipsisVertical).first;
    await tester.tap(threeDots);
    await tester.pumpAndSettle();

    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();

    expect(find.text('Patient profile'), findsOneWidget);

    // Tap 'Start Consultation' inside the profile
    await tester.tap(find.text('Start Consultation'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.consultationWorkspace);
    expect(find.text('Back to Consultations'), findsOneWidget);
    expect(find.text('Thabo Mokoena'), findsOneWidget);
  });

  testWidgets('Tablet view renders 2-column cards layout without start consultation button, with working 3-dots actions', (tester) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: ConsultationView()),
      ),
    );
    await tester.pumpAndSettle();

    // Headers
    expect(find.text('Consultations'), findsOneWidget);
    expect(find.text('Manage drafts, signed notes, and follow-up actions.'), findsOneWidget);
    expect(find.text('Search Patients or consultation...'), findsOneWidget);
    expect(find.text('Consultation records'), findsOneWidget);

    // Cards with status badges and visit/updated info
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Visit: Today · Queue Q-004'), findsOneWidget);
    expect(find.text('Last updated: 12 Oct · 10:34'), findsOneWidget);

    expect(find.text('Nomsa Dlamini'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Visit: Today'), findsOneWidget);
    expect(find.text('Last updated: 12 Oct · 09:18'), findsOneWidget);

    expect(find.text('Sipho Khumalo'), findsOneWidget);
    expect(find.text('Signed'), findsNWidgets(2));

    // Footer
    expect(find.text('Showing 1–4 of 4 consultations'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Three dots button opens menu with View profile & Start consultation
    final threeDots = find.byIcon(LucideIcons.ellipsisVertical).first;
    await tester.tap(threeDots);
    await tester.pumpAndSettle();

    expect(find.text('View profile'), findsOneWidget);
    expect(find.text('Start consultation'), findsOneWidget);

    // Tap View profile opens patient profile
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();
    expect(find.text('Patient profile'), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);

    // Tap back button returns to consultation records
    await tester.tap(find.byIcon(AppIcons.chevronLeft));
    await tester.pumpAndSettle();
    expect(find.text('Consultation records'), findsOneWidget);
  });

  testWidgets('Mobile view renders 1-column cards list without bottom start consultation button, with working 3-dots actions', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: ConsultationView()),
      ),
    );
    await tester.pumpAndSettle();

    // Headers
    expect(find.text('Consultations'), findsOneWidget);
    expect(find.text('Manage drafts, signed notes, and follow-up actions.'), findsOneWidget);
    expect(find.text('Search Patients or consultation...'), findsOneWidget);
    expect(find.text('Consultation records'), findsOneWidget);

    // Individual cards
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Visit: Today · Queue Q-004'), findsOneWidget);

    expect(find.text('Nomsa Dlamini'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);

    // Footer is hidden on mobile per user instruction
    expect(find.text('Showing 1–4 of 4 consultations'), findsNothing);
    expect(find.text('Previous'), findsNothing);
    expect(find.text('Next'), findsNothing);

    // Three dots button is pinned to the right edge of the card
    final threeDots = find.byIcon(LucideIcons.ellipsisVertical).first;
    expect(tester.getTopRight(threeDots).dx, greaterThan(320));

    // Three dots button opens menu
    await tester.tap(threeDots);
    await tester.pumpAndSettle();

    expect(find.text('View profile'), findsOneWidget);
    expect(find.text('Start consultation'), findsOneWidget);

    // Tap View profile opens patient profile
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();
    expect(find.text('Patient profile'), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);

    // Tap back button returns to consultation records
    await tester.tap(find.byIcon(AppIcons.chevronLeft));
    await tester.pumpAndSettle();
    expect(find.text('Consultation records'), findsOneWidget);
  });

  testWidgets('Mobile view hides bottom navigation when viewing profile and restores on back', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultations,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom navigation is initially visible
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('Consultation records'), findsOneWidget);

    // Open 3-dots menu and tap 'View profile'
    final threeDots = find.byIcon(LucideIcons.ellipsisVertical).first;
    await tester.tap(threeDots);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();

    // Profile is displayed
    expect(find.text('Patient profile'), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);

    // Bottom navigation bar MUST be hidden on mobile when profile is open
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Tap back button
    await tester.tap(find.byIcon(AppIcons.chevronLeft));
    await tester.pumpAndSettle();

    // Profile closed, consultation records shown, and bottom nav restored
    expect(find.text('Consultation records'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
  });

  testWidgets('Tablet view hides bottom navigation when viewing profile and restores on back', (tester) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultations,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom navigation is initially visible
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('Consultation records'), findsOneWidget);

    // Open 3-dots menu and tap 'View profile'
    final threeDots = find.byIcon(LucideIcons.ellipsisVertical).first;
    await tester.tap(threeDots);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();

    // Profile is displayed
    expect(find.text('Patient profile'), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);

    // Bottom navigation bar MUST be hidden on tablet when profile is open
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Tap back button
    await tester.tap(find.byIcon(AppIcons.chevronLeft));
    await tester.pumpAndSettle();

    // Profile closed, consultation records shown, and bottom nav restored
    expect(find.text('Consultation records'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
  });

  testWidgets('Consultation workspace on mobile hides bottom navigation and renders boxed back button', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Bottom navigation bar MUST be hidden in consultation workspace
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Boxed back button with chevronLeft icon exists before Consultation title
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);
    expect(find.text('Back to Consultations'), findsNothing);

    // Main headings
    expect(find.text('Consultation'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);

    // Bottom actions
    expect(find.text('Save draft'), findsOneWidget);
    expect(find.text('Review consultation'), findsOneWidget);
  });

  testWidgets('Consultation workspace on tablet hides bottom navigation and renders boxed back button', (tester) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Bottom navigation bar MUST be hidden in consultation workspace on tablet too
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Boxed back button with chevronLeft icon exists before Consultation title
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);
    expect(find.text('Back to Consultations'), findsNothing);
    expect(find.text('Consultation'), findsOneWidget);
    expect(find.text('Review consultation'), findsOneWidget);
  });

  testWidgets('Consultation workspace on desktop renders back button with label', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Back to Consultations'), findsOneWidget);
    expect(find.text('Consultation'), findsOneWidget);
  });

  testWidgets('Consultation workspace renders status badge matching passed status argument', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultations,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Nomsa Dlamini has 'Draft' status in mock records
    expect(find.text('Nomsa Dlamini'), findsOneWidget);
    expect(find.text('Draft'), findsWidgets);

    // Navigate to consultation workspace with status: 'Draft'
    AppNavigation.goToConsultationWorkspace(status: 'Draft');
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.consultationWorkspace);
    expect(find.text('Draft'), findsWidgets);
  });

  testWidgets('Clicking Add prescription opens slide drawer on desktop preserving consultation background', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Consultation background is present
    expect(find.text('Consultation'), findsOneWidget);
    expect(find.text('Add prescription'), findsOneWidget);

    // Scroll to and tap Add prescription
    await tester.ensureVisible(find.text('Add prescription'));
    await tester.tap(find.text('Add prescription'));
    await tester.pumpAndSettle();

    // Drawer is now open as overlay
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);
    expect(find.text('Search Medicines'), findsOneWidget);
    expect(find.text('Allergy: Penicillin (anaphylaxis)'), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Initial state: no medicines listed before searching
    expect(find.text('3 results'), findsNothing);
    expect(find.text('Paracetamol tablet'), findsNothing);

    // Searching displays matching clean medicine names, but NO repeat card because no medicine is previously selected
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'paracetamol',
    );
    await tester.pumpAndSettle();

    expect(find.text('3 results'), findsOneWidget);
    expect(find.text('Paracetamol tablet'), findsOneWidget);
    expect(find.text('Paracetamol syrup'), findsOneWidget);
    expect(find.text('Paracetamol suspension'), findsOneWidget);
    expect(find.text('Repeat previous prescription'), findsNothing);
    expect(find.text('Select'), findsWidgets);
    expect(find.text('Repeat'), findsNothing);

    // Tap Select on the first medicine -> advances directly to Step 2 details form
    await tester.tap(find.text('Select').first);
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2 · Prescription details'), findsOneWidget);
    expect(find.text('Medicine name'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Dose'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text('Instructions for patient'), findsOneWidget);
    expect(find.text('Repeat previous prescription (14 Aug 2026)'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Add to Prescription'), findsOneWidget);

    // Tap Back returns to Step 1
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);

    // Tap Select again to go to Step 2
    await tester.tap(find.text('Select').first);
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2 · Prescription details'), findsOneWidget);

    // Background is STILL visible in widget tree
    expect(find.text('Consultation'), findsOneWidget);

    // Tap Add to Prescription opens Prescription Review screen
    await tester.tap(find.text('Add to Prescription'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2 · Find a medicine'), findsNothing);
    expect(find.text('Step 2 of 2 · Prescription details'), findsNothing);
    expect(find.text('Review before sending'), findsOneWidget);
    expect(find.text('Rx-2026-10427-03'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Add another medicine'), findsOneWidget);
    expect(find.text('Send to despensing'), findsOneWidget);

    // Tap Add another medicine: allows adding another medicine!
    await tester.tap(find.text('Add another medicine'));
    await tester.pumpAndSettle();

    // Now in Step 1 again to find a medicine
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);

    // Searching paracetamol (which was added above) MUST now show repeat card!
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'paracetamol',
    );
    await tester.pumpAndSettle();

    expect(find.text('Repeat previous prescription'), findsOneWidget);
    expect(find.text('Paracetamol tablet · 14 Aug 2026'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);

    // Searching a medicine NOT added before (e.g. metformin) must NOT show repeat option
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'metformin',
    );
    await tester.pumpAndSettle();
    expect(find.text('Repeat previous prescription'), findsNothing);
    expect(find.text('Repeat'), findsNothing);

    // Re-enter paracetamol
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'paracetamol',
    );
    await tester.pumpAndSettle();

    // Tap Repeat advances to Step 2 with repeated medicine!
    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2 · Prescription details'), findsOneWidget);

    // Add to Prescription returns to review screen
    await tester.tap(find.text('Add to Prescription'));
    await tester.pumpAndSettle();
    expect(find.text('Review before sending'), findsOneWidget);

    // Review screen has remove cross button for each medicine
    expect(find.byTooltip('Remove medicine'), findsNWidgets(2));

    // Tap Remove medicine removes one card
    await tester.tap(find.byTooltip('Remove medicine').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove medicine'), findsOneWidget);

    // Tap Remove on the remaining medicine card reverts back to Step 1 search
    await tester.tap(find.byTooltip('Remove medicine'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);

    // Searching paracetamol now MUST NOT show repeat card because it was removed!
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'paracetamol',
    );
    await tester.pumpAndSettle();
    expect(find.text('Repeat previous prescription'), findsNothing);
    expect(find.text('Repeat'), findsNothing);

    // Re-select medicine to advance to review step and test Send to dispensing dialog
    await tester.tap(find.text('Select').first);
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2 · Prescription details'), findsOneWidget);

    await tester.tap(find.text('Add to Prescription'));
    await tester.pumpAndSettle();
    expect(find.text('Review before sending'), findsOneWidget);
    expect(find.text('Send to despensing'), findsOneWidget);

    // Tap Send to despensing shows Sent to dispensing confirmation dialog over Consultation
    await tester.tap(find.text('Send to despensing'));
    await tester.pumpAndSettle();

    expect(find.text('Sent to dispensing'), findsOneWidget);
    expect(find.text('Awaiting dispensing'), findsOneWidget);
    expect(
      find.text(
        'Rx-2026-10427-03 is in the dispensing queue. Dispensing staff will update the status once medicines are issued.',
      ),
      findsOneWidget,
    );
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('Return to consultation'), findsOneWidget);
    expect(find.text('Consultation'), findsOneWidget);

    // Tap Return to consultation dismisses modal and keeps doctor in Consultation
    await tester.tap(find.text('Return to consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Sent to dispensing'), findsNothing);
    expect(find.text('Consultation'), findsOneWidget);
  });

  testWidgets('Clicking Add prescription opens bottom sheet on mobile preserving consultation background', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultation'), findsOneWidget);

    // Scroll to and tap Add prescription
    await tester.ensureVisible(find.text('Add prescription'));
    await tester.tap(find.text('Add prescription'));
    await tester.pumpAndSettle();

    // Bottom sheet is now open
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);
    expect(find.text('Search Medicines'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Search medicine to find results
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'paracetamol',
    );
    await tester.pumpAndSettle();

    // Select medicine to advance to Step 2
    await tester.tap(find.text('Select').first);
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2 · Prescription details'), findsOneWidget);

    // Add to Prescription opens Review screen
    await tester.tap(find.text('Add to Prescription'));
    await tester.pumpAndSettle();
    expect(find.text('Review before sending'), findsOneWidget);
    expect(find.text('Send to despensing'), findsOneWidget);

    // Tap Send to despensing shows mobile bottom sheet confirmation over Consultation
    await tester.tap(find.text('Send to despensing'));
    await tester.pumpAndSettle();

    expect(find.text('Sent to dispensing'), findsOneWidget);
    expect(find.text('Awaiting dispensing'), findsOneWidget);
    expect(find.text('Return to consultation'), findsOneWidget);
    expect(find.text('Consultation'), findsOneWidget);

    // Tap Return to consultation dismisses sheet
    await tester.tap(find.text('Return to consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Sent to dispensing'), findsNothing);
    expect(find.text('Consultation'), findsOneWidget);
  });

  testWidgets('Clicking Add prescription on tablet opens dedicated page without bottom nav bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultation'), findsOneWidget);

    // Scroll to and tap Add prescription
    await tester.ensureVisible(find.text('Add prescription'));
    await tester.tap(find.text('Add prescription'));
    await tester.pumpAndSettle();

    // Dedicated tablet page is open
    expect(find.text('Add prescription'), findsWidgets);
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);
    expect(find.text('Search Medicines'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Bottom navigation bar is NOT present
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Patients'), findsNothing);

    // Searching displays clean medicine names, repeat card is hidden until medicine was selected
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Medicines'),
      'paracetamol',
    );
    await tester.pumpAndSettle();

    expect(find.text('3 results'), findsOneWidget);
    expect(find.text('Paracetamol tablet'), findsOneWidget);
    expect(find.text('Repeat previous prescription'), findsNothing);
    expect(find.text('Repeat'), findsNothing);

    // Tap Select on tablet opens Step 2 details form
    await tester.tap(find.text('Select').first);
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2 · Prescription details'), findsOneWidget);
    expect(find.text('Add to Prescription'), findsOneWidget);

    // Add to Prescription opens review
    await tester.tap(find.text('Add to Prescription'));
    await tester.pumpAndSettle();
    expect(find.text('Review before sending'), findsOneWidget);
    expect(find.text('Send to despensing'), findsOneWidget);

    // Tap Send to despensing pops tablet page and shows centered confirmation dialog over Consultation
    await tester.tap(find.text('Send to despensing'));
    await tester.pumpAndSettle();

    expect(find.text('Sent to dispensing'), findsOneWidget);
    expect(find.text('Awaiting dispensing'), findsOneWidget);
    expect(find.text('Return to consultation'), findsOneWidget);
    expect(find.text('Consultation'), findsOneWidget);

    // Tap Return to consultation dismisses dialog and leaves doctor on Consultation
    await tester.tap(find.text('Return to consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Sent to dispensing'), findsNothing);
    expect(find.text('Consultation'), findsOneWidget);
  });

  testWidgets('Dedicated tablet prescription page at narrow width does not overflow header', (tester) async {
    tester.view.physicalSize = const Size(520, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(
          body: AddPrescriptionTabletPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TabletHeader), findsOneWidget);
    expect(find.text('Add prescription'), findsWidgets);
    expect(find.text('Step 1 of 2 · Find a medicine'), findsOneWidget);
  });

  testWidgets('Clicking Lab referral opens slide drawer on desktop with form fields and Send Refferal', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lab referral'), findsOneWidget);
    await tester.ensureVisible(find.text('Lab referral'));
    await tester.tap(find.text('Lab referral'));
    await tester.pumpAndSettle();

    // Drawer is open
    expect(find.text('Request tests for this consultation'), findsOneWidget);
    expect(find.text('Laboratory'), findsOneWidget);
    expect(find.text('Soweto NHLS Laboratory'), findsOneWidget);
    expect(find.text('Search tests'), findsOneWidget);
    expect(find.text('Selected tests'), findsOneWidget);
    expect(find.text('Full blood count'), findsWidgets);
    expect(find.text('Urgency'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Specimen'), findsOneWidget);
    expect(find.text('Blood · venous'), findsOneWidget);
    expect(find.text('Clinical notes'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Send Refferal'), findsOneWidget);

    // Tap Send Refferal closes drawer
    await tester.tap(find.text('Send Refferal'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Request tests for this consultation'), findsNothing);
  });

  testWidgets('Clicking Lab referral opens bottom sheet on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Lab referral'));
    await tester.tap(find.text('Lab referral'));
    await tester.pumpAndSettle();

    expect(find.text('Request tests for this consultation'), findsOneWidget);
    expect(find.text('Selected tests'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Send Refferal'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Request tests for this consultation'), findsNothing);
  });

  testWidgets('Clicking Lab referral on tablet opens dedicated page without bottom nav bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Lab referral'));
    await tester.tap(find.text('Lab referral'));
    await tester.pumpAndSettle();

    expect(find.text('Request tests for this consultation'), findsOneWidget);
    expect(find.text('Selected tests'), findsOneWidget);
    // Tablet bottom navigation is hidden
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Patients'), findsNothing);

    await tester.tap(find.text('Send Refferal'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Request tests for this consultation'), findsNothing);
  });

  testWidgets('Clicking Sick note / Letter opens slide drawer on desktop with preview and Finalise', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sick note / Letter'), findsOneWidget);
    await tester.ensureVisible(find.text('Sick note / Letter'));
    await tester.tap(find.text('Sick note / Letter'));
    await tester.pumpAndSettle();

    // Drawer is open
    expect(find.text('Step 1 of 2 · Choose a template and review'), findsOneWidget);
    expect(find.text('Template'), findsOneWidget);
    expect(find.text('Sick note (medical certificate)'), findsWidgets);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Medical certificate'), findsOneWidget);
    expect(find.text('Soweto Community Health Centre'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Finalise'), findsOneWidget);

    // Tap Finalise closes drawer
    await tester.tap(find.text('Finalise'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Step 1 of 2 · Choose a template and review'), findsNothing);
  });

  testWidgets('Clicking Sick note / Letter opens bottom sheet on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sick note / Letter'));
    await tester.tap(find.text('Sick note / Letter'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2 · Choose a template and review'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Finalise'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Step 1 of 2 · Choose a template and review'), findsNothing);
  });

  testWidgets('Clicking Sick note / Letter on tablet opens dedicated page without bottom nav bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sick note / Letter'));
    await tester.tap(find.text('Sick note / Letter'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2 · Choose a template and review'), findsOneWidget);
    // Tablet bottom navigation is hidden
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Patients'), findsNothing);

    await tester.tap(find.text('Finalise'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Step 1 of 2 · Choose a template and review'), findsNothing);
  });

  testWidgets('Clicking Attachments opens slide drawer on desktop with dropzone, files and Done', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Attachments'), findsOneWidget);
    await tester.ensureVisible(find.text('Attachments'));
    await tester.tap(find.text('Attachments'));
    await tester.pumpAndSettle();

    // Drawer is open
    expect(find.text('Files linked to this consultation'), findsOneWidget);
    expect(find.text('Drag files here or browse'), findsOneWidget);
    expect(find.text('Attached files (2)'), findsOneWidget);
    expect(find.text('ECG_15Oct2026.pdf'), findsOneWidget);
    expect(find.text('Headache_diary_Oct.pdf'), findsOneWidget);
    expect(find.text('Files can be removed until the consultation is signed off.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done closes drawer
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Files linked to this consultation'), findsNothing);
  });

  testWidgets('Clicking Attachments opens bottom sheet on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Attachments'));
    await tester.tap(find.text('Attachments'));
    await tester.pumpAndSettle();

    expect(find.text('Files linked to this consultation'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Files linked to this consultation'), findsNothing);
  });

  testWidgets('Clicking Attachments on tablet opens dedicated page without bottom nav bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Attachments'));
    await tester.tap(find.text('Attachments'));
    await tester.pumpAndSettle();

    expect(find.text('Files linked to this consultation'), findsOneWidget);
    // Tablet bottom navigation is hidden
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Patients'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Files linked to this consultation'), findsNothing);
  });

  testWidgets('Clicking Review consultation opens review screen on desktop with sections and no warning', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review consultation'), findsOneWidget);
    await tester.ensureVisible(find.text('Review consultation'));
    await tester.tap(find.text('Review consultation'));
    await tester.pumpAndSettle();

    // Review page is visible
    expect(find.text('Ready for sign-off'), findsOneWidget);
    expect(find.text('Check each section before signing off. Signed records cannot be edited.'), findsOneWidget);
    // Critical alert is removed on desktop matching design
    expect(find.text('CRITICAL ALERT · Allergy: Penicillin (anaphylaxis)'), findsNothing);

    // Section cards
    expect(find.textContaining('Presenting complaint'), findsOneWidget);
    expect(find.textContaining('Vitals'), findsOneWidget);
    expect(find.textContaining('Medical history'), findsOneWidget);
    expect(find.textContaining('Examination'), findsOneWidget);
    expect(find.textContaining('Diagnosis'), findsOneWidget);
    expect(find.textContaining('Treatment plan'), findsOneWidget);
    expect(find.textContaining('Prescription'), findsOneWidget);
    expect(find.textContaining('Lab referral, letters & attachments'), findsOneWidget);

    // Bottom actions
    await tester.ensureVisible(find.text('All required sections complete'));
    expect(find.text('All required sections complete'), findsOneWidget);
    expect(find.text('Back to consultation'), findsOneWidget);
    expect(find.text('Sign Off Consultation'), findsOneWidget);

    // Back to consultation works
    await tester.tap(find.text('Back to consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for sign-off'), findsNothing);
  });

  testWidgets('Review consultation on mobile renders full page without bottom sheet or bottom nav', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Review consultation'));
    await tester.tap(find.text('Review consultation'));
    await tester.pumpAndSettle();

    expect(find.text('Ready for sign-off'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Patients'), findsNothing);
    expect(find.text('CRITICAL ALERT · Allergy: Penicillin (anaphylaxis)'), findsNothing);

    // Patient card and section cards
    expect(find.text('Reason for visit'), findsOneWidget);
    expect(find.text('Follow-up'), findsNWidgets(2));
    expect(find.textContaining('Presenting complaint'), findsOneWidget);
    expect(find.textContaining('Vitals'), findsOneWidget);

    await tester.ensureVisible(find.text('Back to consultation'));
    await tester.tap(find.text('Back to consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for sign-off'), findsNothing);
  });

  testWidgets('Review consultation on tablet renders full page without bottom nav and can sign off', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Review consultation'));
    await tester.tap(find.text('Review consultation'));
    await tester.pumpAndSettle();

    expect(find.text('Ready for sign-off'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Patients'), findsNothing);
    expect(find.text('CRITICAL ALERT · Allergy: Penicillin (anaphylaxis)'), findsNothing);

    // Patient card and section cards
    expect(find.text('Reason for visit'), findsOneWidget);
    expect(find.text('Follow-up'), findsNWidgets(2));
    expect(find.textContaining('Presenting complaint'), findsOneWidget);
    expect(find.textContaining('Vitals'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign Off Consultation'));
    await tester.tap(find.text('Sign Off Consultation'));
    await tester.pumpAndSettle();

    // Verify Sign off confirmation page is opened on tablet
    expect(find.text('Confirm to finalise the record'), findsOneWidget);
    expect(find.text('This record will be finalised'), findsOneWidget);
    expect(find.text('I confirm this record is accurate and complete'), findsOneWidget);

    // Confirm sign off via Done button
    await tester.ensureVisible(find.text('Done'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify Consultation completed dialog appears on tablet
    expect(find.text('Consultation completed'), findsOneWidget);
    expect(find.text('View finalised record'), findsOneWidget);
    expect(find.text('Return to Queue'), findsOneWidget);

    // Return to queue dismisses dialog and leaves review mode
    await tester.tap(find.text('Return to Queue'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for sign-off'), findsNothing);
  });

  testWidgets('Clicking Sign Off Consultation on desktop opens slide drawer with confirmation and completed dialog', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Review consultation'));
    await tester.tap(find.text('Review consultation'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign Off Consultation'));
    await tester.tap(find.text('Sign Off Consultation'));
    await tester.pumpAndSettle();

    // Drawer is opened
    expect(find.text('Sign off consultation'), findsOneWidget);
    expect(find.text('Confirm to finalise the record'), findsOneWidget);
    expect(find.text('This record will be finalised'), findsOneWidget);
    expect(find.text('I confirm this record is accurate and complete'), findsOneWidget);
    expect(find.text('Cancel / Return to review'), findsOneWidget);
    expect(find.text('Confirm Sign Off'), findsOneWidget);

    // Confirm Sign Off opens Consultation completed dialog on desktop
    await tester.tap(find.text('Confirm Sign Off'));
    await tester.pumpAndSettle();

    expect(find.text('Consultation completed'), findsOneWidget);
    expect(find.text('View finalised record'), findsOneWidget);
    expect(find.text('Return to Queue'), findsOneWidget);

    // Click Return to Queue to exit
    await tester.tap(find.text('Return to Queue'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for sign-off'), findsNothing);
  });

  testWidgets('Clicking Sign Off Consultation on mobile opens bottom sheet with confirmation and completed bottomsheet', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.consultationWorkspace,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Review consultation'));
    await tester.tap(find.text('Review consultation'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign Off Consultation'));
    await tester.tap(find.text('Sign Off Consultation'));
    await tester.pumpAndSettle();

    // Bottom sheet is opened
    expect(find.text('Confirm to finalise the record'), findsOneWidget);
    expect(find.text('This record will be finalised'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Confirm via Done opens mobile Consultation completed bottom sheet
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Consultation completed'), findsOneWidget);
    expect(find.text('View Finalized Record'), findsOneWidget);
    expect(find.text('Return to queue'), findsOneWidget);

    // Return to queue exits review mode
    await tester.tap(find.text('Return to queue'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for sign-off'), findsNothing);
  });
}
