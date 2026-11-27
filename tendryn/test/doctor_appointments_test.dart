import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/api/api_client.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/api/mock_interceptor.dart';
import 'package:tendryn/core/theme/app_theme.dart';
import 'package:tendryn/features/appointments/controllers/doctor_appointments_controller.dart';
import 'package:tendryn/features/appointments/models/doctor_appointment.dart';
import 'package:tendryn/features/appointments/widgets/doctor_appointments.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/leave_service.dart';

/// Leave service backed by the app's mock API (an accepting server).
LeaveService _acceptingService() => LeaveService(client: ApiClient(Dio()..interceptors.add(MockInterceptor())));

/// A server that cannot be reached.
class _OfflineInterceptor extends Interceptor {
  int calls = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    calls++;
    handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionError), true);
  }
}

/// A server that answers only when [release] is called.
class _GatedInterceptor extends Interceptor {
  final _gate = Completer<void>();
  int calls = 0;

  void release() => _gate.complete();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    calls++;
    await _gate.future;
    final body = options.data as Map<String, dynamic>;
    handler.resolve(Response<dynamic>(requestOptions: options, statusCode: 200, data: {'id': 'LV-1', 'status': 'pending', ...body}));
  }
}

LeaveService _serviceWith(Interceptor interceptor) => LeaveService(client: ApiClient(Dio()..interceptors.add(interceptor)));

/// GetX won't swap a registered service, so remove it first.
void _useService(LeaveService service) {
  Get.delete<LeaveService>(force: true);
  Get.put<LeaveService>(service);
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(DoctorAppointmentsController());
  });
  tearDown(Get.reset);

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child)));
    await tester.pump();
  }

    Future<void> pumpGet(WidgetTester tester, Size size, Widget child) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => Scaffold(body: child)),
            GetPage(name: AppRoutes.doctorAppointmentDetails, page: () => const Scaffold(body: DoctorAppointmentDetailsPage())),
            GetPage(name: AppRoutes.doctorLeaveRequest, page: () => const Scaffold(body: DoctorLeaveRequestPage())),
            GetPage(name: AppRoutes.patients, page: () => const Scaffold(body: Text('patients page'))),
            GetPage(name: AppRoutes.appointments, page: () => Scaffold(body: child)),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }


  final sizes = {
    'desktop': (const Size(1032 + 248, 900), const DoctorAppointmentsDesktop()),
    'tablet portrait': (const Size(744, 1133), const DoctorAppointmentsTablet()),
    'tablet landscape': (const Size(1133, 744), const DoctorAppointmentsTablet()),
    'mobile': (const Size(393, 852), const DoctorAppointmentsMobile()),
    'small mobile': (const Size(320, 640), const DoctorAppointmentsMobile()),
  };

  for (final entry in sizes.entries) {
    testWidgets('${entry.key} lays out without overflow and lists the day', (tester) async {
      await pumpAt(tester, entry.value.$1, entry.value.$2);
      expect(tester.takeException(), isNull);
      expect(find.text('Appointments'), findsNWidgets(2)); // heading + tab
      expect(find.text('My Availability'), findsOneWidget);
      expect(find.text('Nomsa Dlamini'), findsOneWidget);
      expect(find.text('Ready for consultation'), findsOneWidget);
    });
  }

  testWidgets('search filters by patient name or folder number', (tester) async {
    await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
    await tester.enterText(find.byType(TextField), 'SWC-40216');
    await tester.pump();
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Nomsa Dlamini'), findsNothing);
  });

  testWidgets('day without appointments shows the empty state', (tester) async {
    await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
    Get.find<DoctorAppointmentsController>().selectDate(DateTime(2026, 10, 24));
    await tester.pump();
    expect(find.text('No appointments for this day.'), findsOneWidget);
  });

  group('week scope', () {
    final weekSizes = {
      'desktop': (const Size(1032 + 248, 900), const DoctorAppointmentsDesktop()),
      'tablet portrait': (const Size(744, 1133), const DoctorAppointmentsTablet()),
      'tablet landscape': (const Size(1133, 744), const DoctorAppointmentsTablet()),
      'narrow tablet': (const Size(600, 960), const DoctorAppointmentsTablet()),
      'mobile': (const Size(393, 852), const DoctorAppointmentsMobile()),
      'small mobile': (const Size(320, 640), const DoctorAppointmentsMobile()),
    };

    for (final entry in weekSizes.entries) {
      testWidgets('${entry.key} shows the working week without overflow', (tester) async {
        await pumpAt(tester, entry.value.$1, entry.value.$2);
        Get.find<DoctorAppointmentsController>().setScope(DoctorScheduleScope.week);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('19 – 23 October 2026'), findsWidgets);
        expect(find.text('Sipho Khumalo'), findsWidgets);
        expect(find.text('Zanele Mthembu'), findsWidgets);
      });
    }

    testWidgets('stepping moves a week and search narrows it', (tester) async {
      await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      final controller = Get.find<DoctorAppointmentsController>()..setScope(DoctorScheduleScope.week);
      await tester.pump();
      expect(controller.weekTotal, 13);
      controller.step(1);
      await tester.pump();
      expect(find.text('26 – 30 October 2026'), findsWidgets);
      controller.step(-1);
      controller.setSearch('Sipho');
      await tester.pump();
      expect(controller.weekTotal, 3);
    });

    testWidgets('Today returns to the day list on the current day', (tester) async {
      await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      final controller = Get.find<DoctorAppointmentsController>()..setScope(DoctorScheduleScope.week);
      controller.step(1);
      controller.setScope(DoctorScheduleScope.day);
      await tester.pump();
      expect(controller.selectedDate.value, DoctorAppointmentsController.today);
      expect(find.text('Nomsa Dlamini'), findsOneWidget);
    });
  });

  group('appointment details', () {
    final viewButton = find.widgetWithText(TextButton, 'View');

    testWidgets('phone: each View opens a bottom sheet for its own appointment', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());

      await tester.ensureVisible(viewButton.at(1));
      await tester.pumpAndSettle();
      await tester.tap(viewButton.at(1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Appointment details'), findsOneWidget);
      expect(find.text('Thursday · 22 October 2026 · 09:30'), findsOneWidget);
      expect(find.text('09:30 – 09:50'), findsOneWidget);
      expect(find.text('Thu 22 Oct 2026'), findsOneWidget);
      expect(find.text('Dr. Maya Naidoo'), findsOneWidget);
      expect(find.text('Booked by'), findsOneWidget);
      expect(find.text('Read-only'), findsOneWidget);
      expect(find.textContaining('SWC-40216'), findsWidgets);
      expect(find.text('Checked in'), findsWidgets);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Appointment details'), findsNothing);

      await tester.ensureVisible(viewButton.at(2));
      await tester.pumpAndSettle();
      await tester.tap(viewButton.at(2));
      await tester.pumpAndSettle();
      expect(find.text('Thursday · 22 October 2026 · 10:30'), findsOneWidget);
      expect(find.textContaining('SWC-39954'), findsWidgets);
      expect(find.text('Not checked in'), findsOneWidget);
    });

    testWidgets('small phone: the sheet fits and scrolls without overflow', (tester) async {
      await pumpGet(tester, const Size(320, 568), const DoctorAppointmentsMobile());
      await tester.ensureVisible(viewButton.first);
      await tester.tap(viewButton.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('View Patient Profile'), findsOneWidget);
    });

    testWidgets('desktop: View opens the side drawer for the clicked row', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 900), const DoctorAppointmentsDesktop());

      await tester.tap(viewButton.at(3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Appointment details'), findsOneWidget);
      expect(find.text('Thursday · 22 October 2026 · 11:30'), findsOneWidget);
      expect(find.text('11:30 – 11:50'), findsOneWidget);
      expect(find.textContaining('SWC-42107'), findsWidgets);
      expect(find.text('Rescheduled'), findsWidgets);
      // The list stays visible behind the drawer.
      expect(find.text('Zanele Mthembu'), findsOneWidget);

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();
      expect(find.text('Appointment details'), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });

    for (final size in [const Size(744, 1133), const Size(1133, 744)]) {
      testWidgets('tablet ${size.width.toInt()}x${size.height.toInt()}: View opens a details page and back returns', (tester) async {
        await pumpGet(tester, size, const DoctorAppointmentsTablet());

        await tester.ensureVisible(viewButton.at(4));
        await tester.pumpAndSettle();
        await tester.tap(viewButton.at(4));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Appointment details'), findsOneWidget);
        expect(find.text('Thursday · 22 October 2026 · 14:00'), findsOneWidget);
        expect(find.textContaining('SWC-38820'), findsWidgets);
        expect(find.text('Cancelled'), findsOneWidget);
        expect(find.text('This appointment was cancelled.'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Back to appointments'));
        await tester.pumpAndSettle();
        expect(find.text('Appointment details'), findsNothing);
        expect(find.text('Nomsa Dlamini'), findsOneWidget);
      });
    }

    testWidgets('week view: tapping a card opens that appointment', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 900), const DoctorAppointmentsDesktop());
      Get.find<DoctorAppointmentsController>().setScope(DoctorScheduleScope.week);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel(RegExp('^09:00 Sipho Khumalo')));
      await tester.pumpAndSettle();
      expect(find.text('Wednesday · 19 October 2026 · 09:00'.replaceFirst('Wednesday', 'Monday')), findsOneWidget);
      expect(find.text('Not recorded'), findsOneWidget); // visit type for this booking
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('View Patient Profile hands the patient to the Patients screen', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await tester.tap(viewButton.first);
      await tester.pumpAndSettle();
      expect(find.text('51 yrs · Folder #SWC-41782'), findsOneWidget);

      await tester.tap(find.text('View Patient Profile'));
      await tester.pumpAndSettle();
      expect(find.text('patients page'), findsOneWidget);
      final requested = PatientsController.takePendingDoctorProfile();
      expect(requested?.name, 'Nomsa Dlamini');
      expect(requested?.fileNumber, 'SWC-41782');
    });

    testWidgets('a patient outside the directory still opens a profile request', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await tester.ensureVisible(viewButton.at(1));
      await tester.pumpAndSettle();
      await tester.tap(viewButton.at(1));
      await tester.pumpAndSettle();
      expect(find.text('Folder #SWC-40216'), findsNWidgets(2)); // list row + sheet
      await tester.tap(find.text('View Patient Profile'));
      await tester.pumpAndSettle();
      final requested = PatientsController.takePendingDoctorProfile();
      expect(requested?.name, 'Thabo Mokoena');
      expect(requested?.dateOfBirth, 'Not recorded');
    });

    testWidgets('the tablet page without a selected appointment explains and offers a way back', (tester) async {
      tester.view.physicalSize = const Size(744, 1133);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: DoctorAppointmentDetailsPage())));
      await tester.pump();
      expect(find.text('Appointment not found'), findsOneWidget);
    });
  });

  group('my availability tab', () {
    final availabilitySizes = {
      'desktop': (const Size(1032 + 248, 1000), const DoctorAppointmentsDesktop()),
      'narrow desktop': (const Size(1200, 900), const DoctorAppointmentsDesktop()),
      'tablet portrait': (const Size(744, 1133), const DoctorAppointmentsTablet()),
      'tablet landscape': (const Size(1133, 744), const DoctorAppointmentsTablet()),
      'narrow tablet': (const Size(600, 960), const DoctorAppointmentsTablet()),
      'mobile': (const Size(393, 852), const DoctorAppointmentsMobile()),
      'small mobile': (const Size(320, 640), const DoctorAppointmentsMobile()),
    };

    for (final entry in availabilitySizes.entries) {
      testWidgets('${entry.key}: tapping My Availability shows the schedule without overflow', (tester) async {
        await pumpAt(tester, entry.value.$1, entry.value.$2);
        expect(find.text('Working hours'), findsNothing);

        await tester.tap(find.text('My Availability'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Working hours'), findsOneWidget);
        expect(find.text('Monday'), findsOneWidget);
        expect(find.text('Sunday'), findsOneWidget);
        expect(find.text('Working'), findsNWidgets(5));
        expect(find.text('Not working'), findsNWidgets(2));
        expect(find.text('Unavailable dates'), findsOneWidget);
        expect(find.text('Fri 25 Dec 2026'), findsOneWidget);
        expect(find.text('Christmas Day'), findsOneWidget);
        expect(find.text('Leave requests'), findsOneWidget);
        // No leave has been requested yet: the empty state, not sample requests.
        expect(find.text('No leave requests'), findsOneWidget);
        expect(find.text('Requests you submit will appear here with their approval status.'), findsOneWidget);
        expect(find.textContaining('Proposed'), findsNothing);
        expect(find.text('Request Leave'), findsOneWidget);
        // The Appointments tab content is gone.
        expect(find.text('Nomsa Dlamini'), findsNothing);
      });
    }

    testWidgets('Monday shows its split hours, other days a single range', (tester) async {
      await pumpAt(tester, const Size(1280, 1000), const DoctorAppointmentsDesktop());
      await tester.tap(find.text('My Availability'));
      await tester.pumpAndSettle();
      expect(find.text('09:00 AM – 11:30 AM  |  02:00 PM – 05:00 PM'), findsOneWidget);
      expect(find.text('09:00 AM – 05:00 PM'), findsNWidgets(4));
    });

    testWidgets('phone: Monday splits over two lines like the design', (tester) async {
      await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await tester.tap(find.text('My Availability'));
      await tester.pumpAndSettle();
      expect(find.text('09:00 AM – 11:30 AM  |\n02:00 PM – 05:00 PM'), findsOneWidget);
    });

    testWidgets('switching back to Appointments restores the day list and its state', (tester) async {
      await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      final controller = Get.find<DoctorAppointmentsController>();
      controller.setSearch('Thabo');
      await tester.pump();
      await tester.tap(find.text('My Availability'));
      await tester.pumpAndSettle();
      expect(controller.tab.value, DoctorTab.availability);

      await tester.tap(find.widgetWithText(InkWell, 'Appointments'));
      await tester.pumpAndSettle();
      expect(controller.tab.value, DoctorTab.appointments);
      expect(find.text('Thabo Mokoena'), findsOneWidget);
      expect(find.text('Nomsa Dlamini'), findsNothing);
      expect(find.text('Working hours'), findsNothing);
    });

    testWidgets('the selected tab is marked selected for accessibility', (tester) async {
      await pumpAt(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await tester.tap(find.text('My Availability'));
      await tester.pumpAndSettle();
      final selected = tester.getSemantics(find.text('My Availability'));
      expect(selected.flagsCollection.isSelected, isNotNull);
    });

    testWidgets('the edit pencil responds without a service behind it', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await tester.tap(find.text('My Availability'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Edit Monday working hours'));
      await tester.pump();
      expect(find.text('Edit working hours'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    test('leave durations count only the days the doctor works', () {
      final week = DoctorLeaveRequest(start: DateTime(2026, 10, 3), end: DateTime(2026, 10, 12), status: DoctorLeaveStatus.pending);
      // Sat 3 .. Mon 12: Mon-Fri 5-9 plus Mon 12 = 6.
      expect(DoctorAppointmentsController.leaveDurationLabel(week), '6 working days');
      expect(DoctorAppointmentsController.leaveDatesLabel(week), '03 Oct – 12 Oct 2026'.replaceFirst('03 Oct – 12 Oct', '03 – 12 Oct'));
    });
  });

  group('request leave', () {
    setUp(() => Get.put<LeaveService>(_acceptingService()));

    Future<void> openAvailability(WidgetTester tester) async {
      await tester.tap(find.text('My Availability'));
      await tester.pumpAndSettle();
    }

    Future<void> tapRequestLeave(WidgetTester tester) async {
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Request Leave'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Request Leave'));
      await tester.pumpAndSettle();
    }

    DoctorAppointmentsController c() => Get.find<DoctorAppointmentsController>();

    testWidgets('desktop: opens a drawer with the empty form; the Availability tab stays behind it', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 932), const DoctorAppointmentsDesktop());
      await openAvailability(tester);
      await tester.tap(find.text('Request Leave'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Select the dates you will be unavailable.'), findsOneWidget);
      expect(find.text('DD MMM YYYY'), findsNWidgets(2));
      expect(find.text('Optional  e.g. annual leave'), findsOneWidget);
      expect(find.textContaining('Your Unit Admin reviews the request'), findsOneWidget);
      expect(find.text('Submit Request'), findsOneWidget);
      expect(find.text('Start date is required.'), findsNothing);
      expect(find.text('Working hours'), findsOneWidget);

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();
      expect(find.text('Select the dates you will be unavailable.'), findsNothing);
      expect(c().tab.value, DoctorTab.availability);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('submitting an empty form shows the required messages and keeps the form open', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 932), const DoctorAppointmentsDesktop());
      await openAvailability(tester);
      await tester.tap(find.text('Request Leave'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(find.text('Start date is required.'), findsOneWidget);
      expect(find.text('End date is required.'), findsOneWidget);
      expect(find.text('Select the dates you will be unavailable.'), findsOneWidget);
      expect(c().leaveRequests, isEmpty);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('phone: a bottom sheet; dates and reason are kept, Cancel discards them', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Select the dates you will be unavailable.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Annual leave');
      c().leaveStart.value = DateTime(2026, 12, 1);
      await tester.pump();
      expect(find.text('01 Dec 2026'), findsOneWidget);
      expect(c().reasonController.text, 'Annual leave');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Select the dates you will be unavailable.'), findsNothing);
      expect(c().leaveStart.value, isNull);
      expect(c().reasonController.text, isEmpty);

      await tapRequestLeave(tester);
      expect(find.text('DD MMM YYYY'), findsNWidgets(2));
    });

    testWidgets('end before start is rejected with a message', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      c().leaveStart.value = DateTime(2026, 12, 10);
      c().leaveEnd.value = DateTime(2026, 12, 5);
      await tester.pump();
      expect(find.text('End date must be on or after the start date.'), findsOneWidget);
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(c().leaveRequests, isEmpty);
    });

    testWidgets('dates that cover booked appointments list them and warn', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      expect(find.textContaining('Your Unit Admin reviews'), findsOneWidget);

      c().leaveStart.value = DateTime(2026, 10, 19);
      c().leaveEnd.value = DateTime(2026, 10, 21);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Mon 19: Sipho, Lerato (checked in); Wed 21: Bongani (checked in); Thabo's 14:00 is cancelled.
      expect(find.text('3 booked appointments fall in these dates'), findsOneWidget);
      expect(find.text('You can still submit. If approved, reception will reschedule them.'), findsOneWidget);
      expect(find.text('Needs attention'), findsNWidgets(3));
      expect(find.text('Mon 19 Oct · 09:00'), findsOneWidget);
      expect(find.textContaining('Your Unit Admin reviews'), findsNothing);

      c().leaveEnd.value = DateTime(2026, 10, 19);
      await tester.pumpAndSettle();
      expect(find.text('2 booked appointments fall in these dates'), findsOneWidget);
    });

    testWidgets('phone: a valid request is sent, confirmed in a sheet, then listed as pending', (tester) async {
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);

      await tester.enterText(find.byType(TextField), '  Annual leave ');
      c().leaveStart.value = DateTime(2026, 11, 16);
      c().leaveEnd.value = DateTime(2026, 11, 18);
      await tester.pump();
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Select the dates you will be unavailable.'), findsNothing);
      expect(find.text('Leave Request Submitted'), findsOneWidget);
      expect(find.text('Your leave request has been submitted for review.'), findsOneWidget);
      expect(c().leaveRequests, hasLength(1));
      final saved = c().leaveRequests.single;
      expect(saved.id, startsWith('LV-'));
      expect(saved.status, DoctorLeaveStatus.pending);
      expect(saved.reason, 'Annual leave');
      expect(c().leaveStart.value, isNull);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Leave Request Submitted'), findsNothing);
      expect(c().tab.value, DoctorTab.availability);

      expect(find.text('No leave requests'), findsNothing);
      await tester.ensureVisible(find.text('16 – 18 Nov 2026'));
      expect(find.text('16 – 18 Nov 2026'), findsOneWidget);
      expect(find.text('3 working days'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('desktop: success closes the drawer and shows the centred dialog; Done dismisses it', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 932), const DoctorAppointmentsDesktop());
      await openAvailability(tester);
      await tester.tap(find.text('Request Leave'));
      await tester.pumpAndSettle();
      c().leaveStart.value = DateTime(2026, 11, 16);
      c().leaveEnd.value = DateTime(2026, 11, 18);
      await tester.pump();
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Select the dates you will be unavailable.'), findsNothing);
      expect(find.text('Leave Request Submitted'), findsOneWidget);
      final dialog = tester.getRect(find.ancestor(of: find.text('Leave Request Submitted'), matching: find.byType(Material)).first);
      expect(dialog.width, 440);
      expect(dialog.top, 90);
      expect(dialog.center.dx, 640);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Leave Request Submitted'), findsNothing);
      expect(find.text('Working hours'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('failed submission shows the banner, keeps the details, and never shows success', (tester) async {
      final offline = _OfflineInterceptor();
      _useService(_serviceWith(offline));
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      await tester.enterText(find.byType(TextField), 'Annual leave');
      c().leaveStart.value = DateTime(2026, 11, 16);
      c().leaveEnd.value = DateTime(2026, 11, 18);
      await tester.pump();

      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(offline.calls, 1);
      expect(find.text('Request not submitted'), findsOneWidget);
      expect(find.textContaining('We could not reach the server. Your details are kept'), findsOneWidget);
      expect(find.text('Leave Request Submitted'), findsNothing);
      expect(find.text('Select the dates you will be unavailable.'), findsOneWidget);
      expect(c().leaveRequests, isEmpty);
      expect(c().leaveStart.value, DateTime(2026, 11, 16));
      expect(c().reasonController.text, 'Annual leave');
      expect(find.text('16 Nov 2026'), findsOneWidget);

      // Submitting works again once the server is back; the banner goes away.
      _useService(_acceptingService());
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(find.text('Request not submitted'), findsNothing);
      expect(find.text('Leave Request Submitted'), findsOneWidget);
      expect(c().leaveRequests, hasLength(1));
    });

    testWidgets('tablet: a failed submission shows the banner above the heading and keeps the page open', (tester) async {
      _useService(_serviceWith(_OfflineInterceptor()));
      await pumpGet(tester, const Size(744, 1133), const DoctorAppointmentsTablet());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      c().leaveStart.value = DateTime(2026, 11, 16);
      c().leaveEnd.value = DateTime(2026, 11, 18);
      await tester.pump();
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Request not submitted'), findsOneWidget);
      expect(find.text('Leave Request Submitted'), findsNothing);
      final banner = tester.getRect(find.text('Request not submitted'));
      final heading = tester.getRect(find.text('Request Leave').last);
      expect(banner.bottom, lessThan(heading.top));
      expect(c().leaveRequests, isEmpty);
    });

    for (final size in [const Size(744, 1133), const Size(1133, 744), const Size(600, 960)]) {
      testWidgets('tablet ${size.width.toInt()}x${size.height.toInt()}: success shows the confirmation dialog within the viewport', (tester) async {
        await pumpGet(tester, size, const DoctorAppointmentsTablet());
        await openAvailability(tester);
        await tapRequestLeave(tester);
        c().leaveStart.value = DateTime(2026, 11, 16);
        c().leaveEnd.value = DateTime(2026, 11, 18);
        await tester.pump();
        await tester.tap(find.text('Submit Request'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Select the dates you will be unavailable.'), findsNothing);
        final dialog = tester.getRect(find.ancestor(of: find.text('Leave Request Submitted'), matching: find.byType(Material)).first);
        expect(dialog.left, greaterThanOrEqualTo(0));
        expect(dialog.right, lessThanOrEqualTo(size.width));
        expect(dialog.bottom, lessThanOrEqualTo(size.height));
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Leave Request Submitted'), findsNothing);
        expect(find.text('Working hours'), findsOneWidget);
        expect(c().tab.value, DoctorTab.availability);
      });
    }

    testWidgets('a second tap while sending does not send a second request', (tester) async {
      final gated = _GatedInterceptor();
      _useService(_serviceWith(gated));
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      c().leaveStart.value = DateTime(2026, 11, 16);
      c().leaveEnd.value = DateTime(2026, 11, 18);
      await tester.pump();

      await tester.tap(find.text('Submit Request'));
      await tester.pump(const Duration(milliseconds: 10));
      expect(c().isSubmittingLeave.value, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Request'), findsNothing);
      // Both buttons are disabled while sending, and a direct call is ignored too.
      expect(tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Cancel')).onPressed, isNull);
      expect(await c().submitLeaveRequest(), isFalse);
      expect(gated.calls, 1);

      gated.release();
      await tester.pumpAndSettle();
      expect(gated.calls, 1);
      expect(c().leaveRequests, hasLength(1));
      expect(c().isSubmittingLeave.value, isFalse);
      expect(find.text('Leave Request Submitted'), findsOneWidget);
    });

    testWidgets('an invalid form is never sent to the service', (tester) async {
      final offline = _OfflineInterceptor();
      _useService(_serviceWith(offline));
      await pumpGet(tester, const Size(393, 852), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(offline.calls, 0);
      expect(find.text('Start date is required.'), findsOneWidget);
      expect(find.text('Request not submitted'), findsNothing);
    });

    test('the mock leave endpoint rejects a request without dates', () async {
      final client = ApiClient(Dio()..interceptors.add(MockInterceptor()));
      expect(
        () => client.post('/leave-requests', body: {'reason': 'x'}, parse: (j) => j),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
      );
    });

    for (final size in [const Size(744, 1133), const Size(1133, 744), const Size(600, 960)]) {
      testWidgets('tablet ${size.width.toInt()}x${size.height.toInt()}: a page with side by side dates; back returns to Availability', (tester) async {
        await pumpGet(tester, size, const DoctorAppointmentsTablet());
        await openAvailability(tester);
        await tapRequestLeave(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('Select the dates you will be unavailable.'), findsOneWidget);
        expect(find.text('Submit Request'), findsOneWidget);
        final startBox = tester.getRect(find.byKey(const Key('leave-start-date')));
        final endBox = tester.getRect(find.byKey(const Key('leave-end-date')));
        expect(startBox.top, endBox.top); // side by side

        await tester.tap(find.text('Submit Request'));
        await tester.pumpAndSettle();
        expect(find.text('Start date is required.'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Back to My Availability'));
        await tester.pumpAndSettle();
        expect(find.text('Select the dates you will be unavailable.'), findsNothing);
        expect(find.text('Working hours'), findsOneWidget);
        expect(c().tab.value, DoctorTab.availability);
      });
    }

    testWidgets('small phone: the sheet scrolls and fits with errors and warnings', (tester) async {
      await pumpGet(tester, const Size(320, 568), const DoctorAppointmentsMobile());
      await openAvailability(tester);
      await tapRequestLeave(tester);
      c().leaveStart.value = DateTime(2026, 10, 19);
      c().leaveEnd.value = DateTime(2026, 10, 23);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop drawer with dates that cover bookings matches the filled-in design', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 932), const DoctorAppointmentsDesktop());
      await openAvailability(tester);
      await tester.tap(find.text('Request Leave'));
      await tester.pumpAndSettle();

      c().leaveStart.value = DateTime(2026, 10, 22);
      c().leaveEnd.value = DateTime(2026, 10, 22);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('4 booked appointments fall in these dates'), findsOneWidget);
      expect(find.text('Needs attention'), findsNWidgets(4));
      expect(find.text('Thu 22 Oct · 09:00 · Follow-up'), findsOneWidget);
      expect(find.text('22 Oct 2026'), findsNWidgets(2));
      // Dates are valid, so no error styling and the calendar icons stay.
      expect(find.text('Start date is required.'), findsNothing);
      expect(find.byIcon(AppIcons.calendarDays), findsNWidgets(2));
      // Field heights follow the design (41px).
      expect(tester.getSize(find.byKey(const Key('leave-start-date'))).height, 41);

      // Values survive a rebuild of the form (e.g. switching layout).
      expect(c().leaveStart.value, DateTime(2026, 10, 22));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(c().leaveRequests, hasLength(1));
      expect(find.text('22 Oct 2026'), findsOneWidget); // list row
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('desktop drawer scrolls in a short window', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpGet(tester, const Size(1280, 520), const DoctorAppointmentsDesktop());
      await openAvailability(tester);
      await tester.tap(find.text('Request Leave'));
      await tester.pumpAndSettle();
      c().leaveStart.value = DateTime(2026, 10, 19);
      c().leaveEnd.value = DateTime(2026, 10, 23);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Bongani Nkosi').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Submit Request'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    for (final size in [const Size(744, 1133), const Size(1133, 744)]) {
      testWidgets('tablet ${size.width.toInt()}x${size.height.toInt()}: filled-in page lists the affected appointments', (tester) async {
        await pumpGet(tester, size, const DoctorAppointmentsTablet());
        await openAvailability(tester);
        await tapRequestLeave(tester);
        c().leaveStart.value = DateTime(2026, 10, 19);
        c().leaveEnd.value = DateTime(2026, 10, 21);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('3 booked appointments fall in these dates'), findsOneWidget);
        expect(find.text('Needs attention'), findsNWidgets(3));
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Submit Request'), findsOneWidget);
      });
    }

    test('affected lists exclude cancelled and no-show bookings', () {
      final controller = DoctorAppointmentsController();
      controller.leaveStart.value = DateTime(2026, 10, 22);
      controller.leaveEnd.value = DateTime(2026, 10, 22);
      // Thu 22: 4 booked, 1 cancelled, 1 no-show.
      expect(controller.affectedAppointments.map((a) => a.patient), ['Nomsa Dlamini', 'Thabo Mokoena', 'Lerato Maseko', 'Sipho Khumalo']);
      expect(DoctorAppointmentsController.affectedHeading(1), '1 booked appointment falls in these dates');
      expect(DoctorAppointmentsController.leaveDateLabel(DateTime(2026, 11, 5)), '05 Nov 2026');
    });
  });
}
