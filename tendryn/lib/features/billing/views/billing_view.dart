import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';
import 'package:tendryn/features/billing/widgets/billing_desktop.dart';
import 'package:tendryn/features/billing/widgets/billing_invoice_card.dart';
import 'package:tendryn/features/billing/widgets/billing_mobile.dart';
import 'package:tendryn/features/billing/widgets/billing_tablet.dart';

class BillingView extends GetView<BillingController> {
  const BillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const ResponsiveLayout(
            mobile: BillingMobile(),
            tablet: BillingTablet(),
            desktop: BillingDesktop(),
          ),
          // Stack notification banner floating over the top of the billing page
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Obx(() {
              final notice = controller.paymentSuccessNotice.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: notice == null
                    ? const SizedBox.shrink()
                    : Padding(
                        key: ValueKey(notice.invoiceNumber + notice.amountText),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isMobile(context)
                              ? 16
                              : (ResponsiveHelper.isTablet(context) ? 24 : 40),
                        ),
                        child: PaymentSuccessBanner(
                          notice: notice,
                          onView: () {
                            controller.onViewDetail(notice.invoice, context);
                          },
                          onClose: controller.clearPaymentNotice,
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
