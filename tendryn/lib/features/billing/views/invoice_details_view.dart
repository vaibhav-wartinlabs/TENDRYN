import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';
import 'package:tendryn/features/billing/models/billing_invoice_model.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// View modes for Invoice details, single payment, split payment, and payment link.
enum InvoiceViewMode {
  details,
  recordPayment,
  splitPayment,
  sendPaymentLink,
  reviewPaymentLink,
}

/// Full screen view for Tablet & Mobile (and direct route fallback on Desktop).
class InvoiceDetailsView extends StatefulWidget {
  const InvoiceDetailsView({
    super.key,
    this.initialInvoice,
    this.initialRecordPayment = false,
    this.initialSplitPayment = false,
    this.initialSendPaymentLink = false,
    this.initialReviewPaymentLink = false,
  });

  final BillingInvoiceModel? initialInvoice;
  final bool initialRecordPayment;
  final bool initialSplitPayment;
  final bool initialSendPaymentLink;
  final bool initialReviewPaymentLink;

  @override
  State<InvoiceDetailsView> createState() => _InvoiceDetailsViewState();
}

class _InvoiceDetailsViewState extends State<InvoiceDetailsView> {
  late InvoiceViewMode _mode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (widget.initialReviewPaymentLink || args?['isReviewPaymentLink'] == true) {
      _mode = InvoiceViewMode.reviewPaymentLink;
    } else if (widget.initialSendPaymentLink || args?['isSendPaymentLink'] == true) {
      _mode = InvoiceViewMode.sendPaymentLink;
    } else if (widget.initialSplitPayment || args?['isSplitPayment'] == true) {
      _mode = InvoiceViewMode.splitPayment;
    } else if (widget.initialRecordPayment || args?['isRecordPayment'] == true) {
      _mode = InvoiceViewMode.recordPayment;
    } else {
      _mode = InvoiceViewMode.details;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeMode(InvoiceViewMode newMode) {
    setState(() => _mode = newMode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _handleBack() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (_mode == InvoiceViewMode.reviewPaymentLink) {
      _changeMode(InvoiceViewMode.sendPaymentLink);
    } else if (_mode != InvoiceViewMode.details &&
        !widget.initialRecordPayment &&
        !widget.initialSplitPayment &&
        !widget.initialSendPaymentLink &&
        !widget.initialReviewPaymentLink &&
        args?['isRecordPayment'] != true &&
        args?['isSplitPayment'] != true &&
        args?['isSendPaymentLink'] != true &&
        args?['isReviewPaymentLink'] != true) {
      _changeMode(InvoiceViewMode.details);
    } else {
      Get.back();
    }
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('invoice_details_back_button'),
        onTap: _handleBack,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: SizedBox.square(
          dimension: Dimensions.touchTarget,
          child: Center(
            child: Container(
              width: Dimensions.touchTarget,
              height: Dimensions.touchTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: Dimensions.strokeDivider,
                ),
              ),
              child: const Icon(
                AppIcons.chevronLeft,
                size: Dimensions.iconSize,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirmPayment(BillingInvoiceModel invoice) {
    _handlePaymentConfirmed(invoice);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Get.back();
    });
  }

  void _onSendPaymentLinkConfirmed(BillingInvoiceModel invoice) {
    if (Get.isRegistered<BillingController>()) {
      Get.find<BillingController>().confirmPaymentLinkSent(invoice);
    }
    Get.back();
  }

  String get _title {
    switch (_mode) {
      case InvoiceViewMode.details:
        return 'Invoice Details';
      case InvoiceViewMode.recordPayment:
        return 'Record Payment';
      case InvoiceViewMode.splitPayment:
        return 'Split Payment';
      case InvoiceViewMode.sendPaymentLink:
        return 'Send Payment Link';
      case InvoiceViewMode.reviewPaymentLink:
        return 'Review Payment Link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final invoice = widget.initialInvoice ??
        (args?['invoice'] as BillingInvoiceModel?) ??
        (Get.isRegistered<BillingController>()
            ? Get.find<BillingController>().invoices.first
            : const BillingInvoiceModel(
                id: 'inv-1',
                patientName: 'Thabo Nkosi',
                invoiceNumber: 'INV-2026-0148',
                status: InvoiceStatus.partPaid,
                amountText: 'R 350 outstanding',
              ));

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final hPadding = isMobile ? Dimensions.pageMarginMobile : Dimensions.pageMarginDesktop;
    final vPadding = isMobile ? 16.0 : 20.0;

    final actionButtons = InvoiceDetailsActionButtons(
      mode: _mode,
      isDrawer: false,
      onTapRecordPayment: () => _changeMode(InvoiceViewMode.recordPayment),
      onTapSplitPayment: () => _changeMode(InvoiceViewMode.splitPayment),
      onConfirmRecordPayment: () => _onConfirmPayment(invoice),
      onTapBack: _handleBack,
      onReviewLink: () => _changeMode(InvoiceViewMode.reviewPaymentLink),
      onSendLink: () => _onSendPaymentLinkConfirmed(invoice),
    );

    final header = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDefault),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: hPadding,
          top: vPadding,
          right: hPadding,
        ),
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _title,
                style: AppTextStyles.h2Mobile.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final content = ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, vPadding),
      children: [
        InvoiceDetailsBodyContent(
          invoice: invoice,
          mode: _mode,
        ),
        const SizedBox(height: 24),
      ],
    );

    final contentWithFixedHeader = Column(
      children: [
        header,
        Expanded(child: content),
      ],
    );

    final Widget pageBody = isDesktop
        ? Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: contentWithFixedHeader,
            ),
          )
        : contentWithFixedHeader;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isTablet
          ? Column(
              children: [
                const TabletHeader(),
                Expanded(child: pageBody),
              ],
            )
          : SafeArea(
              bottom: false,
              child: pageBody,
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderDefault, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 720 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPadding,
                    vertical: Dimensions.spaceMd,
                  ),
                  child: actionButtons,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop overlay drawer that slides in from the right over Billing.
class InvoiceDetailsDrawer extends StatefulWidget {
  const InvoiceDetailsDrawer({
    super.key,
    required this.invoice,
    required this.onClose,
    this.initialRecordPayment = false,
    this.initialSplitPayment = false,
    this.initialSendPaymentLink = false,
    this.initialReviewPaymentLink = false,
  });

  final BillingInvoiceModel invoice;
  final VoidCallback onClose;
  final bool initialRecordPayment;
  final bool initialSplitPayment;
  final bool initialSendPaymentLink;
  final bool initialReviewPaymentLink;

  @override
  State<InvoiceDetailsDrawer> createState() => _InvoiceDetailsDrawerState();
}

class _InvoiceDetailsDrawerState extends State<InvoiceDetailsDrawer> {
  late InvoiceViewMode _mode;

  @override
  void initState() {
    super.initState();
    if (widget.initialReviewPaymentLink) {
      _mode = InvoiceViewMode.reviewPaymentLink;
    } else if (widget.initialSendPaymentLink) {
      _mode = InvoiceViewMode.sendPaymentLink;
    } else if (widget.initialSplitPayment) {
      _mode = InvoiceViewMode.splitPayment;
    } else if (widget.initialRecordPayment) {
      _mode = InvoiceViewMode.recordPayment;
    } else {
      _mode = InvoiceViewMode.details;
    }
  }

  void _onConfirmPayment() {
    _handlePaymentConfirmed(widget.invoice);
    Future.delayed(const Duration(milliseconds: 300), widget.onClose);
  }

  void _onSendPaymentLinkConfirmed() {
    if (Get.isRegistered<BillingController>()) {
      Get.find<BillingController>().confirmPaymentLinkSent(widget.invoice);
    }
    widget.onClose();
  }

  String get _drawerTitle {
    switch (_mode) {
      case InvoiceViewMode.details:
        return 'Invoice details';
      case InvoiceViewMode.recordPayment:
        return 'Record payment';
      case InvoiceViewMode.splitPayment:
        return 'Split payment';
      case InvoiceViewMode.sendPaymentLink:
        return 'Send payment link';
      case InvoiceViewMode.reviewPaymentLink:
        return 'Review Payment Link';
    }
  }

  String get _drawerSubtitle {
    switch (_mode) {
      case InvoiceViewMode.details:
        return '${widget.invoice.patientName} · ${widget.invoice.visitDate}';
      case InvoiceViewMode.recordPayment:
      case InvoiceViewMode.splitPayment:
      case InvoiceViewMode.sendPaymentLink:
      case InvoiceViewMode.reviewPaymentLink:
        return '${widget.invoice.invoiceNumber} · ${widget.invoice.outstanding} outstanding';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 16,
        shadowColor: Colors.black45,
        child: Container(
          width: Dimensions.drawerWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _drawerTitle,
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _drawerSubtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: widget.onClose,
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: AppColors.backgroundApp,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          AppIcons.close,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.borderDefault),
              // Drawer Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: InvoiceDetailsBodyContent(
                    invoice: widget.invoice,
                    mode: _mode,
                  ),
                ),
              ),
              // Drawer Sticky Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.borderDefault, width: 1),
                  ),
                ),
                child: InvoiceDetailsActionButtons(
                  mode: _mode,
                  isDrawer: true,
                  onTapRecordPayment: () {
                    setState(() => _mode = InvoiceViewMode.recordPayment);
                  },
                  onTapSplitPayment: () {
                    setState(() => _mode = InvoiceViewMode.splitPayment);
                  },
                  onConfirmRecordPayment: _onConfirmPayment,
                  onTapBack: () {
                    if (_mode == InvoiceViewMode.reviewPaymentLink) {
                      setState(() => _mode = InvoiceViewMode.sendPaymentLink);
                    } else if (_mode != InvoiceViewMode.details &&
                        !widget.initialRecordPayment &&
                        !widget.initialSplitPayment &&
                        !widget.initialSendPaymentLink &&
                        !widget.initialReviewPaymentLink) {
                      setState(() => _mode = InvoiceViewMode.details);
                    } else {
                      widget.onClose();
                    }
                  },
                  onReviewLink: () {
                    setState(() => _mode = InvoiceViewMode.reviewPaymentLink);
                  },
                  onSendLink: _onSendPaymentLinkConfirmed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to display the drawer on Desktop overlay.
void showInvoiceDetailsDrawer(
  BuildContext context,
  BillingInvoiceModel invoice, {
  bool initialRecordPayment = false,
  bool initialSplitPayment = false,
  bool initialSendPaymentLink = false,
  bool initialReviewPaymentLink = false,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return InvoiceDetailsDrawer(
        invoice: invoice,
        initialRecordPayment: initialRecordPayment,
        initialSplitPayment: initialSplitPayment,
        initialSendPaymentLink: initialSendPaymentLink,
        initialReviewPaymentLink: initialReviewPaymentLink,
        onClose: () => Navigator.of(dialogContext).pop(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(
        position: slideAnimation,
        child: child,
      );
    },
  );
}

/// Shared helper to record payment and display user feedback.
void _handlePaymentConfirmed(BillingInvoiceModel invoice, [String? amount]) {
  if (Get.isRegistered<BillingController>()) {
    Get.find<BillingController>().recordPayment(invoice, amount: amount);
  } else {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Payment Recorded',
      'Payment of ${amount ?? invoice.outstanding} successfully recorded for ${invoice.patientName}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.feedbackSuccessTint,
      colorText: AppColors.feedbackSuccess,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }
}

/// Reusable body content with Patient, Invoice Breakdown, and Payment Status/Details cards.
class InvoiceDetailsBodyContent extends StatefulWidget {
  const InvoiceDetailsBodyContent({
    super.key,
    required this.invoice,
    this.mode = InvoiceViewMode.details,
    this.isRecordingPayment = false,
  });

  final BillingInvoiceModel invoice;
  final InvoiceViewMode mode;
  final bool isRecordingPayment;

  @override
  State<InvoiceDetailsBodyContent> createState() =>
      _InvoiceDetailsBodyContentState();
}

class _InvoiceDetailsBodyContentState extends State<InvoiceDetailsBodyContent> {
  String _selectedMethod = 'Cash';
  late TextEditingController _amountController;

  // Split payment controllers & selection
  final Set<String> _splitMethods = {'Cash', 'Card'};
  late TextEditingController _cashSplitController;
  late TextEditingController _cardSplitController;
  late TextEditingController _eftSplitController;
  late TextEditingController _instantSplitController;

  // Send payment link controllers
  late TextEditingController _sendAmountController;
  late TextEditingController _sendToController;
  late TextEditingController _phoneOrEmailController;
  late TextEditingController _channelController;

  static const List<String> _methods = ['Cash', 'Card', 'EFT', 'Instant'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.invoice.outstanding);
    _cashSplitController = TextEditingController(text: 'R 100.00');
    _cardSplitController = TextEditingController(text: 'R 250.00');
    _eftSplitController = TextEditingController(text: 'R 0.00');
    _instantSplitController = TextEditingController(text: 'R 0.00');

    _sendAmountController =
        TextEditingController(text: widget.invoice.outstanding);
    _sendToController =
        TextEditingController(text: 'Family member · Daughter');
    _phoneOrEmailController = TextEditingController(text: '083 000 1234');
    _channelController = TextEditingController(text: 'WhatsApp');
  }

  @override
  void didUpdateWidget(covariant InvoiceDetailsBodyContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoice.outstanding != widget.invoice.outstanding) {
      _amountController.text = widget.invoice.outstanding;
      _sendAmountController.text = widget.invoice.outstanding;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cashSplitController.dispose();
    _cardSplitController.dispose();
    _eftSplitController.dispose();
    _instantSplitController.dispose();
    _sendAmountController.dispose();
    _sendToController.dispose();
    _phoneOrEmailController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  InvoiceViewMode get _effectiveMode {
    if (widget.mode != InvoiceViewMode.details) {
      return widget.mode;
    }
    return widget.isRecordingPayment
        ? InvoiceViewMode.recordPayment
        : InvoiceViewMode.details;
  }

  Color _getBadgeBg(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.partPaid:
        return AppColors.feedbackWarningTint;
      case InvoiceStatus.unpaid:
        return AppColors.feedbackInfoTint;
      case InvoiceStatus.paid:
        return AppColors.feedbackSuccessTint;
    }
  }

  Color _getBadgeText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.partPaid:
        return AppColors.feedbackWarning;
      case InvoiceStatus.unpaid:
        return AppColors.feedbackInfo;
      case InvoiceStatus.paid:
        return AppColors.feedbackSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _effectiveMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Patient Header Card (Mint tinted background)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.brandTint),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.invoice.patientName,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.invoice.fileNumber,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Invoice Breakdown Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Invoice ${widget.invoice.invoiceNumber}',
                style: AppTextStyles.h3Mobile.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildLineRow('Consultation', widget.invoice.consultationFee),
              const SizedBox(height: 12),
              _buildLineRow('Dispensed items', widget.invoice.dispensedItemsFee),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: AppColors.backgroundApp),
              const SizedBox(height: 16),
              _buildLineRow('Invoice total', widget.invoice.invoiceTotal,
                  isTotal: true, isGreen: true),
              const SizedBox(height: 12),
              _buildLineRow('Already paid', widget.invoice.alreadyPaid),
              const SizedBox(height: 12),
              _buildLineRow('Outstanding', widget.invoice.outstanding,
                  isTotal: true, isGreen: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Card 3: Send payment link OR Review payment link OR Split payment OR Record payment OR Payment status
        if (mode == InvoiceViewMode.reviewPaymentLink)
          _buildConfirmBeforeSendingCard()
        else if (mode == InvoiceViewMode.sendPaymentLink)
          _buildSendPaymentLinkDetailsCard()
        else if (mode == InvoiceViewMode.splitPayment)
          _buildSplitPaymentDetailsCard()
        else if (mode == InvoiceViewMode.recordPayment)
          _buildPaymentDetailsCard()
        else
          _buildPaymentStatusCard(),
      ],
    );
  }

  /// Card 3 in Review Payment Link mode ("Confirm before sending")
  Widget _buildConfirmBeforeSendingCard() {
    final amountText = _sendAmountController.text.trim().isNotEmpty
        ? _sendAmountController.text.trim()
        : widget.invoice.outstanding;
    final recipientText = _sendToController.text.contains('Family')
        ? 'Family member'
        : (_sendToController.text.trim().isNotEmpty
            ? _sendToController.text.trim()
            : 'Family member');
    final channelText = _channelController.text.trim().isNotEmpty
        ? _channelController.text.trim()
        : 'WhatsApp';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confirm before sending',
            style: AppTextStyles.h3Mobile.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Only payment details are shared',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          _buildConfirmRow('Amount', amountText, isHighlight: true),
          const SizedBox(height: Dimensions.sectionContentGap),
          _buildConfirmRow('Recipient', recipientText),
          const SizedBox(height: Dimensions.sectionContentGap),
          _buildConfirmRow('Channel', channelText),
          const SizedBox(height: Dimensions.sectionContentGap),
          _buildConfirmRow('Expiry', '72 hours'),
          const SizedBox(height: Dimensions.pageSectionGap),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.feedbackInfoTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Text(
              'Payer sees clinic, invoice, amount and patient first name only.',
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: AppColors.feedbackInfo,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.tabular(
            AppTextStyles.label.copyWith(
              fontSize: isHighlight ? 15 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppColors.brandPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Card 3 in Send Payment Link mode (Matches Images 1, 2, 3, 4)
  Widget _buildSendPaymentLinkDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Link details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'For a patient or family member',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Amount
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _sendAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Full balance or enter a part amount.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // 2. Send to
          const Text(
            'Send to',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _sendToController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // 3. Phone or email
          const Text(
            'Phone or email',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _phoneOrEmailController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // 4. Channel
          const Text(
            'Channel',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _channelController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Light blue note banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.feedbackInfoTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: const Text(
              'Expires after 72 hours. Gateway handles card and instant EFT.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.feedbackInfo,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 3 in Split Payment mode (Matches Figma & screenshots)
  Widget _buildSplitPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Payment details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose a method and confirm the amount',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Method Selector Pills (Multi-selection for split payment)
          Row(
            children: [
              for (int i = 0; i < _methods.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (_splitMethods.contains(_methods[i])) {
                          if (_splitMethods.length > 1) {
                            _splitMethods.remove(_methods[i]);
                          }
                        } else {
                          _splitMethods.add(_methods[i]);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _splitMethods.contains(_methods[i])
                            ? AppColors.brandTint
                            : AppColors.backgroundApp,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _methods[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _splitMethods.contains(_methods[i])
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _splitMethods.contains(_methods[i])
                              ? AppColors.brandPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Active Split Inputs
          if (_splitMethods.contains('Cash')) ...[
            const Text(
              'Cash',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildInputContainer(_cashSplitController),
            const SizedBox(height: 12),
          ],
          if (_splitMethods.contains('Card')) ...[
            const Text(
              'Card',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildInputContainer(_cardSplitController),
            const SizedBox(height: 12),
          ],
          if (_splitMethods.contains('EFT')) ...[
            const Text(
              'EFT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildInputContainer(_eftSplitController),
            const SizedBox(height: 12),
          ],
          if (_splitMethods.contains('Instant')) ...[
            const Text(
              'Instant',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildInputContainer(_instantSplitController),
            const SizedBox(height: 12),
          ],

          // Combined Summary Row
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Combined',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                widget.invoice.outstanding,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // Mint Banner Box: Amounts must add up to R 350.00
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Text(
              'Amounts must add up to ${widget.invoice.outstanding}.',
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 3 in Single Record Payment mode
  Widget _buildPaymentDetailsCard() {
    final amountLabel = _selectedMethod == 'Card'
        ? 'Amount to pay with card'
        : _selectedMethod == 'Cash'
            ? 'Amount to pay in cash'
            : 'Amount to pay via $_selectedMethod';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Payment details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose a method and confirm the amount',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Method Selector Pills
          Row(
            children: [
              for (int i = 0; i < _methods.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedMethod = _methods[i]),
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedMethod == _methods[i]
                            ? AppColors.brandTint
                            : AppColors.backgroundApp,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _methods[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedMethod == _methods[i]
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedMethod == _methods[i]
                              ? AppColors.brandPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // Amount Label
          Text(
            amountLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Amount Input Box
          _buildInputContainer(_amountController),
          const SizedBox(height: 6),
          const Text(
            'Part payments are allowed.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Banner box (Cash received / change due)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Text(
              _selectedMethod == 'Cash'
                  ? 'Cash received R 400.00 · Change due R 50.00'
                  : _selectedMethod == 'Card'
                      ? 'Card terminal ready · Tap or insert card'
                      : _selectedMethod == 'EFT'
                          ? 'EFT reference: ${widget.invoice.invoiceNumber}'
                          : 'Instant payment ready on patient terminal',
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // Disclaimer / Terminal Note
          const Text(
            'Card terminal handles card processing; Tendryn records the result.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Clean input box container without inner borders
  Widget _buildInputContainer(TextEditingController controller) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Card 3 in default Invoice Details mode
  Widget _buildPaymentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Payment status',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _getBadgeBg(widget.invoice.status),
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                ),
                child: Text(
                  widget.invoice.statusLabel,
                  style: TextStyle(
                    color: _getBadgeText(widget.invoice.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.invoice.remainingText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLineRow('Total', widget.invoice.invoiceTotal),
          const SizedBox(height: 12),
          _buildLineRow('Paid', widget.invoice.alreadyPaid),
          const SizedBox(height: 12),
          _buildLineRow('Balance', widget.invoice.outstanding,
              isTotal: true, isGreen: true),
          const SizedBox(height: Dimensions.sectionContentGap),
          const Text(
            'Receipt available after payment. Refunds and voids require Unit Admin approval.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: AppTextStyles.tabular(
            AppTextStyles.label.copyWith(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isGreen ? AppColors.brandPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Action buttons: "Split Payment" & "Record Payment".
class InvoiceDetailsActionButtons extends StatelessWidget {
  const InvoiceDetailsActionButtons({
    super.key,
    this.mode = InvoiceViewMode.details,
    this.isRecordingPayment = false,
    this.isDrawer = false,
    this.onTapRecordPayment,
    this.onTapSplitPayment,
    this.onConfirmRecordPayment,
    this.onTapBack,
    this.onReviewLink,
    this.onSendLink,
  });

  final InvoiceViewMode mode;
  final bool isRecordingPayment;
  final bool isDrawer;
  final VoidCallback? onTapRecordPayment;
  final VoidCallback? onTapSplitPayment;
  final VoidCallback? onConfirmRecordPayment;
  final VoidCallback? onTapBack;
  final VoidCallback? onReviewLink;
  final VoidCallback? onSendLink;

  InvoiceViewMode get _effectiveMode {
    if (mode != InvoiceViewMode.details) return mode;
    return isRecordingPayment ? InvoiceViewMode.recordPayment : InvoiceViewMode.details;
  }

  @override
  Widget build(BuildContext context) {
    if (_effectiveMode == InvoiceViewMode.reviewPaymentLink) {
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTapBack,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              hoverColor: AppColors.brandTint,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                height: Dimensions.buttonMinHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onSendLink,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              hoverColor: AppColors.brandHover,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                height: Dimensions.buttonMinHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: Text(
                  isDrawer ? 'Send Payment Link' : 'Send Link',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_effectiveMode == InvoiceViewMode.sendPaymentLink) {
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTapBack,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              hoverColor: AppColors.brandTint,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                height: Dimensions.buttonMinHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onReviewLink,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              hoverColor: AppColors.brandHover,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                height: Dimensions.buttonMinHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: const Text(
                  'Review Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_effectiveMode == InvoiceViewMode.splitPayment) {
      // Single full-width Record Payment button in Split Payment mode
      return InkWell(
        onTap: onConfirmRecordPayment,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        hoverColor: AppColors.brandHover,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.brandPrimary,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          ),
          child: const Text(
            'Record Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTapSplitPayment,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            hoverColor: AppColors.brandTint,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              height: Dimensions.buttonMinHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Split Payment',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              if (_effectiveMode == InvoiceViewMode.recordPayment) {
                if (onConfirmRecordPayment != null) {
                  onConfirmRecordPayment!();
                }
              } else {
                if (onTapRecordPayment != null) {
                  onTapRecordPayment!();
                }
              }
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            hoverColor: AppColors.brandHover,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              height: Dimensions.buttonMinHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Record Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
