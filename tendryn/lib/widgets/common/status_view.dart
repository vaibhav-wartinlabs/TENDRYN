import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/utils/loadable_mixin.dart';
import 'package:tendryn/widgets/common/app_button.dart';

/// Renders loading / error / content for any controller using [LoadableMixin].
/// [builder] runs inside an Obx, so rx values it reads stay reactive.
class StatusView extends StatelessWidget {
  const StatusView({super.key, required this.controller, required this.builder, this.onRetry});

  final LoadableMixin controller;
  final WidgetBuilder builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.status.value) {
        case LoadStatus.idle:
        case LoadStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case LoadStatus.error:
          return _ErrorView(message: controller.errorMessage.value ?? 'Something went wrong.', onRetry: onRetry);
        case LoadStatus.success:
          return builder(context);
      }
    });
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.error, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: Dimensions.spaceSm),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: Dimensions.spaceMd),
              AppButton.primary(label: 'Retry', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
