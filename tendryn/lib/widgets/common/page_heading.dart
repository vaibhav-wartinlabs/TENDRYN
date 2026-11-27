import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// A main page inside the navigation shell: the page heading at the position
/// and size the Figma frames use, on the app background. Add the page content
/// as [child] when the screen is built.
///   desktop: Web H1 (32/40), 24px margins
///   tablet : Web H1 (32/40), 24px sides, 28px top
///   mobile : Mobile H1 (28/36), 16px margins
class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.title, this.subtitle, this.child});

  final String title;
  final String? subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = ResponsiveHelper.screenType(context);
    final (padding, style) = switch (type) {
      LayoutType.desktop => (const EdgeInsets.all(Dimensions.pageMarginDesktop), AppTextStyles.h1),
      LayoutType.tablet => (const EdgeInsets.fromLTRB(Dimensions.pageMarginDesktop, 28, Dimensions.pageMarginDesktop, 36), AppTextStyles.h1),
      LayoutType.mobile => (const EdgeInsets.all(Dimensions.pageMarginMobile), AppTextStyles.h1Mobile),
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: padding,
        children: [
          Semantics(header: true, child: Text(title, style: style.copyWith(color: scheme.onSurface))),
          if (subtitle != null) ...[
            const SizedBox(height: Dimensions.spaceXs),
            Text(subtitle!, style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
          ],
          ?child,
        ],
      ),
    );
  }
}
