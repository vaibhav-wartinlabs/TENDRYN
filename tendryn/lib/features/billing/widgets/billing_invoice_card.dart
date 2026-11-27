import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';
import 'package:tendryn/features/billing/models/billing_invoice_model.dart';

class BillingInvoiceCard extends StatelessWidget {
  const BillingInvoiceCard({
    super.key,
    required this.invoice,
  });

  final BillingInvoiceModel invoice;

  Color _getBadgeBg() {
    switch (invoice.status) {
      case InvoiceStatus.partPaid:
        return AppColors.feedbackWarningTint;
      case InvoiceStatus.unpaid:
        return AppColors.feedbackInfoTint;
      case InvoiceStatus.paid:
        return AppColors.feedbackSuccessTint;
    }
  }

  Color _getBadgeText() {
    switch (invoice.status) {
      case InvoiceStatus.partPaid:
        return AppColors.feedbackWarning;
      case InvoiceStatus.unpaid:
        return AppColors.feedbackInfo;
      case InvoiceStatus.paid:
        return AppColors.feedbackSuccess;
    }
  }

  void _showMenu(BuildContext anchorContext) {
    final controller = Get.find<BillingController>();
    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.sizeOf(anchorContext);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        const menuWidth = 200.0;
        double left = offset.dx + size.width - menuWidth;
        if (left < 16) left = 16;
        if (left + menuWidth > screenSize.width - 16) {
          left = screenSize.width - menuWidth - 16;
        }

        double top = offset.dy + size.height + 4;
        if (top + 160 > screenSize.height) {
          top = offset.dy - 160 - 4;
        }

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => entry.remove(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Material(
                type: MaterialType.transparency,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPrimary.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MenuOptionTile(
                        title: 'View Detail',
                        onTap: () {
                          entry.remove();
                          controller.onViewDetail(invoice, anchorContext);
                        },
                      ),
                      _MenuOptionTile(
                        title: 'Record Payment',
                        onTap: () {
                          entry.remove();
                          controller.onRecordPayment(invoice, anchorContext);
                        },
                      ),
                      _MenuOptionTile(
                        title: 'Send Payment Link',
                        onTap: () {
                          entry.remove();
                          controller.onSendPaymentLink(invoice, anchorContext);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(anchorContext).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    final controller = Get.find<BillingController>();
                    controller.onViewDetail(invoice, context);
                  },
                  borderRadius: BorderRadius.circular(6),
                  hoverColor: AppColors.brandTint.withValues(alpha: 0.3),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        invoice.patientName,
                        style: AppTextStyles.h3Mobile.copyWith(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: _getBadgeBg(),
                        borderRadius: BorderRadius.circular(Dimensions.radius),
                      ),
                      child: Text(
                        invoice.statusLabel,
                        style: AppTextStyles.label.copyWith(
                          color: _getBadgeText(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                    Text(
                      '${invoice.invoiceNumber}  ·  ${invoice.amountText}',
                      style: AppTextStyles.tabular(
                        AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _InvoiceActionButton(
              onTap: _showMenu,
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _InvoiceActionButton extends StatefulWidget {
  const _InvoiceActionButton({
    required this.onTap,
  });

  final void Function(BuildContext) onTap;

  @override
  State<_InvoiceActionButton> createState() => _InvoiceActionButtonState();
}

class _InvoiceActionButtonState extends State<_InvoiceActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _isHovered || _isPressed;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () => widget.onTap(context),
        child: Container(
          width: Dimensions.touchTarget,
          height: Dimensions.touchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.brandTint : AppColors.backgroundApp,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: active
                  ? AppColors.brandPrimary.withValues(alpha: 0.4)
                  : AppColors.backgroundApp,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      blurRadius: 6,
                    ),
                  ]
                : const [],
          ),
          child: const Icon(
            AppIcons.rowMenu,
            size: 18,
            color: AppColors.brandPrimary,
          ),
        ),
      ),
    );
  }
}

class _MenuOptionTile extends StatefulWidget {
  const _MenuOptionTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  State<_MenuOptionTile> createState() => _MenuOptionTileState();
}

class _MenuOptionTileState extends State<_MenuOptionTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _isHovered || _isPressed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.brandTint : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: active
                  ? Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2))
                  : Border.all(color: Colors.transparent),
            ),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Success notification banner shown on Billing screen after payment recorded.
class PaymentSuccessBanner extends StatelessWidget {
  const PaymentSuccessBanner({
    super.key,
    required this.notice,
    required this.onView,
    this.onClose,
  });

  final PaymentSuccessNotice notice;
  final VoidCallback onView;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(
          color: AppColors.triageGreen,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Success check icon
          const Icon(
            AppIcons.circleCheck,
            size: 20,
            color: AppColors.triageGreen,
          ),
          const SizedBox(width: 12),
          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Payment Recorded Successfully',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${notice.invoiceNumber} · ${notice.patientName} · Amount: ${notice.amountText}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // "View" link action
          InkWell(
            onTap: onView,
            borderRadius: BorderRadius.circular(6),
            hoverColor: AppColors.brandTint.withValues(alpha: 0.5),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Dismiss',
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: AppColors.backgroundApp,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    AppIcons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
