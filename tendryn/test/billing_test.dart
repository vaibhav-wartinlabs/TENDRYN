import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';
import 'package:tendryn/main.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/routes/initial_binding.dart';
import 'package:tendryn/services/storage_service.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';

class _MemoryStorage implements StorageService {
  final _data = <String, String>{};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return <String>['wifi'];
      }
      return null;
    },
  );
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
        openDashboardPreview: true,
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
  Get.offNamed(AppRoutes.billing);
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  group('Billing page', () {
    testWidgets('renders desktop layout with metrics and invoices', (tester) async {
      await _pumpApp(tester, const Size(1400, 1100));

      expect(find.text('To collect'), findsOneWidget);
      expect(find.text('Paid today'), findsOneWidget);
      expect(find.text('Cash up'), findsOneWidget);
      expect(find.text('Recent Invoices'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsOneWidget);
      expect(find.text('Nomsa Dube'), findsOneWidget);
      expect(find.text('Outstanding balances'), findsOneWidget);
      expect(find.text('Daily cash up'), findsOneWidget);
    });

    testWidgets('renders tablet layout', (tester) async {
      await _pumpApp(tester, const Size(768, 1024));

      expect(find.text('To collect'), findsOneWidget);
      expect(find.text('Paid today'), findsOneWidget);
      expect(find.text('Recent Invoices'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsOneWidget);
    });

    testWidgets('renders mobile layout without overflow', (tester) async {
      await _pumpApp(tester, const Size(393, 852));

      expect(find.text('To collect'), findsOneWidget);
      expect(find.text('Paid today'), findsOneWidget);
      expect(find.text('Recent Invoices'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsOneWidget);
    });

    testWidgets('3-dot menu opens and View Detail opens invoice details drawer on desktop', (tester) async {
      await _pumpApp(tester, const Size(1400, 900));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      expect(moreIcons, findsWidgets);

      // Open menu on first card
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      expect(find.text('View Detail'), findsOneWidget);
      expect(find.text('Record Payment'), findsOneWidget);
      expect(find.text('Send Payment Link'), findsOneWidget);

      // Tap View Detail - opens Desktop drawer
      await tester.tap(find.text('View Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Invoice details'), findsOneWidget);
      expect(find.text('Invoice INV-2026-0148'), findsOneWidget);
      expect(find.text('Consultation'), findsOneWidget);
      expect(find.text('Dispensed items'), findsOneWidget);
      expect(find.text('Payment status'), findsOneWidget);
      expect(find.text('Record Payment'), findsOneWidget);
      expect(find.text('Split Payment'), findsOneWidget);

      // Tap Record Payment inside drawer transitions to Payment details
      await tester.tap(find.text('Record Payment'));
      await tester.pumpAndSettle();
      expect(find.text('Payment details'), findsOneWidget);
      expect(find.text('Choose a method and confirm the amount'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Split Payment'), findsOneWidget);

      // Tap Split Payment transitions to Split Payment mode
      await tester.tap(find.text('Split Payment'));
      await tester.pumpAndSettle();
      expect(find.text('Split payment'), findsOneWidget);
      expect(find.text('Combined'), findsOneWidget);
      expect(find.text('Amounts must add up to R 350.00.'), findsOneWidget);
      // Tap Record Payment in Split Payment mode confirms payment and shows success banner
      await tester.tap(find.text('Record Payment'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('Payment Recorded Successfully'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile 3-dot menu opens and View Detail navigates to invoice details page', (tester) async {
      await _pumpApp(tester, const Size(393, 852));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      expect(moreIcons, findsWidgets);

      // Open menu on first card
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('View Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Invoice Details'), findsOneWidget);
      expect(find.text('Invoice INV-2026-0148'), findsOneWidget);
      expect(find.text('Consultation'), findsOneWidget);
      expect(find.text('Payment status'), findsOneWidget);
    });

    testWidgets('mobile records payment and shows success banner on billing screen', (tester) async {
      await _pumpApp(tester, const Size(393, 852));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Record Payment'));
      await tester.pumpAndSettle();

      expect(find.text('Record Payment'), findsWidgets);
      expect(find.text('Payment details'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final recordButtons = find.widgetWithText(InkWell, 'Record Payment');
      await tester.tap(recordButtons.last);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Payment Recorded Successfully'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.textContaining('350 paid fully'), findsOneWidget);

      // Tap cross button to dismiss
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();
      expect(find.text('Payment Recorded Successfully'), findsNothing);
    });

    testWidgets('search filters invoice list', (tester) async {
      await _pumpApp(tester, const Size(1400, 900));

      final controller = Get.find<BillingController>();
      controller.search('Nomsa');
      await tester.pumpAndSettle();

      expect(find.text('Nomsa Dube'), findsOneWidget);
      expect(find.text('Thabo Nkosi'), findsNothing);
    });

    testWidgets('desktop Send Payment Link opens drawer with Link details', (tester) async {
      await _pumpApp(tester, const Size(1400, 900));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      expect(find.text('Send Payment Link'), findsOneWidget);
      await tester.tap(find.text('Send Payment Link'));
      await tester.pumpAndSettle();

      expect(find.text('Send payment link'), findsOneWidget);
      expect(find.text('Link details'), findsOneWidget);
      expect(find.text('For a patient or family member'), findsOneWidget);
      expect(find.text('Review Link'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Link details'), findsNothing);
    });

    testWidgets('mobile Send Payment Link navigates to page without bottom navigation bar', (tester) async {
      await _pumpApp(tester, const Size(393, 852));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Payment Link'));
      await tester.pumpAndSettle();

      expect(find.text('Send Payment Link'), findsOneWidget);
      expect(find.text('Link details'), findsOneWidget);
      expect(find.text('For a patient or family member'), findsOneWidget);
      // Verify bottom navigation bar is NOT present
      expect(find.byType(AppBottomNavigation), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Review Link'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Link details'), findsNothing);
    });

    testWidgets('desktop clicking Review Link opens Review Payment Link in drawer', (tester) async {
      await _pumpApp(tester, const Size(1400, 900));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Payment Link'));
      await tester.pumpAndSettle();

      expect(find.text('Review Link'), findsOneWidget);
      await tester.tap(find.text('Review Link'));
      await tester.pumpAndSettle();

      expect(find.text('Review Payment Link'), findsOneWidget);
      expect(find.text('Confirm before sending'), findsOneWidget);
      expect(find.text('Only payment details are shared'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Recipient'), findsOneWidget);
      expect(find.text('Family member'), findsOneWidget);
      expect(find.text('Channel'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Expiry'), findsOneWidget);
      expect(find.text('72 hours'), findsOneWidget);
      expect(find.text('Payer sees clinic, invoice, amount and patient first name only.'), findsOneWidget);
      expect(find.text('Send Payment Link'), findsOneWidget);

      // Tap Back to return to Link details
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Link details'), findsOneWidget);

      // Re-enter and tap Send Payment Link
      await tester.tap(find.text('Review Link'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm before sending'), findsOneWidget);

      await tester.tap(find.text('Send Payment Link'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('Confirm before sending'), findsNothing);
    });

    testWidgets('mobile clicking Review Link navigates to Review Payment Link page', (tester) async {
      await _pumpApp(tester, const Size(393, 852));

      final moreIcons = find.byIcon(LucideIcons.ellipsisVertical);
      await tester.tap(moreIcons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Payment Link'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Link'));
      await tester.pumpAndSettle();

      expect(find.text('Review Payment Link'), findsOneWidget);
      expect(find.text('Confirm before sending'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);

      // Scroll to bottom buttons
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Send Link'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Tap Back returns to Send Payment Link
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Link details'), findsOneWidget);

      // Re-enter and tap Send Link
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review Link'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Link'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm before sending'), findsNothing);
    });
  });
}
