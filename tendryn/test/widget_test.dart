import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/core/utils/validators.dart';
import 'package:tendryn/main.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/routes/initial_binding.dart';
import 'package:tendryn/services/storage_service.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/nav_item.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/clinical_banners.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';
import 'package:tendryn/widgets/common/triage_tag.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';
import 'package:tendryn/features/dashboard/widgets/quick_actions_section.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/features/patients/views/patient_front_desk_preview_view.dart';
import 'package:tendryn/features/patients/views/register_patient_view.dart';
import 'package:tendryn/widgets/desktop/side_navigation.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_theme.dart';

class _MemoryStorage implements StorageService {
  final _data = <String, String>{};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

Future<void> _pumpApp(WidgetTester tester, Size size, {bool preview = false}) async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return <String>['wifi'];
      }
      return null;
    },
  );
  // App specs here exercise width breakpoints; use a desktop target so the
  // native phone/tablet shortest-side rule does not reinterpret test surfaces.
  ResponsiveHelper.debugIsDesktopPlatformOverride = true;
  addTearDown(() => ResponsiveHelper.debugIsDesktopPlatformOverride = null);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(Get.reset);

  await tester.pumpWidget(
    TendrynApp(
      initialBinding: InitialBinding(
        storage: StorageManager(secure: _MemoryStorage(), preferences: _MemoryStorage()),
        openDashboardPreview: preview,
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'password123');
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

/// Loads the bundled fonts so layout tests measure real text widths
/// (otherwise flutter_test falls back to a wide placeholder font).
Future<void> _loadFonts() async {
  for (final (family, path) in [('Inter', 'assets/fonts/Inter.ttf'), ('Plus Jakarta Sans', 'assets/fonts/PlusJakartaSans.ttf')]) {
    await (FontLoader(family)..addFont(rootBundle.load(path))).load();
  }
}

void main() {
  setUpAll(_loadFonts);

  test('ResponsiveHelper maps widths to screen types', () {
    expect(ResponsiveHelper.fromWidth(400), LayoutType.mobile);
    expect(ResponsiveHelper.fromWidth(800), LayoutType.tablet);
    expect(ResponsiveHelper.fromWidth(1200), LayoutType.desktop);
  });

  test('Validators', () {
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.email('nope'), isNotNull);
    expect(Validators.password('short'), isNotNull);
  });

  testWidgets('ResponsiveLayout falls back to mobile when wider layouts are missing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: ResponsiveLayout(mobile: Text('mobile'))));
    expect(find.text('mobile'), findsOneWidget);
  });

  testWidgets('wrong password shows the API error and stays on login', (tester) async {
    await _pumpApp(tester, const Size(1400, 900));
    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Invalid email or password.'), findsOneWidget);
  });

  testWidgets('desktop: sign in shows side navigation and the desktop dashboard', (tester) async {
    await _pumpApp(tester, const Size(1400, 900));
    await _signIn(tester);

    expect(find.text('Front desk overview for today'), findsOneWidget);
    expect(find.byType(AppSideNavigation), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
  });

  test('Formatters.zar uses space thousands and decimal comma', () {
    expect(Formatters.zar(450), 'R 450,00');
    expect(Formatters.zar(8450), 'R 8 450,00');
    expect(Formatters.zar(1234567.5), 'R 1 234 567,50');
  });

  group('design system widgets', () {
    Widget host(Widget child) => MaterialApp(theme: AppTheme.light(), home: Scaffold(body: Center(child: child)));

    testWidgets('AppButton is 48px high, disabled when onPressed is null, blocks taps while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(AppButton.primary(label: 'Continue', onPressed: () => taps++)));
      expect(tester.getSize(find.byType(FilledButton)).height, 48);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 1);

      await tester.pumpWidget(host(AppButton.primary(label: 'Continue', isLoading: true, onPressed: () => taps++)));
      await tester.tap(find.byType(FilledButton));
      expect(taps, 1);

      await tester.pumpWidget(host(const AppButton.secondary(label: 'Cancel', onPressed: null)));
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).enabled, isFalse);
    });

    testWidgets('sync chips and triage tags always show text with their state', (tester) async {
      await tester.pumpWidget(host(Column(mainAxisSize: MainAxisSize.min, children: [
        for (final s in SyncState.values) SyncChip(state: s),
        for (final l in TriageLevel.values) TriageTag(level: l),
      ])));
      for (final s in SyncState.values) {
        expect(find.text(s.label), findsOneWidget);
      }
      for (final l in TriageLevel.values) {
        expect(find.text(l.label), findsOneWidget);
      }
    });

    testWidgets('banners render their message; card renders title and detail', (tester) async {
      await tester.pumpWidget(host(Column(mainAxisSize: MainAxisSize.min, children: [
        const AllergyBanner(message: 'Allergy: Penicillin'),
        const OfflineBanner(),
        AppCard.titled(title: 'Card title', detail: 'Supporting information', elevation: AppCardElevation.soft),
      ])));
      expect(find.text('Allergy: Penicillin'), findsOneWidget);
      expect(find.textContaining('saved and will sync'), findsOneWidget);
      expect(find.text('Card title'), findsOneWidget);
      expect(find.text('Supporting information'), findsOneWidget);
    });
  });

  group('dashboard', () {
    testWidgets('desktop shows the queue and appointments tables and the Figma figures', (tester) async {
      await _pumpApp(tester, const Size(1400, 2400));
      await _signIn(tester);

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Live Queue'), findsOneWidget);
      expect(find.text('Q014'), findsOneWidget);
      expect(find.text('Waiting for Doctor'), findsOneWidget);
      expect(find.text('R 8,450.00'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop at the narrowest width scrolls the tables instead of overflowing', (tester) async {
      await _pumpApp(tester, const Size(1200, 900));
      await _signIn(tester);
      expect(find.byType(AppSideNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet shows cards, a greeting and the sync chip with a bottom bar', (tester) async {
      await _pumpApp(tester, const Size(744, 1200));
      await _signIn(tester);

      expect(find.textContaining('Lerato'), findsWidgets);
      expect(find.text('Synced'), findsOneWidget);
      expect(find.text('R 8,450'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.byType(AppSideNavigation), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile fits a small phone with large text and quick actions respond', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpApp(tester, const Size(360, 800));
      await _signIn(tester);

      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.text('R 8,450'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Take Payment'), 400, scrollable: find.byType(Scrollable).first);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -100));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take Payment'));
      await tester.pump();
      expect(find.text('Page is not generated'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });
  });

  group('development preview startup', () {
    testWidgets('opens the Dashboard directly as the Figma demo user, with no login', (tester) async {
      await _pumpApp(tester, const Size(1400, 900), preview: true);

      expect(find.text('Sign in'), findsNothing);
      expect(find.text('Front desk overview for today'), findsOneWidget);
      expect(find.text('Lerato Mokoena'), findsOneWidget);
      expect(find.text('Receptionist'), findsOneWidget);
      expect(find.text('Ubuntu Family Clinic'), findsOneWidget);
    });

    testWidgets('without the preview the normal flow still starts at login', (tester) async {
      await _pumpApp(tester, const Size(1400, 900));
      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Front desk overview for today'), findsNothing);
    });

    testWidgets('resizing between desktop, tablet and mobile widths switches layouts without errors', (tester) async {
      await _pumpApp(tester, const Size(1400, 1000), preview: true);
      expect(find.byType(AppSideNavigation), findsOneWidget);

      tester.view.physicalSize = const Size(900, 1000);
      await tester.pumpAndSettle();
      expect(find.byType(AppSideNavigation), findsNothing);
      expect(find.byType(AppBottomNavigation), findsOneWidget);

      tester.view.physicalSize = const Size(420, 900);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsOneWidget);

      tester.view.physicalSize = const Size(1400, 1000);
      await tester.pumpAndSettle();
      expect(find.byType(AppSideNavigation), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('light mode only', () {
    testWidgets('stays light even when the system is in dark mode', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await _pumpApp(tester, const Size(1400, 900), preview: true);

      final context = tester.element(find.text('Front desk overview for today'));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.brandPrimary);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundApp);
      expect(theme.colorScheme.surface, AppColors.backgroundSurface);
      expect(Get.isDarkMode, isFalse);
    });
  });

  group('quick actions', () {
    testWidgets('no quick action is highlighted when the Dashboard first opens', (tester) async {
      await _pumpApp(tester, const Size(1400, 2400), preview: true);

      final materials = [
        for (final title in ['Add Walk-in', 'Register Patient', 'Book Appointment', 'Take Payment'])
          tester.widget<Material>(find.ancestor(of: find.text(title), matching: find.byType(Material)).first),
      ];
      for (final m in materials) {
        expect(m.color, AppColors.backgroundSurface);
      }
    });

    testWidgets('find patient results are rendered in a Stack overlay on tap and allow viewing patient', (tester) async {
      await _pumpApp(tester, const Size(1400, 2400), preview: true);

      final section = find.byType(QuickActionsSection);
      expect(find.descendant(of: section, matching: find.text('Find Patient')), findsOneWidget);
      // All 4 action options are initially visible; search results are not active yet
      expect(find.descendant(of: section, matching: find.text('Add Walk-in')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Register Patient')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Book Appointment')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Take Payment')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Thabo Nkosi')), findsNothing);

      // Tapping the search bar activates the search overlay
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.descendant(of: section, matching: find.text('Thabo Nkosi')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Thabo Mokoena')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Book Appointment')), findsOneWidget);
      expect(find.descendant(of: section, matching: find.text('Take Payment')), findsOneWidget);

      await tester.tap(find.descendant(of: section, matching: find.text('View')).first);
      await tester.pumpAndSettle();
      expect(find.text('Front desk view'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Register Patient quick action navigates to RegisterPatientView and back', (tester) async {
      await _pumpApp(tester, const Size(1400, 2400), preview: true);

      final section = find.byType(QuickActionsSection);
      await tester.tap(find.descendant(of: section, matching: find.text('Register Patient')));
      await tester.pumpAndSettle();

      expect(find.text('Back to Dashboard'), findsOneWidget);
      expect(find.byType(RegisterPatientView), findsOneWidget);

      await tester.tap(find.text('Back to Dashboard'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPatientView), findsNothing);
      expect(find.byType(QuickActionsSection), findsOneWidget);
    });

    testWidgets('mobile: Register Patient has no bottom navigation bar', (tester) async {
      await _pumpApp(tester, const Size(390, 844), preview: true);

      await tester.scrollUntilVisible(find.text('Register Patient'), 500, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      final section = find.byType(QuickActionsSection);
      await tester.tap(find.descendant(of: section, matching: find.text('Register Patient')));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPatientView), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPatientView), findsNothing);
      expect(find.byType(QuickActionsSection), findsOneWidget);
    });

    testWidgets('tablet: Register Patient has no bottom navigation bar', (tester) async {
      await _pumpApp(tester, const Size(800, 1024), preview: true);

      await tester.scrollUntilVisible(find.text('Register Patient'), 500, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      final section = find.byType(QuickActionsSection);
      await tester.tap(find.descendant(of: section, matching: find.text('Register Patient')));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPatientView), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPatientView), findsNothing);
      expect(find.byType(QuickActionsSection), findsOneWidget);
    });

    testWidgets('mobile: search field allows typing and filtering without premature navigation, then opens preview', (tester) async {
      await _pumpApp(tester, const Size(390, 844), preview: true);

      await tester.scrollUntilVisible(find.text('Quick Actions'), 500, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      final section = find.byType(QuickActionsSection);
      final searchField = find.descendant(of: section, matching: find.byType(TextField));
      expect(searchField, findsOneWidget);

      final textFieldWidget = tester.widget<TextField>(searchField);
      expect(textFieldWidget.decoration?.hintText, 'Name, ID, phone or file number');

      // Tapping activates search and triggers green styling effect
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      expect(find.byType(PatientFrontDeskPreviewView), findsNothing);

      final searchContainer = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(AppSearchField), matching: find.byType(AnimatedContainer)).first,
      );
      final boxDecoration = searchContainer.decoration as BoxDecoration;
      expect(boxDecoration.color, AppColors.brandTint.withValues(alpha: 0.35));
      expect((boxDecoration.border as Border).top.color, AppColors.brandPrimary);

      // Entering text filters patients
      await tester.enterText(searchField, 'Naledi');
      await tester.pumpAndSettle();

      expect(find.text('Naledi Molefe'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsNothing);

      // Tapping the matched result opens preview in mobile layout
      await tester.tap(find.text('Naledi Molefe'));
      await tester.pumpAndSettle();

      expect(find.byType(PatientFrontDeskPreviewView), findsOneWidget);
      expect(find.text('Naledi Molefe'), findsOneWidget);
      expect(find.byKey(const Key('front_desk_preview_back_button')), findsOneWidget);

      // Back button navigates back to Dashboard
      await tester.tap(find.byKey(const Key('front_desk_preview_back_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PatientFrontDeskPreviewView), findsNothing);
      expect(find.byType(QuickActionsSection), findsOneWidget);
    });

    testWidgets('tablet: search field allows typing and filtering without premature navigation, then opens preview', (tester) async {
      await _pumpApp(tester, const Size(800, 1024), preview: true);

      await tester.scrollUntilVisible(find.text('Quick Actions'), 500, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      final section = find.byType(QuickActionsSection);
      final searchField = find.descendant(of: section, matching: find.byType(TextField));
      expect(searchField, findsOneWidget);

      // Tapping does NOT navigate away immediately
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      expect(find.byType(PatientFrontDeskPreviewView), findsNothing);

      // Entering text filters patients
      await tester.enterText(searchField, 'Sipho');
      await tester.pumpAndSettle();

      expect(find.text('Sipho Dlamini'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsNothing);

      // Tapping the matched result opens preview in tablet layout
      await tester.tap(find.text('Sipho Dlamini'));
      await tester.pumpAndSettle();

      expect(find.byType(PatientFrontDeskPreviewView), findsOneWidget);
      expect(find.text('Sipho Dlamini'), findsOneWidget);
      expect(find.byKey(const Key('front_desk_preview_back_button')), findsOneWidget);

      // Back button navigates back to Dashboard
      await tester.tap(find.byKey(const Key('front_desk_preview_back_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PatientFrontDeskPreviewView), findsNothing);
      expect(find.byType(QuickActionsSection), findsOneWidget);
    });

    testWidgets('quick actions shows No patient found card when search misses and navigates to Register', (tester) async {
      await _pumpApp(tester, const Size(1400, 2400), preview: true);

      final section = find.byType(QuickActionsSection);
      final searchField = find.descendant(of: section, matching: find.byType(TextField));

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'NonExistentPatient');
      await tester.pumpAndSettle();

      expect(find.text('No patient found'), findsOneWidget);
      expect(find.text('Check the search details or register a new patient.'), findsOneWidget);
      expect(find.text('Register New Patient'), findsOneWidget);

      await tester.tap(find.text('Register New Patient'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPatientView), findsOneWidget);
    });
  });

  group('main navigation', () {
    const labels = ['Dashboard', 'Queue', 'Patients', 'Appointments', 'Billing'];

    String? selectedLabel(WidgetTester tester) {
      final selected = tester.widgetList<AppNavItem>(find.byType(AppNavItem)).where((i) => i.selected).toList();
      expect(selected.length, lessThanOrEqualTo(1));
      return selected.isEmpty ? null : selected.first.label;
    }

    Future<void> goThrough(WidgetTester tester, Finder bar) async {
      expect(selectedLabel(tester), 'Dashboard');
      for (final label in labels.skip(1)) {
        await tester.tap(find.descendant(of: bar, matching: find.text(label)));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(selectedLabel(tester), label, reason: 'selected item after opening $label');
        expect(find.text(label), findsWidgets);
      }
      await tester.tap(find.descendant(of: bar, matching: find.text('Dashboard')));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(selectedLabel(tester), 'Dashboard');
      expect(tester.takeException(), isNull);
    }

    testWidgets('desktop sidebar navigates between all five pages and tracks the selection', (tester) async {
      await _pumpApp(tester, const Size(1400, 1000), preview: true);
      await goThrough(tester, find.byType(AppSideNavigation));
    });

    testWidgets('tablet bottom bar navigates between all five pages and tracks the selection', (tester) async {
      await _pumpApp(tester, const Size(744, 1100), preview: true);
      await goThrough(tester, find.byType(AppBottomNavigation));
    });

    testWidgets('mobile bottom bar navigates between all five pages and tracks the selection', (tester) async {
      await _pumpApp(tester, const Size(393, 852), preview: true);
      await goThrough(tester, find.byType(AppBottomNavigation));
    });

    testWidgets('page headings follow the platform (Web H1 on desktop and tablet, Mobile H1 on phones)', (tester) async {
      for (final (size, expected) in [(const Size(1400, 1000), 32.0), (const Size(744, 1100), 32.0), (const Size(393, 852), 28.0)]) {
        await _pumpApp(tester, size, preview: true);
        Get.offNamed(AppRoutes.appointments);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final heading = tester.widget<Text>(find.descendant(of: find.byWidgetPredicate((w) => w is Semantics && w.properties.header == true), matching: find.text('Appointments')));
        expect(heading.style!.fontSize, expected, reason: '$size');
      }
    });
  });

  group('queue', () {
    Future<void> openQueue(WidgetTester tester, Size size) async {
      await _pumpApp(tester, size, preview: true);
      Get.offNamed(AppRoutes.queue);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    String? selectedLabel(WidgetTester tester) => tester
        .widgetList<AppNavItem>(find.byType(AppNavItem))
        .where((i) => i.selected)
        .map((i) => i.label)
        .singleOrNull;

    testWidgets(
      'desktop shows the table, summary, pagination and Queue selected',
      (tester) async {
        await openQueue(tester, const Size(1400, 1000));

        expect(selectedLabel(tester), 'Queue');
        expect(find.text('Today’s queue'), findsOneWidget);
        expect(find.text('Patients waiting'), findsOneWidget);
        expect(find.text('Q014'), findsOneWidget);
        expect(find.text('Waiting for Doctor'), findsOneWidget);
        expect(find.text('Showing 1–5 of 5 patients'), findsOneWidget);
        expect(find.text('Add Walk-in'), findsOneWidget);

        // Search narrows the table; the status filter composes with it.
        await tester.enterText(find.byType(TextField), 'naledi');
        await tester.pumpAndSettle();
        expect(find.text('Q015'), findsOneWidget);
        expect(find.text('Q014'), findsNothing);
        expect(find.text('Showing 1–1 of 1 patients'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        expect(
          find.text('No patients match your search or filter.'),
          findsOneWidget,
        );

        // The row menu offers both actions.
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Queue actions').first);
        await tester.pumpAndSettle();
        expect(find.text('View Patient'), findsOneWidget);
        expect(find.text('Assign Practitioner'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('desktop status filter keeps only the chosen status', (
      tester,
    ) async {
      await openQueue(tester, const Size(1400, 1000));
      await tester.tap(find.byTooltip('Filter by status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('With Nurse').last);
      await tester.pumpAndSettle();
      expect(find.text('Q016'), findsOneWidget);
      expect(find.text('Q014'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'tablet shows queue cards, sync chip and Queue selected in the bottom bar',
      (tester) async {
        await openQueue(tester, const Size(744, 1100));

        expect(selectedLabel(tester), 'Queue');
        expect(find.byType(AppBottomNavigation), findsOneWidget);
        expect(find.text('Synced'), findsOneWidget);
        expect(find.text('Seen today'), findsOneWidget);
        expect(find.text('Arrival: 09:18'), findsOneWidget);
        expect(find.byType(DataTable), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mobile fits a small phone with large text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openQueue(tester, const Size(360, 800));

      expect(selectedLabel(tester), 'Queue');
      expect(
        find.textContaining('12 patients currently in queue'),
        findsOneWidget,
      );
      expect(find.text('Average wait'), findsOneWidget);
      expect(find.text('Seen today'), findsNothing);
      expect(find.byTooltip('Filter by status'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Add Walk-in'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Add Walk-in'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('resizing across breakpoints keeps the Queue page error-free', (
      tester,
    ) async {
      await openQueue(tester, const Size(1400, 1000));
      for (final size in [
        const Size(900, 1000),
        const Size(500, 900),
        const Size(1400, 1000),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size');
      }
    });

    testWidgets('doctor queue desktop shows My Patient Queue, Call Next Patient, and table', (tester) async {
      await _pumpApp(tester, const Size(1400, 1000), preview: true);
      RoleController.to.currentRole.value = ClinicRole.doctor;
      Get.offNamed(AppRoutes.queue);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('My Patient Queue'), findsOneWidget);
      expect(find.text('Call Next Patient'), findsOneWidget);
      expect(find.text('Patients Awaiting Consultation'), findsOneWidget);
      expect(find.text('Thabo Mokoena'), findsOneWidget);
      expect(find.text('Q-004'), findsOneWidget);
      expect(find.text('Showing 1–5 of 24 patients'), findsOneWidget);

      // Search filters doctor queue
      await tester.enterText(find.byType(TextField), 'Naledi');
      await tester.pumpAndSettle();
      expect(find.text('Naledi Molefe'), findsOneWidget);
      expect(find.text('Thabo Mokoena'), findsNothing);
      expect(find.text('Showing 1–1 of 1 patients'), findsOneWidget);

      // Search with non-matching query displays empty state and Clear search works
      await tester.enterText(find.byType(TextField), 'Zandile');
      await tester.pumpAndSettle();
      expect(find.text('No patients match “Zandile”'), findsOneWidget);
      expect(find.text('Check the spelling, or search by ID or queue number.'), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Thabo Mokoena'), findsOneWidget);
      expect(find.text('No patients match “Zandile”'), findsNothing);

      // When doctor queue has no patients waiting (empty queue without search query)
      final queueCtrl = Get.find<QueueController>();
      final originalList = List<QueueEntry>.from(queueCtrl.doctorQueueList);
      queueCtrl.doctorQueueList.clear();
      await tester.pumpAndSettle();
      expect(find.text('No patients waiting'), findsOneWidget);
      expect(find.text('New patients appear here when reception checks them in.'), findsOneWidget);
      expect(find.byType(NoPatientsWaitingIllustration), findsOneWidget);
      expect(find.text('Clear search'), findsNothing);

      // Restore queue
      queueCtrl.doctorQueueList.assignAll(originalList);
      await tester.pumpAndSettle();
      expect(find.text('Thabo Mokoena'), findsOneWidget);

      // Tap Call Next Patient to open modal
      await tester.tap(find.text('Call Next Patient'));
      await tester.pumpAndSettle();

      expect(find.text('Call next patient?'), findsOneWidget);
      expect(find.text('The patient will be called to Consultation room 2.'), findsOneWidget);
      expect(find.text('Call patient'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Call next patient?'), findsNothing);

      // Overflow menu and patient drawer on desktop
      await tester.tap(find.byTooltip('Queue actions').first);
      await tester.pumpAndSettle();
      expect(find.text('View Profile'), findsOneWidget);
      expect(find.text('Update Status'), findsOneWidget);
      expect(find.text('Mark Unavailable'), findsOneWidget);

      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorQueuePatientDrawer), findsOneWidget);
      expect(find.text('Update status'), findsNothing);
      expect(find.text('Mark unavailable'), findsNothing);

      // Tapping 'Open profile' triggers AppNotice, does not open a new page
      await tester.tap(find.text('Open profile'));
      await tester.pump();
      expect(find.byType(DoctorQueuePatientDrawer), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorQueuePatientDrawer), findsNothing);

      // Mark Unavailable opens DoctorMarkUnavailableDrawer on desktop
      await tester.tap(find.byTooltip('Queue actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark Unavailable'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorMarkUnavailableDrawer), findsOneWidget);
      expect(find.text('Return to queue'), findsOneWidget);
      expect(find.text('Mark as no-show'), findsOneWidget);
      expect(find.text('Reception is notified of the change.'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorMarkUnavailableDrawer), findsNothing);
    });

    testWidgets('doctor queue tablet shows 2-column cards and Call Next Patient button', (tester) async {
      await _pumpApp(tester, const Size(800, 1100), preview: true);
      RoleController.to.currentRole.value = ClinicRole.doctor;
      Get.offNamed(AppRoutes.queue);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('My Patient Queue'), findsOneWidget);
      expect(find.text('Call Next Patient'), findsOneWidget);
      expect(find.text('Patients Awaiting Consultation'), findsOneWidget);
      expect(find.text('Thabo Mokoena'), findsOneWidget);
      expect(find.text('Q-004'), findsOneWidget);

      await tester.tap(find.text('Call Next Patient'));
      await tester.pumpAndSettle();

      expect(find.byType(CallNextPatientDialog), findsOneWidget);
      expect(find.text('Call next patient?'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CallNextPatientDialog),
          matching: find.text('Naledi Molefe'),
        ),
        findsOneWidget,
      );
      expect(find.text('Call patient'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CallNextPatientDialog), findsNothing);

      // Open patient full page on tablet (no bottom navigation)
      await tester.tap(find.byTooltip('Queue actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorQueuePatientTabletPage), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(find.text('Update status'), findsNothing);
      expect(find.text('Mark unavailable'), findsNothing);

      await tester.tap(find.text('Open profile'));
      await tester.pump();
      expect(find.byType(DoctorQueuePatientTabletPage), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(AppIcons.chevronLeft));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorQueuePatientTabletPage), findsNothing);

      // Mark Unavailable opens DoctorMarkUnavailableTabletPage without bottom nav
      await tester.tap(find.byTooltip('Queue actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark Unavailable'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorMarkUnavailableTabletPage), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(find.text('Return to queue'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorMarkUnavailableTabletPage), findsNothing);
    });

    testWidgets('doctor queue mobile shows single-column cards and Call Next Patient button', (tester) async {
      await _pumpApp(tester, const Size(393, 852), preview: true);
      RoleController.to.currentRole.value = ClinicRole.doctor;
      Get.offNamed(AppRoutes.queue);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('My Patient Queue'), findsOneWidget);
      expect(find.text('Patients Awaiting Consultation'), findsOneWidget);
      expect(find.text('Thabo Mokoena'), findsOneWidget);
      expect(find.text('Q-004'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Call Next Patient'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Call Next Patient'), findsOneWidget);

      await tester.tap(find.text('Call Next Patient'));
      await tester.pumpAndSettle();

      expect(find.text('Call next patient?'), findsOneWidget);
      expect(find.text('The patient will be called to Consultation room 2.'), findsOneWidget);
      expect(find.text('Call patient'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Call next patient?'), findsNothing);

      // Open patient full page on mobile (no bottom navigation)
      await tester.scrollUntilVisible(
        find.byTooltip('Queue actions').first,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip('Queue actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorQueuePatientTabletPage), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(find.text('Update status'), findsNothing);
      expect(find.text('Mark unavailable'), findsNothing);

      await tester.tap(find.text('Open profile'));
      await tester.pump();
      expect(find.byType(DoctorQueuePatientTabletPage), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(AppIcons.chevronLeft));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorQueuePatientTabletPage), findsNothing);

      // Mark Unavailable opens DoctorMarkUnavailableBottomSheet on mobile
      await tester.scrollUntilVisible(
        find.byTooltip('Queue actions').first,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip('Queue actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark Unavailable'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorMarkUnavailableBottomSheet), findsOneWidget);
      expect(find.text('Return to queue'), findsOneWidget);
      expect(find.text('Call patient'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorMarkUnavailableBottomSheet), findsNothing);
    });
  });
}
