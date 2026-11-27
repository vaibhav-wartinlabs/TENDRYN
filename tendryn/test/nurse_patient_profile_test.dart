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
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/features/queue/bindings/queue_binding.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/controllers/record_sample_controller.dart';
import 'package:tendryn/features/queue/views/record_sample_view.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/queue/views/nurse_patient_profile_view.dart';
import 'package:tendryn/features/queue/views/queue_view.dart';
import 'package:tendryn/features/queue/widgets/queue_row_menu.dart';
import 'package:tendryn/routes/app_pages.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/api_service.dart';
import 'package:tendryn/services/auth_service.dart' as svc;
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/services/queue_service.dart';
import 'package:tendryn/services/storage_service.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

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

  group('NursePatientProfile.fromQueueEntry', () {
    const entry = QueueEntry(
      number: 'Q014',
      patient: 'Thabo Nkosi',
      arrival: '09:10',
      waitingMinutes: 24,
      reason: 'General consultation',
      priority: QueuePriority.urgent,
      status: QueueStatus.waitingForDoctor,
      practitioner: 'Dr Thandi Nkosi',
      demographics: '38/F',
    );

    test('carries the queue row into the profile', () {
      final p = NursePatientProfile.fromQueueEntry(entry);
      expect(p.name, 'Thabo Nkosi');
      expect(p.patientId, 'TND-000014');
      expect(p.sex, 'Female');
      expect(p.ageLabel, '38 yrs');
      expect(p.reason, 'General consultation');
      expect(p.status, QueueStatus.waitingForDoctor);
      expect(p.priority, QueuePriority.urgent);
      expect(p.practitioner, 'Dr Thandi Nkosi');
      expect(p.ageSexAndId, '38 yrs · Female | TND-000014');
      expect(p.timeline.first.time, 'Today · 09:10');
      expect(p.timeline[1].time, 'Today · 09:12');
      expect(p.timeline[1].description, 'Added to triage queue · Waiting for Doctor');
    });

    test('an unassigned practitioner and unreadable demographics are shown honestly', () {
      const unassigned = QueueEntry(
        number: 'Q020',
        patient: 'Sipho Dlamini',
        arrival: '23:59',
        waitingMinutes: 3,
        reason: 'Follow-up',
        priority: QueuePriority.routine,
        status: QueueStatus.waiting,
        demographics: 'unknown',
      );
      final p = NursePatientProfile.fromQueueEntry(unassigned);
      expect(p.timeline[1].time, 'Today · 00:01'); // wraps past midnight
      expect(p.practitioner, 'Not assigned');
      expect(p.sex, 'Not recorded');
      expect(p.ageLabel, 'Not recorded');
    });
  });

  _callFlowTests();
  _clinicalHistoryTests();
  _labReferralTests();
  _viewTriageTests();
  _consultationsTests();
  _prescriptionsTests();
  _labReferralDetailTests();
  _recordSampleTests();
  _labResultTests();

  group('Access', () {
    test('only the Nurse can open the Patient profile', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.nursePatientProfile)?.name, AppRoutes.dashboard);

      await RoleController.to.switchRole(ClinicRole.doctor);
      expect(guard.redirect(AppRoutes.nursePatientProfile)?.name, AppRoutes.dashboard);
      expect(guard.redirect(AppRoutes.consultations), isNull);

      await RoleController.to.switchRole(ClinicRole.nurse);
      expect(guard.redirect(AppRoutes.nursePatientProfile), isNull);
    });
  });

  group('Queue -> View Profile', () {
    Future<void> pumpQueue(WidgetTester tester, {required Size size, required bool desktop}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      ResponsiveHelper.debugIsDesktopPlatformOverride = desktop;

      await RoleController.to.switchRole(ClinicRole.nurse);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          getPages: AppPages.pages,
          home: const _QueueHome(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    Future<void> openProfileOfRow(WidgetTester tester, int row) async {
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      expect(find.text('View Patient'), findsOneWidget);
      expect(find.text('Begin Triage'), findsOneWidget);
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    testWidgets('desktop: opens the tapped patient, then Back to Queue keeps the queue state', (tester) async {
      await pumpQueue(tester, size: const Size(1280, 1100), desktop: true);
      final queue = Get.find<QueueController>();
      final second = queue.pageEntries[1];
      queue.search(second.patient);
      await tester.pumpAndSettle();

      await openProfileOfRow(tester, 0);
      expect(tester.takeException(), isNull);
      expect(Get.currentRoute, AppRoutes.nursePatientProfile);
      expect(find.text('Patient profile'), findsOneWidget);
      expect(find.text('Back to Queue'), findsOneWidget);
      expect(find.text('Start triage'), findsOneWidget);
      expect(find.text(second.patient), findsWidgets);
      expect(find.text('Demographics'), findsOneWidget);
      expect(find.text('Existing conditions'), findsOneWidget);
      expect(find.text('Previous vitals'), findsOneWidget);
      expect(find.text('Visit timeline'), findsOneWidget);
      expect(find.text('Allergy: Penicillin'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(Get.find<NursePatientProfileController>().profile.queueNumber, second.number);

      await tester.tap(find.text('Back to Queue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(Get.currentRoute, isNot(AppRoutes.nursePatientProfile));
      expect(find.text('Patient profile'), findsNothing);
      expect(find.text('Triage queue'), findsOneWidget);
      // Same controller, search still applied.
      expect(identical(Get.find<QueueController>(), queue), isTrue);
      expect(queue.searchQuery.value, second.patient);
    });

    for (final (name, size, desktop) in [
      ('desktop 1280x1083', const Size(1280, 1083), true),
      ('narrow Windows 1200x800', const Size(1200, 800), true),
      ('tablet 744x1362', const Size(744, 1362), false),
      ('small tablet 600x960', const Size(600, 960), false),
      ('tablet landscape 1194x744', const Size(1194, 744), false),
      ('mobile 393x852', const Size(393, 852), false),
      ('small phone 360x640', const Size(360, 640), false),
    ]) {
      testWidgets('profile lays out without overflow: $name', (tester) async {
        await pumpQueue(tester, size: size, desktop: desktop);
        final first = Get.find<QueueController>().pageEntries.first;
        await openProfileOfRow(tester, 0);

        expect(tester.takeException(), isNull);
        expect(find.text('Patient profile'), findsOneWidget);
        expect(find.text(first.patient), findsWidgets);
        expect(find.text('Start triage'), findsOneWidget);

        // Everything below the fold is reachable and does not overflow either.
        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(find.text('Visit timeline'), scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(find.text('Triage completed · Routine · Sister Naledi Naidoo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('mobile: own heading replaces the brand header; back returns to the queue', (tester) async {
      await pumpQueue(tester, size: const Size(393, 852), desktop: false);
      await openProfileOfRow(tester, 0);

      expect(find.text('Patient profile'), findsOneWidget);
      expect(find.text('Back to Queue'), findsNothing); // arrow only, as designed
      // Bottom navigation is hidden on mobile & tablet patient profile
      expect(find.text('Patients'), findsNothing);
      expect(find.text('Vitals / Triage'), findsNothing);

      await tester.tap(find.byTooltip('Back to Queue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Patient profile'), findsNothing);
      // The queue underneath is intact (its heading may be scrolled out of view) and bottom navigation restores.
      expect(find.byType(QueueView), findsOneWidget);
      expect(find.byType(QueueRowMenu), findsWidgets);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Vitals / Triage'), findsOneWidget);
    });

  });
}

class _QueueHome extends StatelessWidget {
  const _QueueHome();

  @override
  Widget build(BuildContext context) {
    QueueBinding().dependencies();
    return const AppShell(route: AppRoutes.queue, child: QueueView());
  }
}

class _CallHost {
  static Future<void> pump(WidgetTester tester, {required Size size, required bool desktop}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ResponsiveHelper.debugIsDesktopPlatformOverride = desktop;
    await RoleController.to.switchRole(ClinicRole.nurse);
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light(), getPages: AppPages.pages, home: const _QueueHome()),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

void _callFlowTests() {
  group('Nurse Call next flow', () {
    Future<void> tapCallNext(WidgetTester tester) async {
      final button = find.text('Call next');
      if (button.evaluate().isEmpty) {
        await tester.dragUntilVisible(button, find.byType(ListView).first, const Offset(0, -300));
      }
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    for (final (name, size, desktop) in [
      ('desktop 1280x832', const Size(1280, 832), true),
      ('tablet 744x861', const Size(744, 861), false),
      ('mobile 393x860', const Size(393, 860), false),
      ('small phone 360x640', const Size(360, 640), false),
      ('narrow Windows 1200x800', const Size(1200, 800), true),
    ]) {
      testWidgets('confirmation shows the next waiting patient without overflow: $name', (tester) async {
        await _CallHost.pump(tester, size: size, desktop: desktop);
        final queue = Get.find<QueueController>();
        final next = queue.nextToCall!;
        expect(next.status, QueueStatus.waiting);

        await tapCallNext(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('Call ${next.patient}?'), findsOneWidget);
        expect(find.textContaining('Queue ${next.number} · TND-'), findsOneWidget);
        expect(
          find.text('${next.patient} will be called to the triage room. Their queue status will change to With Nurse.'),
          findsOneWidget,
        );
        expect(find.text('Queue number'), findsOneWidget);
        expect(find.text('Reason for visit'), findsOneWidget);
        expect(find.text('Priority'), findsWidgets);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Call patient'), findsOneWidget);
      });
    }

    testWidgets('Cancel and Close change nothing', (tester) async {
      await _CallHost.pump(tester, size: const Size(1280, 832), desktop: true);
      final queue = Get.find<QueueController>();
      final next = queue.nextToCall!;
      final waitingBefore = queue.queue.value!.patientsWaiting;

      await tapCallNext(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Call ${next.patient}?'), findsNothing);

      await tapCallNext(tester);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Call ${next.patient}?'), findsNothing);

      expect(queue.nextToCall?.number, next.number);
      expect(queue.queue.value!.patientsWaiting, waitingBefore);
    });

    testWidgets('Call patient marks only that patient With Nurse, on this device, and keeps queue state', (tester) async {
      await _CallHost.pump(tester, size: const Size(393, 860), desktop: false);
      final queue = Get.find<QueueController>();
      final next = queue.nextToCall!;
      final waitingBefore = queue.queue.value!.patientsWaiting;
      queue.search('a');
      await tester.pumpAndSettle();

      await tapCallNext(tester);
      await tester.tap(find.text('Call patient'));
      await tester.pumpAndSettle();

      final updated = queue.queue.value!.entries.firstWhere((e) => e.number == next.number);
      expect(updated.status, QueueStatus.withNurse);
      expect(queue.queue.value!.patientsWaiting, waitingBefore - 1);
      expect(queue.nextToCall?.number, isNot(next.number));
      expect(queue.searchQuery.value, 'a');
      // Honest notice: no real call or sync happened.
      expect(find.textContaining('this device only'), findsOneWidget);
      expect(find.text('Call ${next.patient}?'), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('with nobody waiting it says so instead of opening the dialog', (tester) async {
      await _CallHost.pump(tester, size: const Size(1280, 832), desktop: true);
      final queue = Get.find<QueueController>();
      queue.queue.value = queue.queue.value!.copyWith(
        entries: [for (final e in queue.queue.value!.entries) e.copyWith(status: QueueStatus.withNurse)],
      );
      await tester.pumpAndSettle();

      await tapCallNext(tester);
      expect(find.text('Call patient'), findsNothing);
      expect(find.text('No patients are waiting.'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}

void _clinicalHistoryTests() {
  group('Clinical History tab', () {
    Future<void> openProfile(WidgetTester tester, Size size, bool desktop, int row) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    test('visits come from the selected patient and mark today as the current visit', () {
      const entry = QueueEntry(
        number: 'Q017',
        patient: 'Amahle Khumalo',
        arrival: '09:27',
        waitingMinutes: 7,
        reason: 'Prescription follow-up',
        priority: QueuePriority.routine,
        status: QueueStatus.waiting,
      );
      final p = NursePatientProfile.fromQueueEntry(entry, today: DateTime(2026, 10, 26), recordedBy: 'Sister Z');
      expect(p.visits.length, 2);
      expect(p.visits.first.current, isTrue);
      expect(p.visits.first.date, '26 Oct 2026');
      expect(p.visits.first.reason, 'Prescription follow-up');
      expect(p.visits.first.recordedBy, 'Sister Z');
      expect(p.visits.first.status, VisitStatus.triageInProgress);
      expect(p.visits.last.current, isFalse);
      expect(p.visits.last.status, VisitStatus.triageCompleted);
    });

    for (final (name, size, desktop) in [
      ('desktop 1280x969', const Size(1280, 969), true),
      ('narrow Windows 1200x800', const Size(1200, 800), true),
      ('tablet 744x1154', const Size(744, 1154), false),
      ('small tablet 600x960', const Size(600, 960), false),
      ('tablet landscape 1194x744', const Size(1194, 744), false),
      ('mobile 393x852', const Size(393, 852), false),
      ('small phone 360x640', const Size(360, 640), false),
    ]) {
      testWidgets('shows history for the tapped patient without overflow: $name', (tester) async {
        await openProfile(tester, size, desktop, 1);
        final queue = Get.find<QueueController>();
        final entry = queue.pageEntries[1];

        await tester.tap(find.text('Clinical History'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.clinicalHistory);
        // Header, identity and tabs stay; overview cards are replaced.
        expect(find.text(entry.patient), findsWidgets);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Demographics'), findsNothing);
        expect(find.text('Visit history'), findsOneWidget);
        expect(find.text('2 visits'), findsOneWidget);
        expect(find.text(entry.reason), findsWidgets);
        expect(find.text('Current visit'), findsOneWidget);
        expect(find.text('Triage in progress'), findsOneWidget);
        expect(find.text('Triage completed'), findsOneWidget);
        expect(find.text('Routine check'), findsOneWidget);
        expect(find.text('View triage'), findsOneWidget);

        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(find.text('Clinical records'), scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(find.text('Read only for your role'), findsOneWidget);
        expect(find.text('No consultations recorded'), findsOneWidget);
        expect(find.text('No prescriptions recorded'), findsOneWidget);
        expect(find.text('View consultations'), findsOneWidget);
        expect(find.text('View Prescription'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    for (final (name, size, desktop) in [
      ('desktop', const Size(1280, 969), true),
      ('tablet', const Size(744, 1154), false),
      ('phone', const Size(393, 852), false),
    ]) {
      testWidgets('record links end at the right edge of the card: $name', (tester) async {
        await openProfile(tester, size, desktop, 0);
        await tester.tap(find.text('Clinical History'));
        await tester.pumpAndSettle();
        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(find.text('View Prescription'), scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();

        // The "Read only" badge ends at the card's inner right edge.
        final cardRight = tester.getBottomRight(find.text('Read only').last).dx + 10;
        final consultations = find.ancestor(
          of: find.text('View consultations'),
          matching: find.byType(Row),
        ).first;
        final prescriptions = find.ancestor(
          of: find.text('View Prescription'),
          matching: find.byType(Row),
        ).first;
        final a = tester.getBottomRight(consultations).dx;
        final b = tester.getBottomRight(prescriptions).dx;
        expect(a, closeTo(b, 0.5), reason: 'both links end together');
        expect(a, closeTo(cardRight, 1.5), reason: 'and at the card edge');
      });
    }

    testWidgets('tabs switch back and forth', (tester) async {
      await openProfile(tester, const Size(1280, 1100), true, 0);
      final c = Get.find<NursePatientProfileController>();

      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();
      expect(find.text('Visit history'), findsOneWidget);

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      expect(c.tab.value, NurseProfileTab.overview);
      expect(find.text('Demographics'), findsOneWidget);
      expect(find.text('Visit history'), findsNothing);
      expect(find.text('Start triage'), findsOneWidget);
    });

    testWidgets("a different patient's history is not reused", (tester) async {
      await openProfile(tester, const Size(1280, 1100), true, 0);
      final first = Get.find<QueueController>().pageEntries[0];
      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();
      expect(find.text(first.reason), findsWidgets);
      expect(Get.find<NursePatientProfileController>().profile.visits.first.reason, first.reason);

      await tester.tap(find.text('Back to Queue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final menu = find.byType(QueueRowMenu).at(2);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final third = Get.find<QueueController>().pageEntries[2];
      final c = Get.find<NursePatientProfileController>();
      expect(c.profile.name, third.patient);
      expect(c.profile.visits.first.reason, third.reason);
      expect(c.tab.value, NurseProfileTab.overview); // each opening starts on Overview
    });
  });
}

void _labReferralTests() {
  group('Lab referrals tab', () {
    Future<void> openProfile(WidgetTester tester, Size size, bool desktop, int row) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    for (final (name, size, desktop) in [
      ('desktop 1280x798', const Size(1280, 798), true),
      ('narrow Windows 1200x800', const Size(1200, 800), true),
      ('tablet 744x954', const Size(744, 954), false),
      ('small tablet 600x960', const Size(600, 960), false),
      ('tablet landscape 1194x744', const Size(1194, 744), false),
      ('mobile 393x852', const Size(393, 852), false),
      ('small phone 360x640', const Size(360, 640), false),
    ]) {
      testWidgets('shows the referrals without overflow: $name', (tester) async {
        await openProfile(tester, size, desktop, 1);
        final entry = Get.find<QueueController>().pageEntries[1];

        await tester.tap(find.text('Lab referrals'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.labReferrals);
        // Patient header and tabs stay; the other tabs' cards are gone.
        expect(find.text(entry.patient), findsWidgets);
        expect(find.text('Demographics'), findsNothing);
        expect(find.text('Visit history'), findsNothing);
        expect(find.text('Lab Referrals'), findsOneWidget);
        expect(
          find.text('View laboratory referrals and sample collection information for this patient.'),
          findsOneWidget,
        );
        expect(find.text('Full Blood Count'), findsOneWidget);
        expect(find.text('Lipid Profile'), findsOneWidget);
        expect(find.text('27 Oct 2026'), findsOneWidget);
        expect(find.text('12 Aug 2026'), findsOneWidget);
        expect(find.text('Dr Thandi Nkosi'), findsWidgets);
        expect(find.text('Requested'), findsOneWidget);
        expect(find.text('Result Received'), findsOneWidget);
        expect(find.text('View Details'), findsNWidgets(2));
        expect(find.text('Start triage'), findsOneWidget);
      });
    }

    testWidgets('tabs switch among all three', (tester) async {
      await openProfile(tester, const Size(1280, 1100), true, 0);
      final c = Get.find<NursePatientProfileController>();

      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      expect(c.tab.value, NurseProfileTab.labReferrals);

      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();
      expect(find.text('Visit history'), findsOneWidget);
      expect(find.text('Lab Referrals'), findsNothing);

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      expect(c.tab.value, NurseProfileTab.overview);
      expect(find.text('Demographics'), findsOneWidget);
    });

    testWidgets('desktop: View Details sits at the left edge of its Action column', (tester) async {
      await openProfile(tester, const Size(1280, 1100), true, 1);
      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      final labelLeft = tester.getTopLeft(find.text('Action')).dx;
      for (final link in tester.widgetList<Text>(find.text('View Details')).toList().asMap().keys) {
        final left = tester.getTopLeft(find.text('View Details').at(link)).dx;
        expect(left, closeTo(labelLeft, 1));
      }
    });

    testWidgets('phone: View Details ends at the right edge of the card', (tester) async {
      await openProfile(tester, const Size(393, 852), false, 1);
      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      final scrollable = find
          .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
          .first;
      await tester.dragUntilVisible(find.text('View Details').last, scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      final button = find.ancestor(of: find.text('View Details').first, matching: find.byType(SizedBox)).first;
      final box = tester.getBottomRight(button).dx;
      expect(box, closeTo(393 - 16 - 16, 1.5)); // page margin + card padding
    });

    testWidgets('empty state displays when patient has no lab referrals: desktop, tablet, mobile', (tester) async {
      for (final (size, desktop) in [
        (const Size(1280, 800), true),
        (const Size(744, 954), false),
        (const Size(393, 852), false),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        ResponsiveHelper.debugIsDesktopPlatformOverride = desktop;

        final emptyProfile = NursePatientProfile.fromQueueEntry(
          const QueueEntry(
            number: 'Q099',
            patient: 'John Smith',
            arrival: '08:42',
            waitingMinutes: 24,
            reason: 'Headache',
            priority: QueuePriority.routine,
            status: QueueStatus.waiting,
            demographics: '42/M',
          ),
        );
        expect(emptyProfile.labReferrals, isEmpty);

        await RoleController.to.switchRole(ClinicRole.nurse);
        Get.delete<NursePatientProfileController>(force: true);
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light(),
            getPages: AppPages.pages,
            home: GetBuilder<NursePatientProfileController>(
              init: NursePatientProfileController(profile: emptyProfile),
              builder: (_) => const NursePatientProfileView(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lab referrals'));
        await tester.pumpAndSettle();

        expect(find.text('No lab referrals found'), findsOneWidget);
        expect(
          find.text('No laboratory referrals have been recorded for this patient.'),
          findsOneWidget,
        );
        expect(find.byIcon(AppIcons.file), findsOneWidget);
        expect(find.text('Full Blood Count'), findsNothing);
        expect(find.text('View Details'), findsNothing);

        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();
      }
    });
  });
}

void _viewTriageTests() {
  group('View triage', () {
    Future<void> openHistory(WidgetTester tester, Size size, bool desktop) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(0);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();
      final link = find.text('View triage');
      if (link.evaluate().isEmpty) {
        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(link, scrollable, const Offset(0, -300));
      }
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    void expectTriageContent() {
      expect(find.text('Triage · 12 Aug 2026'), findsOneWidget);
      expect(find.text('Recorded by Sister Naledi Naidoo'), findsOneWidget);
      expect(find.text('Read only'), findsWidgets);
      expect(find.text('Routine'), findsWidgets);
      expect(find.text('Presenting complaint'), findsOneWidget);
      expect(find.text('Routine check'), findsWidgets);
      expect(find.text('Vital signs (previous)'), findsOneWidget);
      for (final v in ['124/80 mmHg', '72 bpm', '36.6 °C', '77 kg', '176 cm', '24.9 kg/m²', '5.1 mmol/L', '98 %']) {
        expect(find.text(v), findsOneWidget, reason: v);
      }
      expect(find.text('Triage notes'), findsOneWidget);
      expect(find.text('Routine check. No concerns recorded.'), findsOneWidget);
    }

    for (final (name, size) in [
      ('desktop 1280x969', const Size(1280, 969)),
      ('narrow Windows 1200x700', const Size(1200, 700)),
    ]) {
      testWidgets('desktop opens a drawer, Close returns to the history: $name', (tester) async {
        await openHistory(tester, size, true);
        expect(tester.takeException(), isNull);
        expectTriageContent();
        expect(find.text('Close'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Triage · 12 Aug 2026'), findsNothing);
        expect(find.text('Visit history'), findsOneWidget);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.clinicalHistory);
      });
    }

    testWidgets('desktop drawer closes with its X button', (tester) async {
      await openHistory(tester, const Size(1280, 969), true);
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();
      expect(find.text('Triage · 12 Aug 2026'), findsNothing);
    });

    for (final (name, size) in [
      ('tablet 744x905', const Size(744, 905)),
      ('small tablet 600x960', const Size(600, 960)),
      ('tablet landscape 1194x744', const Size(1194, 744)),
    ]) {
      testWidgets('tablet opens a full page and back returns to the history: $name', (tester) async {
        await openHistory(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nurseTriageDetail);
        expectTriageContent();
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Start triage'), findsNothing);
        expect(find.text('Vitals / Triage'), findsNothing); // navigation bar hidden on tablet and mobile

        await tester.tap(find.byIcon(AppIcons.chevronLeft));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expect(find.text('Triage · 12 Aug 2026'), findsNothing);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.clinicalHistory);
      });
    }

    for (final (name, size) in [
      ('mobile 393x852', const Size(393, 852)),
      ('small phone 360x640', const Size(360, 640)),
    ]) {
      testWidgets('phone opens a sheet with Cancel only: $name', (tester) async {
        await openHistory(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expect(find.text('Triage · 12 Aug 2026'), findsOneWidget);
        // The sheet scrolls, so check the content is reachable.
        final sheetScroll = find.descendant(of: find.byType(BottomSheet), matching: find.byType(Scrollable)).first;
        await tester.dragUntilVisible(find.text('Routine check. No concerns recorded.'), sheetScroll, const Offset(0, -200));
        expectTriageContent();
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Call patient'), findsNothing);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Triage · 12 Aug 2026'), findsNothing);
        expect(find.text('Visit history'), findsOneWidget);
      });
    }

    test('the triage belongs to the patient and visit it was opened from', () {
      const entry = QueueEntry(
        number: 'Q017',
        patient: 'Amahle Khumalo',
        arrival: '09:27',
        waitingMinutes: 7,
        reason: 'Prescription follow-up',
        priority: QueuePriority.routine,
        status: QueueStatus.waiting,
      );
      final p = NursePatientProfile.fromQueueEntry(entry);
      final r = p.triageFor(p.visits.last);
      expect(r.patientName, 'Amahle Khumalo');
      expect(r.queueNumber, 'Q017');
      expect(r.title, 'Triage · 12 Aug 2026');
      expect(r.subtitle, 'Recorded by Sister Naledi Naidoo');
      expect(r.complaint, 'Routine check');
    });

    test('only the Nurse can open the triage page', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.nurseTriageDetail)?.name, AppRoutes.dashboard);
      await RoleController.to.switchRole(ClinicRole.nurse);
      expect(guard.redirect(AppRoutes.nurseTriageDetail), isNull);
    });

    testWidgets('tapping Read only badge in Clinical records opens triage drawer', (tester) async {
      await _CallHost.pump(tester, size: const Size(1280, 969), desktop: true);
      final menu = find.byType(QueueRowMenu).at(0);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();

      final readOnlyBadge = find.byType(ProfileReadOnlyBadge).first;
      await tester.ensureVisible(readOnlyBadge);
      await tester.tap(readOnlyBadge);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expectTriageContent();
      expect(find.text('Close'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Triage · 12 Aug 2026'), findsNothing);
    });
  });
}

void _consultationsTests() {
  group('View consultations', () {
    Future<void> openConsultations(WidgetTester tester, Size size, bool desktop, {int row = 0}) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();
      final link = find.text('View consultations');
      final scrollable = find
          .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
          .first;
      await tester.dragUntilVisible(link, scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    String subtitle() {
      final p = Get.find<NursePatientProfileController>().profile;
      return '${p.name} · ${p.patientId} · Read only';
    }

    void expectEmptyState() {
      expect(find.text(subtitle()), findsOneWidget);
      expect(find.text('No consultations recorded for this patient'), findsOneWidget);
      expect(
        find.text('Consultation notes are added by the doctor and are read only for nurses.'),
        findsOneWidget,
      );
      expect(find.byIcon(AppIcons.file), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    }

    for (final (name, size) in [
      ('desktop 1280x969', const Size(1280, 969)),
      ('narrow Windows 1200x700', const Size(1200, 700)),
    ]) {
      testWidgets('desktop opens a drawer for the tapped patient: $name', (tester) async {
        await openConsultations(tester, size, true, row: 1);
        expect(tester.takeException(), isNull);
        expectEmptyState();
        expect(Get.find<NursePatientProfileController>().profile.name, Get.find<QueueController>().pageEntries[1].patient);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('No consultations recorded for this patient'), findsNothing);
        expect(find.text('Visit history'), findsOneWidget);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.clinicalHistory);
      });
    }

    testWidgets('desktop drawer closes with its X button', (tester) async {
      await openConsultations(tester, const Size(1280, 969), true);
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();
      expect(find.text('No consultations recorded for this patient'), findsNothing);
    });

    for (final (name, size) in [
      ('tablet 744x906', const Size(744, 906)),
      ('small tablet 600x960', const Size(600, 960)),
      ('tablet landscape 1194x744', const Size(1194, 744)),
    ]) {
      testWidgets('tablet opens a page; Close and back return to the history: $name', (tester) async {
        await openConsultations(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nurseConsultations);
        expectEmptyState();
        expect(find.text('Vitals / Triage'), findsNothing); // navigation bar hidden on tablet and mobile
        expect(find.text('Start triage'), findsNothing);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.clinicalHistory);

        // Back arrow does the same.
        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(find.text('View consultations'), scrollable, const Offset(0, -300));
        await tester.tap(find.text('View consultations'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.byIcon(AppIcons.chevronLeft));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
      });
    }

    for (final (name, size) in [
      ('mobile 393x852', const Size(393, 852)),
      ('small phone 360x640', const Size(360, 640)),
    ]) {
      testWidgets('phone opens a sheet with Close: $name', (tester) async {
        await openConsultations(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expectEmptyState();
        expect(find.text('Cancel'), findsNothing);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('No consultations recorded for this patient'), findsNothing);
        expect(find.text('Visit history'), findsOneWidget);
      });
    }

    test('only the Nurse can open the consultations page', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.nurseConsultations)?.name, AppRoutes.dashboard);
      await RoleController.to.switchRole(ClinicRole.nurse);
      expect(guard.redirect(AppRoutes.nurseConsultations), isNull);
    });
  });
}

void _prescriptionsTests() {
  group('View Prescription', () {
    Future<void> openPrescriptions(WidgetTester tester, Size size, bool desktop, {int row = 0}) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Clinical History'));
      await tester.pumpAndSettle();
      final link = find.text('View Prescription');
      final scrollable = find
          .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
          .first;
      await tester.dragUntilVisible(link, scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    void expectEmptyState() {
      final p = Get.find<NursePatientProfileController>().profile;
      expect(find.text('${p.name} · ${p.patientId} · Read only'), findsOneWidget);
      expect(find.text('No prescriptions recorded for this patient'), findsOneWidget);
      expect(find.text('Prescriptions are issued by the doctor and are read only for nurses.'), findsOneWidget);
      expect(find.text('No consultations recorded for this patient'), findsNothing);
      expect(find.byIcon(AppIcons.file), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    }

    for (final (name, size) in [
      ('desktop 1280x969', const Size(1280, 969)),
      ('narrow Windows 1200x700', const Size(1200, 700)),
    ]) {
      testWidgets('desktop opens a drawer for the tapped patient: $name', (tester) async {
        await openPrescriptions(tester, size, true, row: 1);
        expect(tester.takeException(), isNull);
        expectEmptyState();
        expect(Get.find<NursePatientProfileController>().profile.name, Get.find<QueueController>().pageEntries[1].patient);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('No prescriptions recorded for this patient'), findsNothing);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.clinicalHistory);
      });
    }

    for (final (name, size) in [
      ('tablet 744x906', const Size(744, 906)),
      ('small tablet 600x960', const Size(600, 960)),
      ('tablet landscape 1194x744', const Size(1194, 744)),
    ]) {
      testWidgets('tablet opens a page; Close and back return to the history: $name', (tester) async {
        await openPrescriptions(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nursePrescriptions);
        expectEmptyState();
        expect(find.text('Vitals / Triage'), findsNothing); // navigation bar hidden on tablet and mobile

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);

        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(find.text('View Prescription'), scrollable, const Offset(0, -300));
        await tester.tap(find.text('View Prescription'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.byIcon(AppIcons.chevronLeft));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
      });
    }

    for (final (name, size) in [
      ('mobile 393x852', const Size(393, 852)),
      ('small phone 360x640', const Size(360, 640)),
    ]) {
      testWidgets('phone opens a sheet with Close: $name', (tester) async {
        await openPrescriptions(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expectEmptyState();
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('No prescriptions recorded for this patient'), findsNothing);
        expect(find.text('Visit history'), findsOneWidget);
      });
    }

    testWidgets('Consultations and Prescriptions open their own views', (tester) async {
      await openPrescriptions(tester, const Size(1280, 969), true);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View consultations'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('No consultations recorded for this patient'), findsOneWidget);
      expect(find.text('No prescriptions recorded for this patient'), findsNothing);
    });

    test('only the Nurse can open the prescriptions page', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.nursePrescriptions)?.name, AppRoutes.dashboard);
      await RoleController.to.switchRole(ClinicRole.nurse);
      expect(guard.redirect(AppRoutes.nursePrescriptions), isNull);
    });
  });
}

void _labReferralDetailTests() {
  group('Lab Referral Details', () {
    Future<void> openReferral(WidgetTester tester, Size size, bool desktop, {int row = 1, int referral = 0}) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      final link = find.text('View Details').at(referral);
      final scrollable = find
          .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
          .first;
      await tester.dragUntilVisible(link, scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    void expectDetails({
      String test = 'Full Blood Count',
      String date = '27 Oct 2026',
      String status = 'Requested',
      bool result = false,
    }) {
      final p = Get.find<NursePatientProfileController>().profile;
      expect(find.text('Lab Referral Details'), findsOneWidget);
      expect(find.text('$test · $date'), findsOneWidget);
      for (final label in [
        'Patient Name',
        'Patient ID',
        'Requested Test',
        'Referral Date',
        'Requesting Practitioner',
        'Referral Status',
      ]) {
        // "Referral Date" is also a column or field label in the list underneath.
        expect(find.text(label), label == 'Referral Date' ? findsWidgets : findsOneWidget, reason: label);
      }
      expect(find.text(p.name), findsWidgets);
      expect(find.text(p.patientId), findsOneWidget);
      expect(find.text(status), findsWidgets);
      expect(find.text('Close'), findsOneWidget);
      // A referral with a result offers View Results and the result document;
      // one without offers Record Sample.
      expect(find.text('Record Sample'), result ? findsNothing : findsOneWidget);
      expect(find.text('View Results'), result ? findsOneWidget : findsNothing);
      expect(find.text('Result document'), result ? findsOneWidget : findsNothing);
      expect(find.text('Read only'), result ? findsWidgets : findsNothing);
    }

    for (final (name, size) in [
      ('desktop 1280x861', const Size(1280, 861)),
      ('narrow Windows 1200x700', const Size(1200, 700)),
    ]) {
      testWidgets('desktop opens a drawer for the selected referral: $name', (tester) async {
        await openReferral(tester, size, true, row: 1);
        expect(tester.takeException(), isNull);
        expectDetails();
        final queueEntry = Get.find<QueueController>().pageEntries[1];
        expect(Get.find<NursePatientProfileController>().profile.name, queueEntry.patient);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Lab Referral Details'), findsNothing);
        expect(find.text('Lab Referrals'), findsOneWidget);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.labReferrals);
      });
    }

    testWidgets('the second referral opens its own details', (tester) async {
      await openReferral(tester, const Size(1280, 861), true, referral: 1);
      expectDetails(test: 'Lipid Profile', date: '12 Aug 2026', status: 'Result Received', result: true);
    });

    testWidgets('desktop drawer closes with its X button', (tester) async {
      await openReferral(tester, const Size(1280, 861), true);
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();
      expect(find.text('Lab Referral Details'), findsNothing);
    });

    for (final (name, size) in [
      ('tablet 744x927', const Size(744, 927)),
      ('small tablet 600x960', const Size(600, 960)),
      ('tablet landscape 1194x744', const Size(1194, 744)),
    ]) {
      testWidgets('tablet opens a page; Close and back return to Lab referrals: $name', (tester) async {
        await openReferral(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nurseLabReferral);
        expectDetails();
        expect(find.text('Vitals / Triage'), findsNothing); // navigation bar hidden

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.labReferrals);

        final scrollable = find
            .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
            .first;
        await tester.dragUntilVisible(find.text('View Details').first, scrollable, const Offset(0, -300));
        await tester.tap(find.text('View Details').first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.byIcon(AppIcons.chevronLeft));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expect(find.text('Lab Referrals'), findsOneWidget);
      });
    }

    for (final (name, size) in [
      ('mobile 393x852', const Size(393, 852)),
      ('small phone 360x640', const Size(360, 640)),
    ]) {
      testWidgets('phone opens a sheet with Close and Record Sample: $name', (tester) async {
        await openReferral(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        expectDetails();
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Lab Referral Details'), findsNothing);
        expect(find.text('Lab Referrals'), findsOneWidget);
      });
    }

    test('the detail belongs to the patient and referral it was opened from', () {
      const entry = QueueEntry(
        number: 'Q017',
        patient: 'Amahle Khumalo',
        arrival: '09:27',
        waitingMinutes: 7,
        reason: 'Prescription follow-up',
        priority: QueuePriority.routine,
        status: QueueStatus.waiting,
      );
      final p = NursePatientProfile.fromQueueEntry(entry);
      final d = p.labReferralDetail(p.labReferrals.last);
      expect(d.patientName, 'Amahle Khumalo');
      expect(d.patientId, 'TND-000017');
      expect(d.subtitle, 'Lipid Profile · 12 Aug 2026');
      expect(d.referral.status, LabReferralStatus.resultReceived);
    });

    test('only the Nurse can open the referral page', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.nurseLabReferral)?.name, AppRoutes.dashboard);
      await RoleController.to.switchRole(ClinicRole.nurse);
      expect(guard.redirect(AppRoutes.nurseLabReferral), isNull);
    });
  });
}

void _recordSampleTests() {
  group('Record Sample', () {
    Future<void> openForm(WidgetTester tester, Size size, bool desktop, {int row = 1, int referral = 0}) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(row);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      final link = find.text('View Details').at(referral);
      final scrollable = find
          .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
          .first;
      await tester.dragUntilVisible(link, scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Record Sample'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    RecordSampleController form() => Get.find<RecordSampleController>();

    Finder inForm(String text) =>
        find.descendant(of: find.byType(RecordSampleForm), matching: find.text(text));

    void expectForm({String test = 'Full Blood Count', String date = '27 Oct 2026'}) {
      final p = Get.find<NursePatientProfileController>().profile;
      expect(find.text('Record Sample'), findsWidgets);
      expect(find.text('$test · $date'), findsWidgets);
      for (final label in ['Patient Name', 'Patient ID', 'Requested Test']) {
        expect(inForm(label), findsOneWidget, reason: label);
      }
      expect(inForm(p.name), findsOneWidget);
      expect(inForm(p.patientId), findsOneWidget);
      expect(inForm('Sample collection'), findsOneWidget);
      expect(inForm('Sample collection date'), findsOneWidget);
      expect(inForm('Sample collection time'), findsOneWidget);
      expect(inForm('Sample collection status'), findsOneWidget);
      expect(inForm('09:30'), findsOneWidget);
      expect(inForm('Sample Taken'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Sample'), findsOneWidget);
    }

    for (final (name, size) in [
      ('desktop 1280x861', const Size(1280, 861)),
      ('narrow Windows 1200x700', const Size(1200, 700)),
    ]) {
      testWidgets('desktop opens the form over the referral drawer: $name', (tester) async {
        await openForm(tester, size, true, row: 1);
        expect(tester.takeException(), isNull);
        expectForm();
        expect(form().detail.patientName, Get.find<QueueController>().pageEntries[1].patient);
        expect(form().date.value, DateTime(2026, 10, 27)); // defaults to the referral date

        // Cancel closes only the form: the Lab Referral Details drawer is still there.
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Save Sample'), findsNothing);
        expect(find.text('Lab Referral Details'), findsOneWidget);
        expect(Get.isRegistered<RecordSampleController>(), isFalse);
      });
    }

    testWidgets('X closes the form and returns to the referral details', (tester) async {
      await openForm(tester, const Size(1280, 861), true);
      await tester.tap(find.byIcon(AppIcons.close).last);
      await tester.pumpAndSettle();
      expect(find.text('Save Sample'), findsNothing);
      expect(find.text('Lab Referral Details'), findsOneWidget);
    });

    testWidgets('the status field opens its options', (tester) async {
      await openForm(tester, const Size(1280, 861), true);
      await tester.tap(inForm('Sample Taken'));
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuItem<String>), findsOneWidget);
      await tester.tap(find.byType(PopupMenuItem<String>));
      await tester.pumpAndSettle();
      expect(form().status.value, 'Sample Taken');
    });

    testWidgets('the date and time fields open pickers and keep the value when cancelled', (tester) async {
      await openForm(tester, const Size(1280, 861), true);
      await tester.tap(inForm('27 Oct 2026').last);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(DatePickerDialog), matching: find.text('Cancel')));
      await tester.pumpAndSettle();
      expect(form().date.value, DateTime(2026, 10, 27));

      await tester.tap(inForm('09:30'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(TimePickerDialog), matching: find.text('Cancel')));
      await tester.pumpAndSettle();
      expect(form().timeLabel, '09:30');
    });

    testWidgets('validation: a date before the referral date is rejected and values are kept', (tester) async {
      await openForm(tester, const Size(1280, 861), true);
      form().date.value = DateTime(2026, 10, 20);
      form().time.value = const TimeOfDay(hour: 14, minute: 5);
      await tester.pump();

      await tester.tap(find.text('Save Sample'));
      await tester.pump();
      expect(find.text('The collection date can’t be before the referral date.'), findsOneWidget);
      // Nothing was claimed as saved, and the entered values are still there.
      expect(find.textContaining('Nothing was recorded'), findsNothing);
      expect(form().dateLabel, '20 Oct 2026');
      expect(form().timeLabel, '14:05');
      expect(inForm('14:05'), findsOneWidget);

      // Fixing the date clears the error.
      form().date.value = DateTime(2026, 10, 27);
      await tester.tap(find.text('Save Sample'));
      await tester.pump();
      expect(find.text('The collection date can’t be before the referral date.'), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('Save Sample saves the sample and displays Lab Referral Details with result', (tester) async {
      await openForm(tester, const Size(1280, 861), true);
      form().time.value = const TimeOfDay(hour: 11, minute: 45);
      await tester.pump();

      await tester.tap(find.text('Save Sample'));
      await tester.pumpAndSettle();
      expect(find.text('Save Sample'), findsNothing);
      expect(find.text('Lab Referral Details'), findsOneWidget);
      expect(find.text('Result Received'), findsWidgets);
      expect(find.text('Result document'), findsOneWidget);
      expect(find.text('View Results'), findsOneWidget);
    });

    test('a second submit while one is running is ignored', () async {
      final c = RecordSampleController(
        detail: const LabReferralDetail(
          patientName: 'A',
          patientId: 'TND-000001',
          referral: LabReferral(
            test: 'Full Blood Count',
            date: '27 Oct 2026',
            requestedBy: 'Dr Thandi Nkosi',
            status: LabReferralStatus.requested,
          ),
        ),
      );
      c.isSaving.value = true;
      expect(await c.submit(), isNull);
      expect(c.dateError.value, isNull); // not even validated while busy
    });

    test('parseShortDate reads the app date format', () {
      expect(RecordSampleController.parseShortDate('27 Oct 2026'), DateTime(2026, 10, 27));
      expect(RecordSampleController.parseShortDate('1 Jan 2027'), DateTime(2027, 1, 1));
      expect(RecordSampleController.parseShortDate('soon'), isNull);
      expect(RecordSampleController.parseShortDate('27 Foo 2026'), isNull);
    });

    for (final (name, size) in [
      ('tablet 744x927', const Size(744, 927)),
      ('small tablet 600x960', const Size(600, 960)),
      ('tablet landscape 1194x744', const Size(1194, 744)),
    ]) {
      testWidgets('tablet opens a page; Cancel and back return to the referral details: $name', (tester) async {
        await openForm(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nurseRecordSample);
        expectForm();
        expect(find.text('Vitals / Triage'), findsNothing); // navigation bar hidden
        form().time.value = const TimeOfDay(hour: 14, minute: 5);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nurseLabReferral);
        expect(find.text('Lab Referral Details'), findsOneWidget);

        // Reopening gives a fresh form, not the earlier edits.
        await tester.tap(find.text('Record Sample'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(form().timeLabel, '09:30');
        await tester.tap(find.byIcon(AppIcons.chevronLeft));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(Get.currentRoute, AppRoutes.nurseLabReferral);
      });
    }

    for (final (name, size) in [
      ('mobile 393x852', const Size(393, 852)),
      ('small phone 360x640', const Size(360, 640)),
    ]) {
      testWidgets('phone opens a sheet over the referral sheet: $name', (tester) async {
        await openForm(tester, size, false);
        expect(tester.takeException(), isNull);
        expect(Get.currentRoute, AppRoutes.nursePatientProfile);
        final sheetScroll = find.descendant(of: find.byType(BottomSheet), matching: find.byType(Scrollable)).first;
        await tester.dragUntilVisible(inForm('Sample collection status'), sheetScroll, const Offset(0, -200));
        expectForm();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Save Sample'), findsNothing);
        expect(find.text('Lab Referral Details'), findsOneWidget);
      });
    }

    test('only the Nurse can open the form page', () async {
      final guard = RoleGuard();
      expect(guard.redirect(AppRoutes.nurseRecordSample)?.name, AppRoutes.dashboard);
      await RoleController.to.switchRole(ClinicRole.nurse);
      expect(guard.redirect(AppRoutes.nurseRecordSample), isNull);
    });
  });
}

void _labResultTests() {
  group('Lab Referral Details with a result', () {
    Future<void> openResult(WidgetTester tester, Size size, bool desktop) async {
      await _CallHost.pump(tester, size: size, desktop: desktop);
      final menu = find.byType(QueueRowMenu).at(1);
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      final link = find.text('View Details').at(1); // Lipid Profile, Result Received
      final scrollable = find
          .descendant(of: find.byType(NursePatientProfileView), matching: find.byType(Scrollable))
          .first;
      await tester.dragUntilVisible(link, scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    void expectResultVariant() {
      expect(find.text('Lab Referral Details'), findsOneWidget);
      expect(find.text('Lipid Profile · 12 Aug 2026'), findsOneWidget);
      expect(find.text('Read only'), findsWidgets);
      expect(find.byIcon(AppIcons.lock), findsOneWidget);
      expect(find.text('Result Received'), findsWidgets);
      expect(find.text('Result document'), findsOneWidget);
      expect(find.text('Lipid Profile result'), findsOneWidget);
      expect(find.byIcon(AppIcons.fileText), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('View Results'), findsOneWidget);
      expect(find.text('Record Sample'), findsNothing);
      // No results-entry form or dropdown exists in these designs.
      expect(find.text('Save Results'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    }

    for (final (name, size, desktop) in [
      ('desktop 1280x861', const Size(1280, 861), true),
      ('narrow Windows 1200x700', const Size(1200, 700), true),
      ('tablet 744x863', const Size(744, 863), false),
      ('small tablet 600x960', const Size(600, 960), false),
      ('tablet landscape 1194x744', const Size(1194, 744), false),
      ('mobile 393x852', const Size(393, 852), false),
      ('small phone 360x640', const Size(360, 640), false),
    ]) {
      testWidgets('shows the result variant without overflow: $name', (tester) async {
        await openResult(tester, size, desktop);
        expect(tester.takeException(), isNull);
        expectResultVariant();
        final p = Get.find<NursePatientProfileController>().profile;
        expect(find.text(p.patientId), findsOneWidget);
      });
    }

    testWidgets('the result document link and View Results open Result Document screen and back returns to lab referrals', (tester) async {
      await openResult(tester, const Size(1280, 861), true);
      // Tapping the document link opens the Result Document view
      await tester.tap(find.text('Lipid Profile result'));
      await tester.pumpAndSettle();
      expect(find.text('Result Document'), findsOneWidget);
      expect(find.text('Document preview unavailable'), findsOneWidget);
      expect(find.text('The source result document was not supplied. No report content is available to preview.'), findsOneWidget);
      expect(find.text('Back to Referral'), findsOneWidget);

      // Back to Referral returns directly to Lab referrals page with empty state
      await tester.tap(find.text('Back to Referral'));
      await tester.pumpAndSettle();
      expect(find.text('Result Document'), findsNothing);
      expect(find.text('Lab Referrals'), findsOneWidget);
      expect(find.text('No lab referrals found'), findsOneWidget);
      expect(find.text('No laboratory referrals have been recorded for this patient.'), findsOneWidget);
    });

    testWidgets('tablet: View Results opens Result Document without bottom navigation', (tester) async {
      await openResult(tester, const Size(744, 863), false);
      expect(Get.currentRoute, AppRoutes.nurseLabReferral);
      expect(find.byType(AppBottomNavigation), findsNothing);

      await tester.tap(find.text('View Results'));
      await tester.pumpAndSettle();
      expect(find.text('Result Document'), findsOneWidget);
      expect(find.text('Document preview unavailable'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);

      await tester.tap(find.text('Back to Referral'));
      await tester.pumpAndSettle();
      expect(find.text('Result Document'), findsNothing);
      expect(find.text('Lab Referrals'), findsOneWidget);
      expect(find.text('No lab referrals found'), findsOneWidget);
      expect(find.text('No laboratory referrals have been recorded for this patient.'), findsOneWidget);
    });

    testWidgets('the Result document dropdown starts open and collapses and expands', (tester) async {
      await openResult(tester, const Size(1280, 861), true);
      expect(find.text('Lipid Profile result'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.text('Result document'));
      await tester.pumpAndSettle();
      expect(find.text('Lipid Profile result'), findsNothing);
      expect(find.text('Result document'), findsOneWidget);

      await tester.tap(find.text('Result document'));
      await tester.pumpAndSettle();
      expect(find.text('Lipid Profile result'), findsOneWidget);
    });

    testWidgets('Close returns to Lab referrals; tablet back does too', (tester) async {
      await openResult(tester, const Size(744, 863), false);
      expect(Get.currentRoute, AppRoutes.nurseLabReferral);
      await tester.tap(find.byIcon(AppIcons.chevronLeft));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(Get.currentRoute, AppRoutes.nursePatientProfile);
      expect(Get.find<NursePatientProfileController>().tab.value, NurseProfileTab.labReferrals);
    });

    testWidgets('the Requested referral still offers Record Sample and no result document', (tester) async {
      await _CallHost.pump(tester, size: const Size(1280, 861), desktop: true);
      final menu = find.byType(QueueRowMenu).at(1);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Patient'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Lab referrals'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Details').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Record Sample'), findsOneWidget);
      expect(find.text('Result document'), findsNothing);
      expect(find.text('View Results'), findsNothing);
    });
  });
}
