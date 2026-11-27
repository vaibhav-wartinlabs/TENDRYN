import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/controllers/book_appointment_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/features/appointments/views/book_appointment_view.dart';
import 'package:tendryn/features/appointments/widgets/appointments_desktop.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
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
    appointments: const AppointmentsSummary(booked: 0, remaining: 0, noShows: 0, items: []),
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

  group('BookAppointmentController', () {
    test('initial state matches prototype specifications', () {
      final controller = BookAppointmentController();
      expect(controller.selectedPatient.value, isNull);
      expect(controller.selectedPractitioner.value, 'Select Practitioner');
      expect(controller.isPractitionerExpanded.value, isFalse);
      expect(controller.selectedSlot.value, '14:30');
      expect(controller.selectedVisitType.value, 'Consultation');
      expect(controller.selectedDate.value.day, 29);
      expect(controller.selectedDate.value.month, 9);
      expect(controller.selectedDate.value.year, 2026);
    });

    test('practitioner selection toggles and updates', () {
      final controller = BookAppointmentController();
      expect(controller.isPractitionerExpanded.value, isFalse);
      controller.togglePractitioner();
      expect(controller.isPractitionerExpanded.value, isTrue);

      controller.selectPractitioner('Dr Sipho Khumalo');
      expect(controller.selectedPractitioner.value, 'Dr Sipho Khumalo');
      expect(controller.isPractitionerExpanded.value, isFalse);
    });

    test('patient search filters and selection works', () {
      final controller = BookAppointmentController();
      controller.search('thabo');
      expect(controller.filteredPatients.isNotEmpty, isTrue);
      controller.selectPatient(controller.filteredPatients.first);
      expect(controller.selectedPatient.value?.name, 'Thabo Nkosi');
    });

    test('slot selection only selects available slots', () {
      final controller = BookAppointmentController();
      controller.selectSlot('09:00');
      expect(controller.selectedSlot.value, '09:00');

      // Unavailable slots cannot be selected
      controller.selectSlot('12:00');
      expect(controller.selectedSlot.value, '09:00');
    });

    test('visit type toggle updates correctly', () {
      final controller = BookAppointmentController();
      controller.selectVisitType('Follow-up');
      expect(controller.selectedVisitType.value, 'Follow-up');
    });

    test('date selection updates formatted string', () {
      final controller = BookAppointmentController();
      controller.selectDate(DateTime(2026, 9, 23));
      expect(controller.selectedDate.value.day, 23);
      expect(controller.formattedSlotHeaderDate, contains('23'));
    });
  });

  group('BookAppointmentView Widgets', () {
    Widget createTestWidget() {
      return GetMaterialApp(
        theme: AppTheme.light(),
        home: const BookAppointmentView(),
      );
    }

    testWidgets('mobile: renders book appointment screen without bottom navigation bar', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Get.put(BookAppointmentController(
        initialPatient: BookAppointmentController.mockPatients.first,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Heading and subtitle
      expect(find.text('Book Appointment'), findsWidgets);
      expect(find.text('Schedule a receptionist-managed visit.'), findsWidgets);

      // Patient card details
      expect(find.text('Thabo Nkosi'), findsWidgets);
      expect(find.textContaining('PT-002184'), findsOneWidget);

      // Practitioner
      expect(find.text('Select Practitioner'), findsWidgets);

      // Available slots and visit type
      expect(find.text('Available slots'), findsOneWidget);
      expect(find.text('14:30'), findsOneWidget);
      expect(find.text('Consultation'), findsOneWidget);
      expect(find.text('Follow-up'), findsOneWidget);

      // Actions at bottom
      expect(find.text('Cancel'), findsOneWidget);

      // CRITICAL REQUIREMENT: NO bottom navigation bar on mobile!
      expect(find.byType(AppBottomNavigation), findsNothing);
    });

    testWidgets('tablet: renders 2-column layout with header and no bottom navigation bar', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Get.put(BookAppointmentController(
        initialPatient: BookAppointmentController.mockPatients.first,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tablet Header
      expect(find.text('Tendryn · Reception'), findsOneWidget);
      expect(find.text('Ubuntu Family Clinic'), findsOneWidget);

      // Main content
      expect(find.text('Book Appointment'), findsWidgets);
      expect(find.text('Select Practitioner'), findsWidgets);
      expect(find.text('Available slots'), findsOneWidget);
      expect(find.text('Scheduling Notes (optional)'), findsOneWidget);

      // CRITICAL REQUIREMENT: NO bottom navigation bar on tablet!
      expect(find.byType(AppBottomNavigation), findsNothing);
    });

    testWidgets('desktop: opens drawer with cancel and book appointment buttons', (tester) async {
      ResponsiveHelper.debugIsDesktopPlatformOverride = true;
      addTearDown(() => ResponsiveHelper.debugIsDesktopPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Get.put(BookAppointmentController());

      await tester.pumpWidget(GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: BookAppointmentDrawer()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Book Appointment'), findsWidgets);
      expect(find.text('Schedule a receptionist-managed visit.'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Scheduling Notes (optional)'), findsOneWidget);
    });

    testWidgets('Appointments page desktop: clicking Book appointment opens BookAppointmentDrawer', (tester) async {
      ResponsiveHelper.debugIsDesktopPlatformOverride = true;
      addTearDown(() => ResponsiveHelper.debugIsDesktopPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final appointmentsController = Get.put(AppointmentsController());

      await tester.pumpWidget(GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AppointmentsDesktop()),
      ));
      await tester.pumpAndSettle();

      // Call bookAppointment from controller (as triggered by Book appointment button)
      appointmentsController.bookAppointment();
      await tester.pumpAndSettle();

      expect(find.byType(BookAppointmentDrawer), findsOneWidget);
      expect(find.text('Schedule a receptionist-managed visit.'), findsWidgets);
      expect(find.text('Scheduling Notes (optional)'), findsOneWidget);
    });

    testWidgets('Appointments page: clicking available slot opens BookAppointmentDrawer with slot', (tester) async {
      ResponsiveHelper.debugIsDesktopPlatformOverride = true;
      addTearDown(() => ResponsiveHelper.debugIsDesktopPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final appointmentsController = Get.put(AppointmentsController());

      await tester.pumpWidget(GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AppointmentsDesktop()),
      ));
      await tester.pumpAndSettle();

      final availableEntry = AppointmentsController.schedule.firstWhere(
        (e) => e.kind == AppointmentKind.available,
      );
      appointmentsController.openEntry(availableEntry);
      await tester.pumpAndSettle();

      expect(find.byType(BookAppointmentDrawer), findsOneWidget);
      expect(Get.find<BookAppointmentController>().selectedSlot.value, availableEntry.time);
    });

    testWidgets('Book appointment drawer: clicking Book appointment button triggers Appointment conflict popup', (tester) async {
      ResponsiveHelper.debugIsDesktopPlatformOverride = true;
      addTearDown(() => ResponsiveHelper.debugIsDesktopPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final appointmentsController = Get.put(AppointmentsController());

      await tester.pumpWidget(GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AppointmentsDesktop()),
      ));
      await tester.pumpAndSettle();

      appointmentsController.bookAppointment();
      await tester.pumpAndSettle();

      expect(find.byType(BookAppointmentDrawer), findsOneWidget);

      // Tap the "Book Appointment" button inside the drawer (last is button, first is title)
      final drawerBookBtn = find.descendant(
        of: find.byType(BookAppointmentDrawer),
        matching: find.text('Book Appointment'),
      ).last;
      await tester.tap(drawerBookBtn);
      await tester.pumpAndSettle();

      // Conflict popup appears on screen!
      expect(find.text('Appointment conflict'), findsOneWidget);
      expect(find.text('The selected time overlaps an existing appointment.'), findsOneWidget);
      expect(find.text('Choose Another Time'), findsOneWidget);
      expect(find.text('Book Anyway'), findsOneWidget);
    });
  });
}
