import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/patients/controllers/patient_front_desk_preview_controller.dart';
import 'package:tendryn/features/patients/views/patient_front_desk_preview_view.dart';
import 'package:tendryn/models/user.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/dashboard_service.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';

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
    return const User(
      id: '1',
      name: 'Lerato Mokoena',
      email: 'lerato@example.com',
      role: UserRole.member,
      jobTitle: 'Reception',
      clinicName: 'Ubuntu Family Clinic',
    );
  }
  @override
  Future<void> logout() async {}
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

void main() {
  setUp(() {
    Get.reset();
    Get.put<AuthController>(_FakeAuthController());
    Get.put<DashboardService>(_FakeDashboardService());
    Get.put<ConnectivityService>(_FakeConnectivityService());
    Get.put<DashboardController>(DashboardController(
      service: Get.find<DashboardService>(),
      auth: Get.find<AuthController>(),
    ));
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget() {
    return GetMaterialApp(
      theme: AppTheme.light(),
      home: const PatientFrontDeskPreviewView(),
    );
  }

  testWidgets('desktop: renders desktop drawer layout with header, cards, and buttons', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    addTearDown(() => ResponsiveHelper.debugIsDesktopPlatformOverride = null);
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientFrontDeskPreviewController>(PatientFrontDeskPreviewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Patient Name and File number
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('File #PT-002184'), findsOneWidget);

    // Verify Badges
    expect(find.text('Front desk view'), findsOneWidget);
    expect(find.text('WhatsApp Active'), findsOneWidget);

    // Verify Details card fields
    expect(find.text('Date of birth / age'), findsOneWidget);
    expect(find.text('12 Mar 1982 · 44 years'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('082 ••• ••42'), findsOneWidget);
    expect(find.text('File number'), findsOneWidget);
    expect(find.text('PT-002184'), findsOneWidget);

    // Verify Recent front desk activity
    expect(find.text('Recent front desk activity'), findsOneWidget);
    expect(find.text('Last visit 14 Aug 2026 · No outstanding front desk tasks'), findsOneWidget);

    // Verify View Patient button
    expect(find.text('View Patient'), findsOneWidget);
    expect(find.text('Opens the existing receptionist Patient Profile.'), findsOneWidget);

    // Verify Sticky bottom actions on drawer
    final drawer = find.byType(PatientFrontDeskPreviewDrawer);
    expect(find.descendant(of: drawer, matching: find.text('Add to Queue')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Book Appointment')), findsOneWidget);

    // Close button exists
    expect(find.byKey(const Key('front_desk_preview_close_button')), findsOneWidget);
  });

  testWidgets('tablet: renders tablet header, back button, details, and sticky actions (no bottom nav)', (tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientFrontDeskPreviewController>(PatientFrontDeskPreviewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tablet renders tablet header
    expect(find.text('Tendryn · Reception'), findsOneWidget);

    // Back button and header
    expect(find.byKey(const Key('front_desk_preview_back_button')), findsOneWidget);
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('File #PT-002184'), findsOneWidget);

    // Badges and card
    expect(find.text('Front desk view'), findsOneWidget);
    expect(find.text('WhatsApp Active'), findsOneWidget);
    expect(find.text('12 Mar 1982 · 44 years'), findsOneWidget);

    // Sticky buttons are present; bottom navigation bar is removed
    expect(find.text('Add to Queue'), findsOneWidget);
    expect(find.text('Book Appointment'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
  });

  testWidgets('mobile: renders mobile back button, content, and sticky actions (no bottom nav)', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Get.put<PatientFrontDeskPreviewController>(PatientFrontDeskPreviewController());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Mobile header with back button
    expect(find.byKey(const Key('front_desk_preview_back_button')), findsOneWidget);
    expect(find.text('Thabo Nkosi'), findsOneWidget);
    expect(find.text('File #PT-002184'), findsOneWidget);

    // Details and actions
    expect(find.text('Front desk view'), findsOneWidget);
    expect(find.text('12 Mar 1982 · 44 years'), findsOneWidget);
    expect(find.text('Add to Queue'), findsOneWidget);
    expect(find.text('Book Appointment'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
  });
}
