import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/billing/models/billing_invoice_model.dart';
import 'package:tendryn/features/billing/views/invoice_details_view.dart';
import 'package:tendryn/routes/app_routes.dart';

class PaymentSuccessNotice {
  const PaymentSuccessNotice({
    required this.invoiceNumber,
    required this.patientName,
    required this.amountText,
    required this.invoice,
  });

  final String invoiceNumber;
  final String patientName;
  final String amountText;
  final BillingInvoiceModel invoice;
}

class BillingController extends GetxController {
  final searchQuery = ''.obs;
  final paymentSuccessNotice = Rxn<PaymentSuccessNotice>();

  void clearPaymentNotice() {
    paymentSuccessNotice.value = null;
  }

  final invoices = <BillingInvoiceModel>[
    const BillingInvoiceModel(
      id: 'inv-1',
      patientName: 'Thabo Nkosi',
      invoiceNumber: 'INV-2026-0148',
      status: InvoiceStatus.partPaid,
      amountText: 'R 350 outstanding',
      fileNumber: 'File #PT-002184 · 082 ••• ••42 · Visit 29 Sep 2026',
      visitDate: 'Visit 29 Sep 2026',
      consultationFee: 'R 600.00',
      dispensedItemsFee: 'R 250.00',
      invoiceTotal: 'R 850.00',
      alreadyPaid: 'R 500.00',
      outstanding: 'R 350.00',
      remainingText: 'Part paid · R 350.00 remaining',
    ),
    const BillingInvoiceModel(
      id: 'inv-2',
      patientName: 'Nomsa Dube',
      invoiceNumber: 'INV-2026-0152',
      status: InvoiceStatus.unpaid,
      amountText: 'R 1,250 outstanding',
      fileNumber: 'File #PT-001892 · 071 ••• ••88 · Visit 29 Sep 2026',
      visitDate: 'Visit 29 Sep 2026',
      consultationFee: 'R 750.00',
      dispensedItemsFee: 'R 500.00',
      invoiceTotal: 'R 1,250.00',
      alreadyPaid: 'R 0.00',
      outstanding: 'R 1,250.00',
      remainingText: 'Unpaid · R 1,250.00 remaining',
    ),
    const BillingInvoiceModel(
      id: 'inv-3',
      patientName: 'Lindiwe Ndlovu',
      invoiceNumber: 'INV-2026-0149',
      status: InvoiceStatus.paid,
      amountText: 'R 650 paid',
      fileNumber: 'File #PT-003410 · 083 ••• ••18 · Visit 29 Sep 2026',
      visitDate: 'Visit 29 Sep 2026',
      consultationFee: 'R 500.00',
      dispensedItemsFee: 'R 150.00',
      invoiceTotal: 'R 650.00',
      alreadyPaid: 'R 650.00',
      outstanding: 'R 0.00',
      remainingText: 'Paid · Fully settled',
    ),
    const BillingInvoiceModel(
      id: 'inv-4',
      patientName: 'Lindiwe Ndlovu',
      invoiceNumber: 'INV-2026-0149',
      status: InvoiceStatus.paid,
      amountText: 'R 650 paid',
      fileNumber: 'File #PT-003410 · 083 ••• ••18 · Visit 29 Sep 2026',
      visitDate: 'Visit 29 Sep 2026',
      consultationFee: 'R 500.00',
      dispensedItemsFee: 'R 150.00',
      invoiceTotal: 'R 650.00',
      alreadyPaid: 'R 650.00',
      outstanding: 'R 0.00',
      remainingText: 'Paid · Fully settled',
    ),
  ].obs;

  List<BillingInvoiceModel> get filteredInvoices {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return invoices.toList();
    return invoices.where((inv) {
      return inv.patientName.toLowerCase().contains(query) ||
          inv.invoiceNumber.toLowerCase().contains(query);
    }).toList();
  }

  void search(String text) {
    searchQuery.value = text;
  }

  void onViewDetail(BillingInvoiceModel invoice, [BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx != null && ResponsiveHelper.isDesktop(ctx)) {
      showInvoiceDetailsDrawer(ctx, invoice, initialRecordPayment: false);
    } else {
      Get.toNamed(
        AppRoutes.invoiceDetails,
        arguments: {'invoice': invoice, 'isRecordPayment': false},
      );
    }
  }

  void onRecordPayment(BillingInvoiceModel invoice, [BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx != null && ResponsiveHelper.isDesktop(ctx)) {
      showInvoiceDetailsDrawer(ctx, invoice, initialRecordPayment: true);
    } else {
      Get.toNamed(
        AppRoutes.invoiceDetails,
        arguments: {'invoice': invoice, 'isRecordPayment': true},
      );
    }
  }

  void recordPayment(BillingInvoiceModel invoice, {String? amount}) {
    final index = invoices.indexWhere((i) => i.id == invoice.id);
    late BillingInvoiceModel updatedInvoice;
    final displayAmount = amount ?? invoice.outstanding;
    if (index != -1) {
      final current = invoices[index];
      updatedInvoice = BillingInvoiceModel(
        id: current.id,
        patientName: current.patientName,
        invoiceNumber: current.invoiceNumber,
        status: InvoiceStatus.paid,
        amountText: '$displayAmount Paid',
        fileNumber: current.fileNumber,
        visitDate: current.visitDate,
        consultationFee: current.consultationFee,
        dispensedItemsFee: current.dispensedItemsFee,
        invoiceTotal: current.invoiceTotal,
        alreadyPaid: current.invoiceTotal,
        outstanding: 'R 0.00',
        remainingText: 'Paid · Fully settled',
      );
      invoices[index] = updatedInvoice;
    } else {
      updatedInvoice = invoice;
    }

    final rawAmount = displayAmount
        .replaceAll('R', '')
        .replaceAll('.00', '')
        .trim();

    paymentSuccessNotice.value = PaymentSuccessNotice(
      invoiceNumber: invoice.invoiceNumber,
      patientName: invoice.patientName,
      amountText: '$rawAmount paid fully',
      invoice: updatedInvoice,
    );
  }

  void onSendPaymentLink(BillingInvoiceModel invoice, [BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx != null && ResponsiveHelper.isDesktop(ctx)) {
      showInvoiceDetailsDrawer(
        ctx,
        invoice,
        initialSendPaymentLink: true,
      );
    } else {
      Get.toNamed(
        AppRoutes.invoiceDetails,
        arguments: {'invoice': invoice, 'isSendPaymentLink': true},
      );
    }
  }

  void onReviewPaymentLink(BillingInvoiceModel invoice, [BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx != null && ResponsiveHelper.isDesktop(ctx)) {
      showInvoiceDetailsDrawer(
        ctx,
        invoice,
        initialReviewPaymentLink: true,
      );
    } else {
      Get.toNamed(
        AppRoutes.invoiceDetails,
        arguments: {'invoice': invoice, 'isReviewPaymentLink': true},
      );
    }
  }

  final paymentLinkSentNotice = Rxn<String>();

  void confirmPaymentLinkSent(BillingInvoiceModel invoice) {
    paymentLinkSentNotice.value =
        'Payment link of ${invoice.outstanding} sent via WhatsApp.';
  }

  void onCashUp() {
    AppNotice.unavailable('Cash Up', 'Page is not available');
  }

  void onDailyCashUp() {
    AppNotice.unavailable('Daily Cash Up', 'Page is not available');
  }

  void onOutstandingBalances() {
    AppNotice.unavailable('Outstanding Balances', 'Page is not available');
  }

  void onFilter() {
    AppNotice.unavailable('Filter', 'Page is not available');
  }

  void onPagination(int page) {
    AppNotice.unavailable('Page $page', 'Page is not available');
  }
}
