import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/features/appointments/views/appointment_details_view.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/patients/controllers/patient_quick_view_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/patients/views/patient_quick_view.dart';
import 'package:tendryn/features/patients/widgets/assign_practitioner_dropdown.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/views/patients_view.dart';
import 'package:tendryn/features/queue/controllers/add_walk_in_controller.dart';
import 'package:tendryn/features/queue/views/add_walk_in_view.dart';
import 'package:tendryn/services/dashboard_service.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/models/user.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/features/queue/models/queue_model.dart';
import 'package:tendryn/routes/app_pages.dart';
import 'package:tendryn/services/queue_service.dart';

class _FakeAuthController extends GetxController implements AuthController {
  final _dummyObs = true.obs;
  @override
  bool get isAuthenticated {
    _dummyObs.value;
    return true;
  }
  @override
  User? get user {
    _dummyObs.value;
    return const User(id: '1', name: 'Lerato Mokoena', email: 'lerato@example.com', role: UserRole.member, jobTitle: 'Reception', clinicName: 'Ubuntu Family Clinic');
  }
  @override
  Future<void> logout() async {}
  // no-op implementation of other required methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDashboardService extends GetxService implements DashboardService {
  @override
  Future<DashboardModel> fetchSummary() async => DashboardModel(
                patientsWaiting: 4,
        seenToday: 12,
        averageWaitMinutes: 25,
        takingsToday: 1540.50,
        queue: [],
        appointments: AppointmentsSummary(booked: 0, remaining: 0, noShows: 0, items: []),
        attention: [],
      );
}

class _FakeConnectivityService extends GetxService implements ConnectivityService {
  @override
  RxBool get isOnline => true.obs;
}

const _flowEntries = [
  QueueEntry(
    number: 'Q-01',
    patient: 'Thabo Nkosi',
    arrival: '08:30',
    waitingMinutes: 20,
    reason: 'Check-up',
    priority: QueuePriority.routine,
    status: QueueStatus.waiting,
  ),
];

class _FlowQueueService extends GetxService implements QueueService {
  @override
  Future<QueueModel> fetchQueue({required DateTime date}) async => const QueueModel(
        patientsWaiting: 1,
        seenToday: 0,
        averageWaitMinutes: 20,
        entries: _flowEntries,
      );
}

class _FlowDashboardService extends GetxService implements DashboardService {
  @override
  Future<DashboardModel> fetchSummary() async => DashboardModel(
        patientsWaiting: 1,
        seenToday: 0,
        averageWaitMinutes: 20,
        takingsToday: 0,
        queue: _flowEntries,
        appointments: AppointmentsSummary(booked: 0, remaining: 0, noShows: 0, items: []),
        attention: [],
      );
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<AuthController>(_FakeAuthController());
    Get.put<DashboardService>(_FakeDashboardService());
    Get.put<ConnectivityService>(_FakeConnectivityService());
    Get.put<DashboardController>(DashboardController(service: Get.find<DashboardService>(), auth: Get.find<AuthController>()));
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget() {
    return GetMaterialApp(
      theme: AppTheme.light(),
      home: const PatientQuickView(),
    );
  }

  test('PatientQuickViewModel has correct prototype data for Thabo Nkosi', () {
    const p = PatientQuickViewModel.thaboNkosi;
    expect(p.name, 'Thabo Nkosi');
    expect(p.fileNumber, '#PT-002184');
    expect(p.phone, '082 ••• ••42');
    expect(p.dobAndAge, '12 Mar 1982 · 44 years');
    expect(p.queueNumber, 'Q014');
    expect(p.arrivedTime, '09:10');
    expect(p.waitingDuration, '24 min');
    expect(p.visitReason, 'General consultation');
    expect(p.priority, 'Routine');
    expect(p.status, 'Waiting');
    expect(p.practitioner, 'Not assigned');
    expect(p.whatsAppStatus, 'Active');
  });

  testWidgets('desktop: renders mobile full-page layout', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientQuickViewController>(PatientQuickViewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify it renders the mobile header
    expect(find.byKey(const Key('quick_view_back_button')), findsOneWidget);
    expect(find.text('Patient Quick View'), findsOneWidget);

    // Verify overlay no longer exists
    expect(find.byKey(const Key('quick_view_overlay')), findsNothing);

    // Verify patient information card
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('File #PT-002184 · 082 ••• ••42'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Manage Queue'), findsOneWidget);
    expect(find.text('Assign Practitioner'), findsOneWidget);
  });

  testWidgets('tablet: renders mobile full-page layout', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientQuickViewController>(PatientQuickViewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tablet renders tablet header
    expect(find.text('Tendryn · Reception'), findsOneWidget);

    // Subheader with back button and title
    expect(find.byKey(const Key('quick_view_back_button')), findsOneWidget);
    expect(find.text('Patient Quick View'), findsOneWidget);

    // Patient card and details
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('12 Mar 1982 · 44 years'), findsOneWidget);
    expect(find.text('Manage Queue'), findsOneWidget);
    expect(find.text('Assign Practitioner'), findsOneWidget);

    // Bottom navigation removed
    expect(find.byType(AppBottomNavigation), findsNothing);

    // No desktop drawer overlay
    expect(find.byKey(const Key('quick_view_overlay')), findsNothing);
  });

  testWidgets('mobile: renders mobile full-page layout', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientQuickViewController>(PatientQuickViewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Mobile header with back button and title
    expect(find.byKey(const Key('quick_view_back_button')), findsOneWidget);
    expect(find.text('Patient Quick View'), findsOneWidget);

    // Patient card and details
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('File #PT-002184 · 082 ••• ••42'), findsOneWidget);
    expect(find.text('12 Mar 1982 · 44 years'), findsOneWidget);

    // Action buttons
    expect(find.text('Manage Queue'), findsOneWidget);
    expect(find.text('Assign Practitioner'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);

    // No desktop overlay
    expect(find.byKey(const Key('quick_view_overlay')), findsNothing);
  });

  testWidgets('responsive: automatically switches layout on window resize', (tester) async {
    // Start at desktop width
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientQuickViewController>(PatientQuickViewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick_view_overlay')), findsNothing);
    expect(find.byKey(const Key('quick_view_back_button')), findsOneWidget);

    // Resize to tablet
    tester.view.physicalSize = const Size(800, 1024);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick_view_overlay')), findsNothing);
    expect(find.text('Tendryn · Reception'), findsOneWidget);

    // Resize to mobile
    tester.view.physicalSize = const Size(393, 852);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick_view_overlay')), findsNothing);
    expect(find.text('Tendryn · Reception'), findsNothing);
    expect(find.byKey(const Key('quick_view_back_button')), findsOneWidget);
  });

  testWidgets('actions: Manage Queue and Assign Practitioner buttons trigger correctly', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PatientQuickViewController();
    Get.put<PatientQuickViewController>(controller);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Manage Queue'), findsOneWidget);
    expect(find.text('Assign Practitioner'), findsOneWidget);

    await tester.tap(find.text('Manage Queue'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('Assign Practitioner'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Thabo Nkosi'), findsOneWidget);
  });

  test('PatientQuickViewModel.fromQueueEntry populates fields correctly', () {
    const entry = QueueEntry(
      number: 'Q042',
      patient: 'Ayanda Dlamini',
      arrival: '10:15',
      waitingMinutes: 15,
      reason: 'Fever and cough',
      priority: QueuePriority.urgent,
      status: QueueStatus.waiting,
    );
    final vm = PatientQuickViewModel.fromQueueEntry(entry);
    expect(vm.name, 'Ayanda Dlamini');
    expect(vm.queueNumber, 'Q042');
    expect(vm.fileNumber, '#PT-0042');
    expect(vm.arrivedTime, '10:15');
    expect(vm.waitingDuration, '15 min');
    expect(vm.visitReason, 'Fever and cough');
    expect(vm.priority, 'Urgent');
    expect(vm.status, 'Waiting');
    expect(vm.practitioner, 'Not assigned');
  });

  test('PatientQuickViewController handles returnRoute correctly', () {
    final controller = PatientQuickViewController(
      returnRoute: AppRoutes.queue,
      startInAssignMode: true,
    );
    expect(controller.returnRoute, AppRoutes.queue);
    expect(controller.isAssignMode.value, isTrue);
    expect(controller.isDropdownVisible.value, isTrue);

    controller.selectPractitioner('Dr Sipho Khumalo');
    expect(controller.selectedPractitioner.value, 'Dr Sipho Khumalo');
  });

  test('AddWalkInController handles returnRoute correctly', () {
    final defaultController = AddWalkInController();
    expect(defaultController.returnRoute, AppRoutes.queue);

    final dashboardController = AddWalkInController(returnRoute: AppRoutes.dashboard);
    expect(dashboardController.returnRoute, AppRoutes.dashboard);
  });

  test('AppointmentDetailsModel.fromEntry maps correctly', () {
    const entry = AppointmentEntry(
      time: '14:00',
      patient: 'Lindiwe Ndlovu',
      practitioner: 'Dr Thandi Maseko',
      visitType: 'Follow-up',
      status: AppointmentStatus.checkedIn,
    );
    final details = AppointmentDetailsModel.fromEntry(entry);
    expect(details.patient, 'Lindiwe Ndlovu');
    expect(details.time, '14:00');
    expect(details.practitioner, 'Dr Thandi Maseko');
    expect(details.visitType, 'Follow-up');
    expect(details.status, 'Checked In');
    expect(details.arrival, '13:52');
  });

  test('AppointmentDetailsController initializes with mock data', () {
    final controller = AppointmentDetailsController();
    expect(controller.details.value.patient, 'Lindiwe Ndlovu');
    expect(controller.details.value.status, 'Checked In');
    expect(controller.details.value.time, '14:00');
  });

  test('PatientQuickViewModel.forPatient creates valid model', () {
    final p = PatientQuickViewModel.forPatient(name: 'Lindiwe Ndlovu');
    expect(p.name, 'Lindiwe Ndlovu');
    expect(p.fileNumber, '#PT-001746');
    expect(p.phone, '083 ••• ••18');
  });

  test('AddWalkInController searches Thabo Nkosi and Thabo Mokoena or handles not found', () {
    final controller = AddWalkInController();
    expect(controller.results.length, 2);
    expect(controller.results.map((p) => p.name).toList(), containsAll(['Thabo Nkosi', 'Thabo Mokoena']));

    controller.search('Nkosi');
    expect(controller.results.length, 1);
    expect(controller.results.first.name, 'Thabo Nkosi');

    controller.search('Thabo Zondi');
    expect(controller.results, isEmpty);

    controller.onRegisterNewPatient();
  });

  testWidgets('AddWalkInView shows Thabo Nkosi and Thabo Mokoena on match, and No Patient Found on miss', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put(AddWalkInController());

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const AddWalkInView(),
      ),
    );
    await tester.pumpAndSettle();

    // With initial query "Thabo", both patients are visible
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('No patient found'), findsNothing);

    // Search for non-existent patient
    await tester.enterText(find.byType(TextField).first, 'Thabo Zondi');
    await tester.pumpAndSettle();

    // Now empty state is displayed
    expect(find.text('Thabo Nkosi'), findsNothing);
    expect(find.text('Thabo Mokoena'), findsNothing);
    expect(find.text('No patient found'), findsOneWidget);
    expect(find.text('Check the search details or register a new patient.'), findsOneWidget);
    expect(find.text('Register New Patient'), findsOneWidget);

    // Tap Register New Patient
    await tester.tap(find.text('Register New Patient'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('PatientsDesktop renders without stack overflow', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put(PatientsController());

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const PatientsView(),
      ),
    );
    await tester.pumpAndSettle();
  });

  group('Dashboard/Queue popup actions: drawer on desktop OS only', () {
    final cases = <(TargetPlatform, Size, bool)>[
      (TargetPlatform.windows, const Size(1400, 900), true),
      (TargetPlatform.windows, const Size(1280, 800), true),
      (TargetPlatform.windows, const Size(1000, 700), false),
      (TargetPlatform.android, const Size(1280, 800), false),
      (TargetPlatform.android, const Size(1000, 700), false),
      (TargetPlatform.android, const Size(800, 1280), false),
      (TargetPlatform.android, const Size(393, 852), false),
    ];
    for (final (platform, size, drawer) in cases) {
      for (final from in [AppRoutes.queue, AppRoutes.dashboard]) {
        for (final assign in [false, true]) {
          testWidgets('$platform $size from $from ${assign ? 'assign' : 'view'} -> ${drawer ? 'drawer' : 'page'}', (tester) async {
            SharedPreferences.setMockInitialValues({});
            debugDefaultTargetPlatformOverride = platform;
            Get.reset();
            Get.put<AuthController>(_FakeAuthController());
            Get.put<ConnectivityService>(_FakeConnectivityService());
            Get.put(RoleController());
            Get.put<DashboardService>(_FlowDashboardService());
            Get.put<QueueService>(_FlowQueueService());
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            try {
              await tester.pumpWidget(GetMaterialApp(theme: AppTheme.light(), initialRoute: from, getPages: AppPages.pages));
              await tester.pumpAndSettle();
              await tester.scrollUntilVisible(find.byTooltip('Queue actions'), 200, scrollable: find.byType(Scrollable).first);
              await tester.tap(find.byTooltip('Queue actions'));
              await tester.pumpAndSettle();
              await tester.tap(find.text(assign ? 'Assign Practitioner' : 'View Patient').last);
              await tester.pumpAndSettle();

              expect(find.byType(PatientQuickViewDrawer), drawer ? findsOneWidget : findsNothing);
              expect(Get.currentRoute, drawer ? from : AppRoutes.patientQuickView);
              final controller = Get.find<PatientQuickViewController>();
              expect(controller.patient.value.name, 'Thabo Nkosi');
              expect(controller.isAssignMode.value, assign);
              expect(controller.isDropdownVisible.value, assign);
              expect(find.byType(AssignPractitionerDropdown), assign ? findsOneWidget : findsNothing);
              expect(tester.takeException(), isNull);
            } finally {
              debugDefaultTargetPlatformOverride = null;
            }
          });
        }
      }
    }
  });

  group('tablet page layout', () {
    for (final size in const [Size(800, 1280), Size(1000, 700), Size(900, 600), Size(1280, 800)]) {
      testWidgets('assign mode keeps body and practitioner list usable at $size', (tester) async {
        Get.put(PatientQuickViewController(startInAssignMode: true));
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Regression: a bare Center in bottomNavigationBar once filled the
        // whole screen and left the scrollable body 0px tall.
        expect(tester.getSize(find.byType(SingleChildScrollView)).height, greaterThan(200));

        // Uses the full tablet width with Billing's 24px side padding, not a capped column.
        expect(tester.getSize(find.byType(SingleChildScrollView)).width, size.width);
        expect(tester.getRect(find.text('Thabo Nkosi').first).left, 24 + Dimensions.spaceMd + 2);
        expect(tester.getRect(find.byType(AssignPractitionerDropdown)).width, size.width - 48);

        final dropdown = find.byType(AssignPractitionerDropdown);
        final buttons = find.text('Save Assignment');
        expect(tester.getRect(dropdown).bottom, lessThanOrEqualTo(tester.getRect(buttons).top));

        await tester.tap(find.descendant(of: dropdown, matching: find.text('Not assigned')));
        await tester.pumpAndSettle();
        final last = find.descendant(of: dropdown, matching: find.text('Nurse Z. Mthembu'));
        expect(last, findsOneWidget);
        expect(tester.getRect(last).bottom, lessThanOrEqualTo(tester.getRect(buttons).top));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
