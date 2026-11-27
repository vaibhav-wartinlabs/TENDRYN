import 'package:flutter/widgets.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';

/// Chooses a layout by screen type. A missing wider layout falls back to the
/// narrower one (desktop -> tablet -> mobile), so a screen can ship mobile-first.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.mobile, this.tablet, this.desktop});

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.desktop => desktop ?? tablet ?? mobile,
      LayoutType.tablet => tablet ?? mobile,
      LayoutType.mobile => mobile,
    };
  }
}
