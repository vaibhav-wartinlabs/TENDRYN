import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/features/lab_results/bindings/lab_result_details_binding.dart';
import 'package:tendryn/features/lab_results/controllers/lab_result_details_controller.dart';
import 'package:tendryn/features/lab_results/controllers/lab_results_controller.dart';
import 'package:tendryn/features/lab_results/views/lab_result_details_view.dart';
import 'package:tendryn/features/lab_results/views/lab_results_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/features/lab_results/models/lab_result_model.dart';
import 'package:tendryn/features/lab_results/widgets/lab_result_drawer.dart';

class _FakeConnectivityService extends GetxService implements ConnectivityService {
  @override
  final isOnline = true.obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put<ConnectivityService>(_FakeConnectivityService(), permanent: true);
    final role = Get.put(RoleController(), permanent: true);
    role.currentRole.value = ClinicRole.doctor;
    Get.put(LabResultsController());
  });

  tearDown(() {
    Get.reset();
    ResponsiveHelper.debugIsDesktopPlatformOverride = null;
  });

  testWidgets('Desktop view renders page header, tabs, search, and seed table rows', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lab Results'), findsWidgets);
    expect(find.text('Review patient test results and track lab referrals.'), findsOneWidget);
    expect(find.text('Lab Referrals'), findsOneWidget);
    expect(find.text('All lab results'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Folder #SWC-10427'), findsOneWidget);
    expect(find.text('Full blood count'), findsWidgets);
    expect(find.text('Nomsa Dlamini'), findsOneWidget);
    expect(find.text('Sipho Khumalo'), findsOneWidget);
    expect(find.text('Lerato Maseko'), findsOneWidget);
    expect(find.text('Awaiting review'), findsWidgets);
    expect(find.text('Reviewed'), findsWidgets);
  });

  testWidgets('Three dots action menu View details navigates to labResultDetails route', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.labResults,
        getPages: [
          GetPage(
            name: AppRoutes.labResults,
            page: () => const Scaffold(body: LabResultsView()),
          ),
          GetPage(
            name: AppRoutes.labResultDetails,
            page: () => const Scaffold(body: Text('Lab Result Details Page')),
            binding: LabResultDetailsBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final actionButtons = find.byTooltip('Actions');
    expect(actionButtons, findsWidgets);

    // Tap first action button
    await tester.tap(actionButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('View details'), findsOneWidget);
    expect(find.text('Record review'), findsOneWidget);

    // Tap View details
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();

    expect(find.text('Lab Result Details Page'), findsOneWidget);
  });

  testWidgets('LabResultDetailsView renders all mockup sections on desktop', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(LabResultDetailsController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabResultDetailsView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify top controls and headers
    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(find.text('Back to Lab Results'), findsOneWidget);
    expect(find.text('View Patient Profile'), findsOneWidget);

    // Verify Patient Card
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('#SWC-10427'), findsOneWidget);
    expect(find.text('740312 5021 087'), findsOneWidget);
    expect(find.text('52 · Male · DOB 12 Mar 1974'), findsOneWidget);

    // Verify Lab Result Card
    expect(find.text('Lab result'), findsOneWidget);
    expect(find.text('Full blood count'), findsWidgets);
    expect(find.text('12 Oct 2026 · 10:15'), findsOneWidget);
    expect(find.text('Soweto NHLS Laboratory'), findsOneWidget);
    expect(find.text('Dr. Maya Naidoo'), findsWidgets);
    expect(find.text('Lab referral · 08 Oct 2026'), findsOneWidget);
    expect(find.text('View referral'), findsOneWidget);

    // Verify Doctor Review Card
    expect(find.text('Doctor review'), findsOneWidget);
    expect(find.text('Awaiting review'), findsOneWidget);
    expect(find.text('Record Review'), findsOneWidget);

    // Verify Result Document Card
    expect(find.text('Result document'), findsOneWidget);
    expect(find.text('2 attachments'), findsOneWidget);
    expect(find.text('Laboratory report · page 1 of 2'), findsOneWidget);
    expect(find.text('Placeholder only no report content shown in design'), findsOneWidget);
    expect(find.text('Report · PDF'), findsOneWidget);
    expect(find.text('Photo · JPG'), findsOneWidget);

    // Switch attachment to image
    await tester.tap(find.text('Photo · JPG'));
    await tester.pumpAndSettle();
    expect(find.text('Specimen photograph · page 1 of 1'), findsOneWidget);
  });

  testWidgets('Tablet view renders cards and tablet pagination', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.labResults,
        getPages: [
          GetPage(
            name: AppRoutes.labResults,
            page: () => const Scaffold(body: LabResultsView()),
          ),
          GetPage(
            name: AppRoutes.labResultDetails,
            page: () => const Scaffold(body: Text('Lab Result Details Page')),
            binding: LabResultDetailsBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lab Results'), findsWidgets);
    expect(find.text('All lab results'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Folder Number'), findsWidgets);
    expect(find.text('#SWC-10427'), findsOneWidget);
    expect(find.text('Full blood count'), findsWidgets);
    expect(find.text('Showing 1–4 of 4 consultations'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Verify 3 dots action menu on tablet card
    final actionButtons = find.byTooltip('Actions');
    expect(actionButtons, findsWidgets);

    await tester.tap(actionButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('View details'), findsOneWidget);
    expect(find.text('Record review'), findsOneWidget);

    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();

    expect(find.text('Lab Result Details Page'), findsOneWidget);
  });

  testWidgets('Mobile view renders single-column cards and navigates on View details', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.labResults,
        getPages: [
          GetPage(
            name: AppRoutes.labResults,
            page: () => const Scaffold(body: LabResultsView()),
          ),
          GetPage(
            name: AppRoutes.labResultDetails,
            page: () => const Scaffold(body: Text('Lab Result Details Page')),
            binding: LabResultDetailsBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search by patient name, folder no.'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('#SWC-10427'), findsOneWidget);
    expect(find.text('Full blood count'), findsWidgets);
    expect(find.text('Showing 1–4 of 4 consultations'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Verify 3 dots action menu on mobile card
    final actionButtons = find.byTooltip('Actions');
    expect(actionButtons, findsWidgets);

    await tester.tap(actionButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('View details'), findsOneWidget);
    expect(find.text('Record review'), findsOneWidget);

    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();

    expect(find.text('Lab Result Details Page'), findsOneWidget);
  });

  testWidgets('LabResultDetailsView renders mockup format on tablet without bottom navigation', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(LabResultDetailsController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabResultDetailsView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify TabletHeader is displayed
    expect(find.byType(TabletHeader), findsOneWidget);

    // Verify bottom navigation is NOT displayed
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Verify boxed back button with chevron
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);

    // Verify header title and subtitle
    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(find.text("Review the patient's laboratory report and related clinical information."), findsOneWidget);

    // Verify Patient and Lab result cards
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Lab result'), findsOneWidget);
    expect(find.text('View referral'), findsOneWidget);

    // Verify Result document card
    expect(find.text('Result document'), findsOneWidget);
    expect(find.text('2 attachments'), findsOneWidget);

    // Verify Doctor review card
    expect(find.text('Doctor review'), findsOneWidget);
    expect(find.text('Awaiting review'), findsOneWidget);
    expect(find.text('Record Review'), findsOneWidget);

    // Verify full-width View Patient Profile button
    expect(find.text('View Patient Profile'), findsOneWidget);
  });

  testWidgets('LabResultDetailsView renders mockup format on mobile without bottom navigation', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(LabResultDetailsController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabResultDetailsView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom navigation is NOT displayed
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Verify boxed back button with chevron
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);

    // Verify header title
    expect(find.text('Lab Result Details'), findsOneWidget);

    // Verify cards are all present
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Lab result'), findsOneWidget);
    expect(find.text('Result document'), findsOneWidget);
    expect(find.text('Doctor review'), findsOneWidget);
    expect(find.text('View Patient Profile'), findsOneWidget);
  });

  testWidgets('Record Review Drawer renders initial state, simulates error on save, retries to success, and completes on Done', (tester) async {
    final sampleResult = LabResultModel(
      id: 'LR-001',
      patientName: 'John Smith',
      folderNumber: 'SWC-10427',
      testName: 'Full blood count',
      category: 'Hematology',
      resultReceivedDate: '12 Oct 2026 · 10:15',
      sampleCollectedDate: '11 Oct 2026 · 14:30',
      orderingDoctor: 'Dr. Maya Naidoo',
      laboratory: 'Soweto NHLS Laboratory',
      status: LabReviewStatus.awaitingReview,
      parameters: const [],
    );

    LabResultModel? finalReviewedResult;
    bool wasClosed = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: LabResultDrawer(
            result: sampleResult,
            simulateSaveError: true,
            onClose: () => wasClosed = true,
            onReviewed: (updated) => finalReviewedResult = updated,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial State (Image 1)
    expect(find.text('Record Review'), findsOneWidget);
    expect(find.text('Confirm you have reviewed this lab result.'), findsOneWidget);
    expect(find.text('Review summary'), findsOneWidget);
    expect(find.text('Awaiting review'), findsOneWidget);
    expect(find.text('Review notes (optional)'), findsOneWidget);
    expect(find.text('Marking as reviewed records your name and the time. It does not change the lab referral status.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Mark as Reviewed'), findsOneWidget);

    // Enter note
    await tester.enterText(find.byType(TextField), 'Patient shows mild anemia. Follow up in 3 months.');
    await tester.pumpAndSettle();

    // Tap Mark as Reviewed -> triggers save failure simulation (Image 3)
    await tester.tap(find.text('Mark as Reviewed'));
    await tester.pumpAndSettle();

    // 2. Error State (Image 3)
    expect(find.text('Review not saved'), findsOneWidget);
    expect(find.text('We could not save your review. Your notes are kept  try again.'), findsOneWidget);
    expect(find.text('Patient shows mild anemia. Follow up in 3 months.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    // Tap Try Again -> transitions to reviewed state (Image 2)
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    // 3. Success State (Image 2)
    expect(find.text('Review recorded for this lab result.'), findsOneWidget);
    expect(find.text('Result marked as reviewed'), findsOneWidget);
    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('The report stays available on the result details page. The lab referral status is not changed by this review.'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done -> finishes review and notifies callback
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(wasClosed, isTrue);
    expect(finalReviewedResult, isNotNull);
    expect(finalReviewedResult!.status, equals(LabReviewStatus.reviewed));
    expect(finalReviewedResult!.reviewedBy, equals('Dr. Maya Naidoo'));
  });

  testWidgets('showLabResultDrawer opens mobile bottom sheet modal and completes review lifecycle', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sampleResult = LabResultModel(
      id: 'LR-001',
      patientName: 'John Smith',
      folderNumber: 'SWC-10427',
      testName: 'Full blood count',
      category: 'Hematology',
      resultReceivedDate: '12 Oct 2026 · 10:15',
      sampleCollectedDate: '11 Oct 2026 · 14:30',
      orderingDoctor: 'Dr. Maya Naidoo',
      laboratory: 'Soweto NHLS Laboratory',
      status: LabReviewStatus.awaitingReview,
      parameters: const [],
    );

    LabResultModel? reviewedResult;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showLabResultDrawer(
                    context,
                    result: sampleResult,
                    simulateSaveError: true,
                    onReviewed: (updated) => reviewedResult = updated,
                  );
                },
                child: const Text('Open Review'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap to open bottom sheet
    await tester.tap(find.text('Open Review'));
    await tester.pumpAndSettle();

    // Verify modal bottom sheet header & close icon
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Record Review'), findsOneWidget);
    expect(find.text('Confirm you have reviewed this lab result.'), findsOneWidget);

    // Initial state: notes & cancel / mark as reviewed
    expect(find.text('Review notes (optional)'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Mark as Reviewed'), findsOneWidget);

    // Tap Mark as Reviewed -> triggers save error
    await tester.tap(find.text('Mark as Reviewed'));
    await tester.pumpAndSettle();

    expect(find.text('Review not saved'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    // Tap Try Again -> transitions to reviewed success state
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text('Result marked as reviewed'), findsOneWidget);
    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done -> finishes review, updates callback and dismisses sheet
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(reviewedResult?.status, equals(LabReviewStatus.reviewed));
    expect(find.text('Record Review'), findsNothing); // Sheet is closed
  });

  testWidgets('showLabResultDrawer opens tablet page inside AppShell and completes review lifecycle', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sampleResult = LabResultModel(
      id: 'LR-001',
      patientName: 'John Smith',
      folderNumber: 'SWC-10427',
      testName: 'Full blood count',
      category: 'Hematology',
      resultReceivedDate: '12 Oct 2026 · 10:15',
      sampleCollectedDate: '11 Oct 2026 · 14:30',
      orderingDoctor: 'Dr. Maya Naidoo',
      laboratory: 'Soweto NHLS Laboratory',
      status: LabReviewStatus.awaitingReview,
      parameters: const [],
    );

    LabResultModel? reviewedResult;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showLabResultDrawer(
                    context,
                    result: sampleResult,
                    simulateSaveError: true,
                    onReviewed: (updated) => reviewedResult = updated,
                  );
                },
                child: const Text('Open Review'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap to open tablet page
    await tester.tap(find.text('Open Review'));
    await tester.pumpAndSettle();

    // Verify tablet bottom navigation is NOT displayed
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Verify boxed back button on tablet header
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);
    expect(find.text('Record Review'), findsOneWidget);
    expect(find.text('Confirm you have reviewed this lab result.'), findsOneWidget);

    // Initial state: notes & cancel / mark as reviewed
    expect(find.text('Review notes (optional)'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Mark as reviewed'), findsOneWidget);

    // Tap Mark as reviewed -> triggers save error
    await tester.tap(find.text('Mark as reviewed'));
    await tester.pumpAndSettle();

    expect(find.text('Review not saved'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    // Tap Try Again -> transitions to reviewed success state
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text('Result marked as reviewed'), findsOneWidget);
    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done -> finishes review, updates callback and pops page
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(reviewedResult?.status, equals(LabReviewStatus.reviewed));
    expect(find.text('Record Review'), findsNothing);
  });

  testWidgets('Desktop Lab Referrals tab displays table with 4 seed records and Create button', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    expect(find.text('Create Lab Referral'), findsOneWidget);
    expect(find.text('All lab referrals'), findsOneWidget);
    expect(find.text('4 referrals'), findsOneWidget);

    // Verify seed referrals
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Full blood count'), findsWidgets);
    expect(find.text('08 Oct 2026'), findsOneWidget);
    expect(find.text('Result Received'), findsOneWidget);

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Renal function, Lipid panel'), findsOneWidget);
    expect(find.text('11 Oct 2026'), findsOneWidget);
    expect(find.text('Awaiting Result'), findsOneWidget);

    expect(find.text('Ayanda Zulu'), findsOneWidget);
    expect(find.text('HbA1c'), findsOneWidget);
    expect(find.text('Sample Taken'), findsOneWidget);

    expect(find.text('Peter van Wyk'), findsOneWidget);
    expect(find.text('Requested'), findsOneWidget);

    expect(find.text('View Referral'), findsWidgets);
    expect(find.text('Showing 1–4 of 4 referrals'), findsOneWidget);
  });

  testWidgets('Tablet Lab Referrals tab displays 2-column cards grid and header Create button', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    expect(find.text('Create Lab Referral'), findsOneWidget);
    expect(find.text('All lab referrals'), findsOneWidget);
    expect(find.text('4 referrals'), findsOneWidget);

    // Verify 4 referral cards exist
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Result Received'), findsOneWidget);
    expect(find.text('#SWC-10427'), findsOneWidget);

    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Awaiting Result'), findsOneWidget);
    expect(find.text('#SWC-40311'), findsOneWidget);

    expect(find.text('Ayanda Zulu'), findsOneWidget);
    expect(find.text('Sample Taken'), findsOneWidget);
    expect(find.text('#SWC-42560'), findsOneWidget);

    expect(find.text('Peter van Wyk'), findsOneWidget);
    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('#SWC-43018'), findsOneWidget);

    expect(find.text('View Referral'), findsNWidgets(4));
    expect(find.text('Showing 1–4 of 4 referrals'), findsOneWidget);
  });

  testWidgets('Mobile Lab Referrals tab displays stacked cards and sticky bottom Create button', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // On mobile, Create Lab Referral button is in sticky bottom bar
    expect(find.text('Create Lab Referral'), findsOneWidget);
    expect(find.text('All lab referrals'), findsOneWidget);
    expect(find.text('4 referrals'), findsOneWidget);

    // Verify stacked cards
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Result Received'), findsOneWidget);
    expect(find.text('Thabo Mokoena'), findsOneWidget);
    expect(find.text('Awaiting Result'), findsOneWidget);
    expect(find.text('Ayanda Zulu'), findsOneWidget);
    expect(find.text('Sample Taken'), findsOneWidget);
    expect(find.text('Peter van Wyk'), findsOneWidget);
    expect(find.text('Requested'), findsOneWidget);

    expect(find.text('View Referral'), findsNWidgets(4));
    expect(find.text('Showing 1–4 of 4 referrals'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Desktop View Referral opens slide-in drawer with referral details', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // Tap first 'View Referral' link
    await tester.tap(find.text('View Referral').first);
    await tester.pumpAndSettle();

    // Verify Drawer opens
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Read-only status'), findsOneWidget);
    expect(find.text('The laboratory updates the referral status. Doctors can view it but not change it.'), findsOneWidget);
    expect(find.text('Soweto NHLS Laboratory'), findsOneWidget);
    expect(find.text('Dr. Maya Naidoo'), findsOneWidget);
    expect(find.text('Linked result'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('View Patient Profile'), findsOneWidget);

    // Tap Back closes drawer
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only status'), findsNothing);
  });

  testWidgets('Tablet View Referral opens page with hideBottomNavigation', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // Tap 'View Referral'
    await tester.tap(find.text('View Referral').first);
    await tester.pumpAndSettle();

    // Verify Tablet full page opens with boxed back button
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);
    expect(find.text('Read-only status'), findsOneWidget);
    expect(find.text('Linked result'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('View Patient Profile'), findsOneWidget);

    // Verify bottom navigation is NOT present on tablet referral details
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Tap Back pops page
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only status'), findsNothing);
  });

  testWidgets('Mobile View Referral opens bottom sheet without bottom navigation', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // Tap first 'View Referral'
    await tester.tap(find.text('View Referral').first);
    await tester.pumpAndSettle();

    // Verify Mobile bottom sheet opens
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Read-only status'), findsOneWidget);
    expect(find.text('Linked result'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('View Patient Profile'), findsOneWidget);

    // Verify bottom navigation is NOT present in sheet
    expect(find.byType(AppBottomNavigation), findsNothing);

    // Tap Back dismisses sheet
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only status'), findsNothing);
  });

  testWidgets('Desktop Create Lab Referral button opens slide-in drawer and submits', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // Tap 'Create Lab Referral' button
    await tester.tap(find.text('Create Lab Referral'));
    await tester.pumpAndSettle();

    // Verify Create Lab Referral Drawer is displayed
    expect(find.text('Create Lab Referral'), findsWidgets);
    expect(find.text('Request laboratory tests for a patient.'), findsOneWidget);
    expect(find.text('Search patient by name or folder no.'), findsOneWidget);
    expect(find.text('Search tests (e.g. Full blood count)'), findsOneWidget);
    expect(find.text('Soweto NHLS Laboratory'), findsOneWidget);
    expect(find.text('Add clinical notes for the laboratory'), findsOneWidget);
    expect(find.text('Search by code or description'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Create Refferal'), findsOneWidget);

    // Enter patient name & submit
    await tester.enterText(find.byType(TextField).at(1), 'Grace Hooper');
    await tester.enterText(find.byType(TextField).at(2), 'Urea and Electrolytes');
    await tester.tap(find.text('Create Refferal'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Referral is added
    expect(find.text('Grace Hooper'), findsOneWidget);
  });

  testWidgets('Tablet Create Lab Referral opens full page with hideBottomNavigation', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // Tap 'Create Lab Referral' button
    await tester.tap(find.text('Create Lab Referral'));
    await tester.pumpAndSettle();

    // Verify Tablet view has boxed back button and no bottom navigation
    expect(find.text('Create Lab Referral'), findsWidgets);
    expect(find.byIcon(AppIcons.chevronLeft), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Create Refferal'), findsOneWidget);

    // Tap Back
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Search patient by name or folder no.'), findsNothing);
  });

  testWidgets('Mobile Create Lab Referral sticky button opens bottom sheet', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: LabResultsView()),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Lab Referrals tab
    await tester.tap(find.text('Lab Referrals'));
    await tester.pumpAndSettle();

    // Tap sticky bottom 'Create Lab Referral' button
    await tester.tap(find.text('Create Lab Referral'));
    await tester.pumpAndSettle();

    // Verify Mobile bottom sheet opens without bottom nav
    expect(find.text('Create Lab Referral'), findsWidgets);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Create Refferal'), findsOneWidget);

    // Tap Back dismisses sheet
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Search patient by name or folder no.'), findsNothing);
  });
}
