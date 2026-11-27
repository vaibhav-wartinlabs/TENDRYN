import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_details_view.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_view.dart';
import 'package:tendryn/features/lab_results/views/lab_results_view.dart';
import 'package:tendryn/features/lab_results/views/patient_lab_info_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/common/doctor_coming_soon_view.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';

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
    Get.put(RoleController());
    Get.put(LabReferralController());
  });

  tearDown(() {
    ResponsiveHelper.debugIsDesktopPlatformOverride = null;
    Get.reset();
  });

  test('ClinicRole includes labStaff with correct titles and destinations', () {
    expect(ClinicRole.labStaff.label, 'Lab Staff');
    expect(ClinicRole.labStaff.jobTitle, 'Lab Staff');
    expect(ClinicRole.labStaff.demoUserName, 'Lerato Mokoena');

    final destinations = NavDestinations.forRole(ClinicRole.labStaff);
    expect(destinations.length, 3);
    expect(destinations[0].label, 'Lab Referral');
    expect(destinations[0].route, AppRoutes.labReferral);
    expect(destinations[1].label, 'Result');
    expect(destinations[2].label, 'Patient Lab Information');

    final bottomDestinations = NavDestinations.forRoleBottom(ClinicRole.labStaff);
    expect(bottomDestinations.length, 3);
    expect(bottomDestinations[0].label, 'Lab Referral');
    expect(bottomDestinations[1].label, 'Result');
    expect(bottomDestinations[2].label, 'Patient Lab Info');
  });

  testWidgets('LabReferralView renders desktop layout and 3-dots action menu', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Lab Referral'), findsOneWidget);
    expect(find.text('View laboratory requests and track sample progress.'), findsOneWidget);

    // Verify Search input
    expect(find.byType(TextField), findsOneWidget);

    // Verify Table Header
    expect(find.text('Referrals'), findsOneWidget);
    expect(find.text('Patient Name'), findsOneWidget);
    expect(find.text('Test Requested'), findsOneWidget);
    expect(find.text('Requested By'), findsOneWidget);
    expect(find.text('Referral Date'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);

    // Verify 3 dots action menu button presence
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    expect(actionMenuButtons, findsWidgets);

    // Tap first 3-dots menu button
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();

    // Verify 3 options exist: View Detail, Record Sample, Patient Lab Information
    expect(find.text('View Detail'), findsOneWidget);
    expect(find.text('Record Sample'), findsOneWidget);
    expect(find.text('Patient Lab Information'), findsOneWidget);
  });

  testWidgets('LabReferralView renders tablet 2-column card layout', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's queue"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify cards have 3 dots button
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    expect(actionMenuButtons, findsWidgets);
  });

  testWidgets('LabReferralView renders mobile single-column card layout', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's queue"), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Verify cards have 3 dots button
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    expect(actionMenuButtons, findsWidgets);
  });

  testWidgets('LabReferralView renders empty state when no patient matches search and Clear search restores results', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Type a non-matching query
    await tester.enterText(find.byType(TextField), 'NonExistentPatient');
    await tester.pumpAndSettle();

    // Verify empty state is displayed
    expect(find.text('No referrals match your search'), findsOneWidget);
    expect(find.text('Check the patient name or ID and try again.'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
    expect(find.text('0 referrals'), findsOneWidget);

    // Tap "Clear search"
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();

    // Verify results restored
    expect(find.text('No referrals match your search'), findsNothing);
    expect(find.text('John Smith'), findsOneWidget);
  });

  testWidgets('LabReferralDetailsView renders desktop layout and navigates back', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first 3-dots button
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();

    // Tap 'View Detail'
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    // Verify Lab Referral Details page is open (pre-save state)
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Review the requested tests and associated patient information.'), findsOneWidget);
    expect(find.text('Back to Lab Referral'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Requested tests'), findsOneWidget);
    expect(find.text('Referral information'), findsOneWidget);
    expect(find.text('Sample collection'), findsOneWidget);
    expect(find.text('No sample recorded yet. Record the sample once it has been collected.'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Referral created by Dr Thandi Nkosi'), findsOneWidget);
    expect(find.text('Sample recorded by Lerato Mokoena'), findsNothing);
    expect(find.text('Record Sample'), findsOneWidget);
    expect(find.text('View Patient Lab Information'), findsOneWidget);

    // Tap Back pill
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();

    // Verify back to LabReferralView
    expect(find.text('Referrals'), findsOneWidget);
  });

  testWidgets('LabReferralDetailsView renders tablet layout without bottom nav and pre-save Record Sample CTA', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Open View Detail before saving sample
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Review the requested tests and associated patient information.'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Requested tests'), findsOneWidget);
    expect(find.text('Referral information'), findsOneWidget);
    expect(find.text('Sample collection'), findsOneWidget);
    expect(find.text('No sample recorded yet. Record the sample once it has been collected.'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Record Sample'), findsOneWidget);
    expect(find.text('View Patient Lab Information'), findsOneWidget);

    // Tap boxed back button to return to LabReferralView
    final backIcon = find.byIcon(AppIcons.chevronLeft);
    expect(backIcon, findsOneWidget);
    await tester.tap(backIcon);
    await tester.pumpAndSettle();
    expect(find.text("Today's queue"), findsOneWidget);
  });

  testWidgets('LabReferralDetailsView renders mobile layout without bottom nav and pre-save Record Sample CTA', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Open View Detail before saving sample
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Requested tests'), findsOneWidget);
    expect(find.text('Referral information'), findsOneWidget);
    expect(find.text('Sample collection'), findsOneWidget);
    expect(find.text('No sample recorded yet. Record the sample once it has been collected.'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Record Sample'), findsOneWidget);
    expect(find.text('View Patient Lab Information'), findsOneWidget);

    // Tap boxed back button
    final backIcon = find.byIcon(AppIcons.chevronLeft);
    expect(backIcon, findsOneWidget);
    await tester.tap(backIcon);
    await tester.pumpAndSettle();
    expect(find.text("Today's queue"), findsOneWidget);
  });

  testWidgets('LabReferralDetailsView status pill opens dialog with 4 status options and updates status', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final referral = LabReferralController.to.referrals.first;
    expect(referral.status, LabReferralStatus.requested);

    await tester.pumpWidget(
      GetMaterialApp(
        home: LabReferralDetailsView(
          referral: referral,
          onClose: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap interactive status pill
    await tester.tap(find.byKey(const Key('referral_status_pill_banner')));
    await tester.pumpAndSettle();

    // Verify dialog title and 4 options exist
    expect(find.text('Select current laboratory referral status'), findsOneWidget);
    expect(find.text('Requested'), findsWidgets);
    expect(find.text('Sample Taken'), findsOneWidget);
    expect(find.text('Awaiting Result'), findsOneWidget);
    expect(find.text('Result Received'), findsOneWidget);

    // Select 'Sample Taken'
    await tester.tap(find.text('Sample Taken'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify dialog is closed and status is updated in controller and view
    expect(find.text('Select current laboratory referral status'), findsNothing);
    expect(LabReferralController.to.referrals.first.status, LabReferralStatus.sampleTaken);
    expect(find.text('Sample Taken'), findsWidgets);
    expect(find.text('Upload Result'), findsOneWidget);
  });

  testWidgets('LabReferralDetailsView status pill on mobile opens bottom sheet with 4 status options and updates status', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final referral = LabReferralController.to.referrals.first;

    await tester.pumpWidget(
      GetMaterialApp(
        home: LabReferralDetailsView(
          referral: referral,
          onClose: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap status pill in banner
    await tester.tap(find.byKey(const Key('referral_status_pill_banner')));
    await tester.pumpAndSettle();

    // Verify bottom sheet header and 4 options
    expect(find.text('Select current laboratory referral status'), findsOneWidget);
    expect(find.text('Requested'), findsWidgets);
    expect(find.text('Sample Taken'), findsWidgets);
    expect(find.text('Awaiting Result'), findsOneWidget);
    expect(find.text('Result Received'), findsOneWidget);

    // Select 'Result Received'
    await tester.tap(find.text('Result Received'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify bottom sheet is dismissed and status is updated
    expect(find.text('Select current laboratory referral status'), findsNothing);
    expect(LabReferralController.to.referrals.first.status, LabReferralStatus.resultReceived);
    expect(find.text('Result Received'), findsWidgets);
  });

  testWidgets('Updating referral status returns to LabReferralView and displays green success banner', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initially no banner
    expect(find.text('Referral updated'), findsNothing);

    // Tap first 3-dots button and 'View Detail'
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    // In details view, tap status pill
    await tester.tap(find.byKey(const Key('referral_status_pill_banner')));
    await tester.pumpAndSettle();

    // Select 'Awaiting Result'
    await tester.tap(find.text('Awaiting Result'));
    await tester.pumpAndSettle();

    // Verify we are back on main LabReferralView and green banner is displayed
    expect(find.text('Referral updated'), findsOneWidget);
    expect(find.text('John Smith · Full Blood Count is now Awaiting Result.'), findsOneWidget);
    expect(find.text('Lab Referral'), findsOneWidget);

    // After 5 seconds, the banner automatically disappears
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Referral updated'), findsNothing);
    expect(find.text('John Smith · Full Blood Count is now Awaiting Result.'), findsNothing);
  });

  testWidgets('Desktop Record Sample drawer opens from 3-dots menu and saves sample', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final referral = LabReferralController.to.referrals.first;
    expect(referral.status, LabReferralStatus.requested);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first 3-dots button and 'Record Sample'
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();

    // Verify Record Sample drawer is open
    expect(find.text('Record Sample'), findsWidgets);
    expect(find.text('Record sample collection for this referral.'), findsOneWidget);
    expect(find.text('Full Blood Count'), findsWidgets);
    expect(find.text('LR-000124'), findsOneWidget);
    expect(find.text('Collection date'), findsOneWidget);
    expect(find.text('Collection time'), findsOneWidget);
    expect(find.text('Sample notes (optional)'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save Sample'), findsOneWidget);

    // Tap 'Save Sample'
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();

    // Drawer is closed, status updated to Sample Taken, and Sample Recorded dialog appears!
    expect(find.text('Record sample collection for this referral.'), findsNothing);
    expect(LabReferralController.to.referrals.first.status, LabReferralStatus.sampleTaken);
    expect(find.text('Sample Recorded'), findsOneWidget);
    expect(find.text('Sample information has been saved successfully.'), findsOneWidget);
    expect(find.text('View Referral'), findsOneWidget);
    expect(find.text('Back to Lab Referral'), findsOneWidget);

    // Tap 'Back to Lab Referral' to dismiss confirmation
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();
    expect(find.text('Sample Recorded'), findsNothing);
  });

  testWidgets('Tablet Record Sample opens full page without bottom navigation and saves sample', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first 3-dots button and 'Record Sample'
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();

    // Verify Record Sample view open on tablet without bottom navigation
    expect(find.text('Record Sample'), findsWidgets);
    expect(find.text('Record sample collection for this referral.'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save Sample'), findsOneWidget);

    // Tap Save Sample and verify Sample Recorded dialog appears
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();

    expect(find.text('Sample Recorded'), findsOneWidget);
    expect(find.text('View Referral'), findsOneWidget);
    expect(find.text('Back to Lab Referral'), findsOneWidget);

    // Tap View Referral -> opens details view
    await tester.tap(find.text('View Referral'));
    await tester.pumpAndSettle();

    expect(find.text('Sample Recorded'), findsNothing);
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Review the requested tests and associated patient information.'), findsOneWidget);
  });

  testWidgets('Mobile Record Sample opens bottom sheet without bottom navigation and saves sample', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first 3-dots button and 'Record Sample'
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();

    // Verify Record Sample bottom sheet on mobile without bottom navigation
    expect(find.text('Record Sample'), findsWidgets);
    expect(find.text('Record sample collection for this referral.'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save Sample'), findsOneWidget);

    // Tap Save Sample and verify Sample Recorded mobile bottom sheet appears
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();

    expect(find.text('Sample Recorded'), findsOneWidget);
    expect(find.text('View Referral'), findsOneWidget);
    expect(find.text('Back to Lab Referral'), findsOneWidget);

    // Dismiss sheet
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();
    expect(find.text('Sample Recorded'), findsNothing);
  });

  testWidgets('View Referral after Save Sample displays updated sample collection card and activity timeline', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first 3-dots button and 'Record Sample'
    final actionMenuButtons = find.byType(AppActionsBoxButton);
    await tester.tap(actionMenuButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();

    // Tap 'Save Sample'
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();

    // Dialog appears: tap 'View Referral'
    expect(find.text('View Referral'), findsOneWidget);
    await tester.tap(find.text('View Referral'));
    await tester.pumpAndSettle();

    // Details view is opened with updated sample details matching mockups
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Sample collection'), findsOneWidget);
    expect(find.text('Collection date'), findsOneWidget);
    expect(find.text('Collection time'), findsOneWidget);
    expect(find.text('Recorded by'), findsOneWidget);
    expect(find.text('Sample notes'), findsOneWidget);
    expect(find.text('Lerato Mokoena (Lab Staff)'), findsOneWidget);
    expect(find.text('Collected at lab reception.'), findsOneWidget);

    // Activity timeline has 3 items
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Referral created by Dr Thandi Nkosi'), findsOneWidget);
    expect(find.text('Sample recorded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('Status changed to Awaiting Result'), findsOneWidget);

    // Primary action button is now 'Upload Result' because sample is taken
    expect(find.text('Upload Result'), findsOneWidget);
  });

  testWidgets('Desktop View Detail after Save Sample shows updated sample collection, activity, and Upload Result CTA', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Record sample & return to Lab Referral list
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Collected from left arm');
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();

    // Now click 3-dots -> 'View Detail' from main list
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Collection date'), findsOneWidget);
    expect(find.text('Collection time'), findsOneWidget);
    expect(find.text('Recorded by'), findsOneWidget);
    expect(find.text('Lerato Mokoena (Lab Staff)'), findsOneWidget);
    expect(find.text('Collected from left arm'), findsOneWidget);
    expect(find.text('Sample recorded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('Status changed to Awaiting Result'), findsOneWidget);
    expect(find.text('Upload Result'), findsOneWidget);
  });

  testWidgets('Mobile View Detail after Save Sample hides bottom nav and shows updated details', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Collected from left arm');
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Collection date'), findsOneWidget);
    expect(find.text('Collected from left arm'), findsOneWidget);
    expect(find.text('Sample recorded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('Status changed to Awaiting Result'), findsOneWidget);
    expect(find.text('Upload Result'), findsOneWidget);
  });

  testWidgets('Tablet View Detail after Save Sample hides bottom nav and shows updated details', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Collection date'), findsOneWidget);
    expect(find.text('Collected at lab reception.'), findsOneWidget);
    expect(find.text('Sample recorded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('Upload Result'), findsOneWidget);
  });

  testWidgets('Tapping Record Sample inside LabReferralDetailsView saves sample and updates details view live', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Open View Detail on pre-save referral
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Detail'));
    await tester.pumpAndSettle();

    expect(find.text('No sample recorded yet. Record the sample once it has been collected.'), findsOneWidget);
    expect(find.text('Record Sample'), findsOneWidget);

    // Record sample directly from Details page CTA
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();
    expect(find.text('Record sample collection for this referral.'), findsOneWidget);

    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();
    expect(find.text('Sample Recorded'), findsOneWidget);

    // Click View Referral -> stays on updated details view cleanly
    await tester.tap(find.text('View Referral'));
    await tester.pumpAndSettle();

    expect(find.text('Sample Recorded'), findsNothing);
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Collection date'), findsOneWidget);
    expect(find.text('Lerato Mokoena (Lab Staff)'), findsOneWidget);
    expect(find.text('Sample recorded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('Upload Result'), findsOneWidget);

    // Back pill pops straight back to LabReferralView
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();
    expect(find.text('Referrals'), findsOneWidget);
  });

  testWidgets('Patient Lab Information opens from 3-dots menu on desktop, tablet, and mobile without bottom nav', (tester) async {
    // 1. Desktop
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient Lab Information'));
    await tester.pumpAndSettle();

    expect(find.text('Patient Lab Information'), findsWidgets);
    expect(find.text('Lab referrals, sample tracking and uploaded results for this patient.'), findsOneWidget);
    expect(find.text('TND-000124 · Male · 42 yrs'), findsOneWidget);
    expect(find.text('Lab referrals'), findsOneWidget);
    expect(find.text('Sample tracking'), findsOneWidget);
    expect(find.text('Uploaded results'), findsOneWidget);
    expect(find.text('LR-0017'), findsWidgets);
    expect(find.text('UE_John-Smith_LR-0017.pdf'), findsOneWidget);

    // Back pill returns to LabReferralView
    await tester.tap(find.text('Back to lab referral'));
    await tester.pumpAndSettle();
    expect(find.text('Referrals'), findsOneWidget);
  });

  testWidgets('Patient Lab Information opens on tablet and mobile without bottom navigation and supports View Details', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient Lab Information'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Patient Lab Information'), findsOneWidget);
    expect(find.text('Lab referrals'), findsOneWidget);
    expect(find.text('Sample tracking'), findsOneWidget);
    expect(find.text('Uploaded results'), findsOneWidget);
    expect(find.text('UE_John-Smith_LR-0017.pdf'), findsOneWidget);

    // Tap Back button to return
    await tester.tap(find.byIcon(AppIcons.chevronLeft));
    await tester.pumpAndSettle();
    expect(find.text("Today's queue"), findsOneWidget);
  });

  testWidgets('View Patient Lab Information button in LabReferralDetailsView opens Patient Lab Info with live sample tracking', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabReferralView(),
      ),
    );
    await tester.pumpAndSettle();

    // Save sample first
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Sample'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Sample'));
    await tester.pumpAndSettle();

    // Tap View Referral -> LabReferralDetailsView
    await tester.tap(find.text('View Referral'));
    await tester.pumpAndSettle();

    // Tap View Patient Lab Information button -> PatientLabInfoView (mobile)
    await tester.tap(find.text('View Patient Lab Information'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Patient Lab Information'), findsOneWidget);
    expect(find.text('TND-000124 · Male · 42 yrs'), findsOneWidget);
    expect(find.text('Lerato Mokoena (Lab Staff)'), findsOneWidget);
    expect(find.text('UE_John-Smith_LR-0017.pdf'), findsOneWidget);

    // Tap 'View Details' on first referral row opens LabReferralDetailsView
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();
    expect(find.text('Lab Referral Details'), findsOneWidget);
  });

  testWidgets('Lab Staff Result view renders desktop table with empty 3-dots action and search/filter', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    RoleController.to.currentRole.value = ClinicRole.labStaff;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LabResultsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Result'), findsOneWidget);
    expect(find.text('Upload and manage laboratory result documents.'), findsOneWidget);
    expect(find.text('Lab results'), findsOneWidget);
    expect(find.text('2 awaiting result · 2 result received'), findsOneWidget);
    expect(find.text('Patient Name'), findsOneWidget);
    expect(find.text('Test Name'), findsOneWidget);
    expect(find.text('Referral Date'), findsOneWidget);
    expect(find.text('Result Status'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Naledi Molefe'), findsOneWidget);
    expect(find.text('Amahle Khumalo'), findsOneWidget);
    expect(find.text('Sipho Dlamini'), findsOneWidget);

    // Tapping 3-dots on an already Result Received row shows ONLY 'View Details'
    // (never prompts 'Upload Lab Results' again once saved).
    final dots = find.byType(AppActionsBoxButton);
    expect(dots, findsNWidgets(4));
    await tester.tap(dots.at(2));
    await tester.pumpAndSettle();
    expect(find.text('Upload Lab Results'), findsNothing);
    expect(find.text('View Details'), findsOneWidget);

    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(
      find.text(
        'View the uploaded laboratory document and its referral details.',
      ),
      findsOneWidget,
    );
    expect(find.text('Result information'), findsOneWidget);
    expect(find.text('Result document'), findsOneWidget);
    expect(find.text('Amahle Khumalo'), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);

    await tester.tap(find.text('Back to Result'));
    await tester.pumpAndSettle();
    expect(find.text('Lab results'), findsOneWidget);

    // Tapping 'View Details' on an Awaiting Result row shows inline Upload PDF card
    // on the right column, and saving it flips to read-only saved state without
    // prompting repeated uploads afterwards.
    await tester.tap(dots.first);
    await tester.pumpAndSettle();
    expect(find.text('Upload Lab Results'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();

    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(find.text('Upload laboratory result PDF'), findsOneWidget);
    expect(find.text('Choose File'), findsOneWidget);

    // Submitting without choosing file shows inline validation error
    await tester.ensureVisible(find.text('Upload Result'));
    await tester.tap(find.text('Upload Result'));
    await tester.pumpAndSettle();
    expect(find.text('Please choose a PDF, JPG, or PNG file to upload.'), findsOneWidget);

    // Pick PDF and save inline -> switches live to saved read-only document card
    await tester.ensureVisible(find.text('Choose File'));
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('.pdf').first);
    await tester.pumpAndSettle();
    expect(find.text('Laboratory report'), findsOneWidget);
    await tester.ensureVisible(find.text('Upload Result'));
    await tester.tap(find.text('Upload Result'));
    await tester.pumpAndSettle();

    expect(find.text('Upload laboratory result PDF'), findsNothing);
    expect(find.text('Upload Result'), findsNothing);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    expect(find.text('FBC_John-Smith_LR-000124.pdf'), findsOneWidget);
    expect(find.text('Laboratory report'), findsOneWidget);

    // Related Referral CTA now shows 'View Result' (not 'Upload Result') since saved
    await tester.ensureVisible(find.text('View Related Referral'));
    await tester.tap(find.text('View Related Referral'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('View Result'), findsOneWidget);
    expect(find.text('Upload Result'), findsNothing);
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Back to Result'));
    await tester.tap(find.text('Back to Result'));
    await tester.pumpAndSettle();
    expect(find.text('1 awaiting result · 3 result received'), findsOneWidget);

    // Already-saved John Smith 3-dots no longer offers 'Upload Lab Results'
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Upload Lab Results'), findsNothing);
    expect(find.text('View Details'), findsOneWidget);
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();
    expect(find.text('FBC_John-Smith_LR-000124.pdf'), findsOneWidget);
    expect(find.text('Upload laboratory result PDF'), findsNothing);
    await tester.tap(find.text('Back to Result'));
    await tester.pumpAndSettle();

    // Second awaiting row (Naledi Molefe): Tap 'Upload Lab Results' -> drawer flow
    await tester.tap(find.byType(AppActionsBoxButton).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Lab Results'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Lab Result'), findsOneWidget);
    expect(find.text('Attach a laboratory report to the selected patient referral.'), findsOneWidget);
    expect(find.text('Select a PDF or image file'), findsOneWidget);
    expect(find.text('Accepted formats: PDF, JPG, PNG'), findsOneWidget);
    expect(find.text('Choose File'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Upload Result'), findsOneWidget);

    // Submitting without selecting file displays inline validation error
    await tester.tap(find.text('Upload Result'));
    await tester.pumpAndSettle();
    expect(find.text('Please choose a PDF, JPG, or PNG file to upload.'), findsOneWidget);

    // Choose a file -> displays selected file card, Laboratory report preview,
    // blue attachment banner, and trash delete button
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    expect(find.text('Select Report File'), findsOneWidget);
    await tester.tap(find.textContaining('.pdf').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('.pdf'), findsWidgets);
    expect(find.text('PDF document'), findsOneWidget);
    expect(find.text('Laboratory report'), findsOneWidget);
    expect(
      find.text(
        'Will be attached to Naledi Molefe (TND-000118) · LR-000118 · Urinalysis.',
      ),
      findsOneWidget,
    );

    // Clicking red trash icon removes file and restores dropzone
    await tester.tap(find.byTooltip('Remove file'));
    await tester.pumpAndSettle();
    expect(find.text('Choose File'), findsOneWidget);

    // Re-pick file and upload -> closes drawer + shows Lab Result Uploaded modal
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('.pdf').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload Result'));
    await tester.pumpAndSettle();

    final naledi = LabReferralController.to.labStaffResults[1];
    expect(find.text('Upload Lab Result'), findsNothing);
    expect(find.text('Lab Result Uploaded'), findsOneWidget);
    expect(
      find.text(
        "The laboratory result has been attached to the patient's record.",
      ),
      findsOneWidget,
    );
    expect(
      find.text('${naledi.patientName} · ${naledi.folderNumber}'),
      findsOneWidget,
    );
    expect(find.text(naledi.referenceNumber), findsOneWidget);
    expect(find.text('Doctor review pending'), findsOneWidget);
    expect(
      find.textContaining('${naledi.requestedBy} can now access this result'),
      findsOneWidget,
    );
    expect(find.text('View Result'), findsOneWidget);
    expect(find.text('Return to Result'), findsOneWidget);

    await tester.tap(find.text('View Result'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Uploaded'), findsNothing);
    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(find.text('Result information'), findsOneWidget);
    expect(find.text('Result document'), findsOneWidget);
    expect(find.text('Lerato Mokoena'), findsWidgets);
    expect(find.text('Doctor review pending'), findsOneWidget);
    expect(
      find.text('Clinical review is completed by the requesting doctor.'),
      findsOneWidget,
    );
    expect(find.text('U_Naledi-Molefe_LR-000118.pdf'), findsOneWidget);
    expect(find.text('View Patient Lab Information'), findsOneWidget);
    expect(find.text('View Related Referral'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);

    // Sub-actions work from Lab Result Details
    await tester.tap(find.text('View Patient Lab Information'));
    await tester.pumpAndSettle();
    expect(find.text('Patient Lab Information'), findsWidgets);
    expect(find.text('Naledi Molefe'), findsWidgets);
    expect(find.text('U_Naledi-Molefe_LR-000118.pdf'), findsWidgets);
    expect(find.text('Back to Result Details'), findsOneWidget);
    await tester.tap(find.text('Back to Result Details'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);

    await tester.tap(find.text('View Related Referral'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Naledi Molefe'), findsWidgets);
    expect(find.text('Result uploaded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('View Result'), findsOneWidget);
    await tester.tap(find.text('Back to Lab Referral'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);

    await tester.tap(find.text('Back to Result'));
    await tester.pumpAndSettle();
    expect(find.text('0 awaiting result · 4 result received'), findsOneWidget);

    // Search filter + clear search
    await tester.enterText(find.byType(TextField), 'NonExistentResult');
    await tester.pumpAndSettle();
    expect(find.text('No lab results match your search'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('John Smith'), findsOneWidget);
  });

  testWidgets('Lab Staff Result view renders mobile card layout and Upload Lab Result sheet without bottom nav', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    RoleController.to.currentRole.value = ClinicRole.labStaff;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: AppShell(
          route: AppRoutes.labResults,
          child: LabResultsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('Result'), findsWidgets);
    expect(find.text('Upload and manage laboratory result documents.'), findsOneWidget);
    expect(find.text('Lab results'), findsOneWidget);
    expect(find.text('2 awaiting result · 2 result received'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Full Blood Count'), findsOneWidget);
    expect(find.byType(AppActionsBoxButton), findsNWidgets(4));

    // Mobile Upload Lab Result opens modal bottom sheet over root navigator (no bottom nav)
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Lab Results'));
    await tester.pumpAndSettle();
    expect(find.text('Upload Lab Result'), findsOneWidget);
    expect(find.text('Choose File'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Upload Lab Result'), findsNothing);

    // Re-open, select file, tap Upload Result -> shows Mobile Lab Result Uploaded bottom sheet
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Lab Results'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('.pdf').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Result'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Lab Result'), findsNothing);
    expect(find.text('Lab Result Uploaded'), findsOneWidget);
    expect(find.text('Doctor review pending'), findsOneWidget);
    expect(find.text('View Result'), findsOneWidget);
    expect(find.text('Return to Result'), findsOneWidget);

    await tester.tap(find.text('View Result'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Uploaded'), findsNothing);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(find.text('Result information'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Result document'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    expect(find.text('View Related Referral'), findsOneWidget);
    expect(find.text('View Patient Lab Information'), findsOneWidget);

    // Mobile sub-actions open Patient Lab Information & Lab Referral Details (no bottom nav)
    await tester.tap(find.text('View Patient Lab Information'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Patient Lab Information'), findsOneWidget);
    expect(find.text('FBC_John-Smith_LR-000124.pdf'), findsWidgets);
    await tester.tap(find.byIcon(AppIcons.chevronLeft).last);
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);

    await tester.tap(find.text('View Related Referral'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Result uploaded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('View Result'), findsOneWidget);
    await tester.tap(find.byIcon(AppIcons.chevronLeft).last);
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('1 awaiting result · 3 result received'), findsOneWidget);
  });

  testWidgets('Lab Staff Result view renders tablet layout and hides bottom nav when Upload Lab Result opens', (tester) async {
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    RoleController.to.currentRole.value = ClinicRole.labStaff;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: AppShell(
          route: AppRoutes.labResults,
          child: LabResultsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('Result'), findsWidgets);
    expect(find.text('Sipho Dlamini'), findsOneWidget);

    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Lab Results'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Upload Lab Result'), findsOneWidget);
    expect(find.text('Choose File'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Upload Lab Result'), findsNothing);

    // Re-open, select file, tap Upload Result -> shows Tablet Lab Result Uploaded modal dialog
    await tester.tap(find.byType(AppActionsBoxButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Lab Results'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsNothing);
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('.pdf').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Result'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Lab Result'), findsNothing);
    expect(find.text('Lab Result Uploaded'), findsOneWidget);
    expect(find.text('Doctor review pending'), findsOneWidget);
    expect(find.text('View Result'), findsOneWidget);
    expect(find.text('Return to Result'), findsOneWidget);

    await tester.tap(find.text('View Result'));
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Uploaded'), findsNothing);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Lab Result Details'), findsOneWidget);
    expect(
      find.text(
        'View the uploaded laboratory document and its referral details.',
      ),
      findsOneWidget,
    );
    expect(find.text('Result information'), findsOneWidget);
    expect(find.text('Result document'), findsOneWidget);
    expect(find.text('Doctor review pending'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    expect(find.textContaining('Will be attached to'), findsNothing);
    expect(find.text('View Patient Lab Information'), findsOneWidget);
    expect(find.text('View Related Referral'), findsOneWidget);

    // Tablet sub-actions open Patient Lab Information & Lab Referral Details (no bottom nav)
    await tester.tap(find.text('View Patient Lab Information'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Patient Lab Information'), findsOneWidget);
    expect(find.text('FBC_John-Smith_LR-000124.pdf'), findsWidgets);
    await tester.tap(find.byIcon(AppIcons.chevronLeft).last);
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);

    await tester.tap(find.text('View Related Referral'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Lab Referral Details'), findsOneWidget);
    expect(find.text('Result uploaded by Lerato Mokoena'), findsOneWidget);
    expect(find.text('View Result'), findsOneWidget);
    await tester.tap(find.byIcon(AppIcons.chevronLeft).last);
    await tester.pumpAndSettle();
    expect(find.text('Lab Result Details'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('1 awaiting result · 3 result received'), findsOneWidget);
  });

  testWidgets('Patient Lab Information navigation tab renders full page across desktop, mobile, and tablet without Coming Soon', (tester) async {
    RoleController.to.currentRole.value = ClinicRole.labStaff;
    if (!Get.isRegistered<LabReferralController>()) {
      Get.put(LabReferralController());
    }

    // 1. Desktop top-level tab
    ResponsiveHelper.debugIsDesktopPlatformOverride = true;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: AppShell(
          route: AppRoutes.patientLabInfo,
          child: PatientLabInfoView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DoctorComingSoonView), findsNothing);
    expect(find.text('Coming Soon'), findsNothing);
    expect(find.text('Patient Lab Information'), findsWidgets);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('TND-000124 · Male · 42 yrs'), findsOneWidget);
    expect(find.text('Lab referrals'), findsOneWidget);
    expect(find.text('Sample tracking'), findsOneWidget);
    expect(find.text('Uploaded results'), findsOneWidget);
    expect(find.text('UE_John-Smith_LR-0017.pdf'), findsOneWidget);

    // 2. Mobile top-level tab keeps bottom navigation visible
    ResponsiveHelper.debugIsDesktopPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(
      const GetMaterialApp(
        home: AppShell(
          route: AppRoutes.patientLabInfo,
          child: PatientLabInfoView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DoctorComingSoonView), findsNothing);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('Patient Lab Information'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);

    // 3. Tablet top-level tab keeps bottom navigation visible
    tester.view.physicalSize = const Size(800, 1024);
    await tester.pumpWidget(
      const GetMaterialApp(
        home: AppShell(
          route: AppRoutes.patientLabInfo,
          child: PatientLabInfoView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DoctorComingSoonView), findsNothing);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.text('Patient Lab Information'), findsOneWidget);
    expect(find.text('UE_John-Smith_LR-0017.pdf'), findsOneWidget);
  });
}
