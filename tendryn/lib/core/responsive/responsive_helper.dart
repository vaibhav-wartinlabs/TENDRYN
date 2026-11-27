import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tendryn/core/responsive/responsive_breakpoints.dart';

enum LayoutType { mobile, tablet, desktop }

/// Centralizes device layout selection. Native mobile platforms use the
/// shortest side, so rotating a phone or tablet does not switch layout class.
/// Desktop platforms use window width so resized windows still adapt.
abstract class ResponsiveHelper {
  static LayoutType fromWidth(double width) {
    if (width >= ResponsiveBreakpoints.tablet) return LayoutType.desktop;
    if (width >= ResponsiveBreakpoints.mobile) return LayoutType.tablet;
    return LayoutType.mobile;
  }

  static LayoutType screenType(BuildContext context) {
    final size = MediaQuery.maybeSizeOf(context);
    if (size != null) {
      return fromWidth(isDesktopPlatform ? size.width : size.shortestSide);
    }
    try {
      final view = View.maybeOf(context);
      if (view != null) {
        final logicalSize = view.physicalSize / view.devicePixelRatio;
        return fromWidth(isDesktopPlatform ? logicalSize.width : logicalSize.shortestSide);
      }
    } catch (_) {}
    return LayoutType.desktop;
  }

  /// Optional test override so testWidgets does not have to mutate
  /// Flutter's foundation `debugDefaultTargetPlatformOverride` variable.
  static bool? debugIsDesktopPlatformOverride;

  /// Windows, macOS and Linux (not Android/iOS, whatever their screen size).
  static bool get isDesktopPlatform =>
      debugIsDesktopPlatformOverride ??
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Side drawers over the current page: a desktop OS with a desktop-width
  /// window. Phones and Android tablets, even at >= 1200px, keep full pages.
  static bool usesDrawer(BuildContext context) =>
      isDesktopPlatform && isDesktop(context);

  static bool isMobile(BuildContext context) => screenType(context) == LayoutType.mobile;
  static bool isTablet(BuildContext context) => screenType(context) == LayoutType.tablet;
  static bool isDesktop(BuildContext context) => screenType(context) == LayoutType.desktop;

  /// True for tablet-sized native screens currently in landscape. Use the
  /// available constraints for the actual layout; this is for orientation-
  /// specific treatment such as expanding a tablet action bar.
  static bool isTabletLandscape(BuildContext context) {
    if (!isTablet(context)) return false;
    final size = MediaQuery.maybeSizeOf(context);
    return size != null && size.width > size.height;
  }
}
