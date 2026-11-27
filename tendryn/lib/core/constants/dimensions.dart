/// Spacing, radius, stroke and size tokens from the Tendryn design system
/// ("Tendryn DS / 01"). Figma variable names are noted where one exists.
abstract class Dimensions {
  // Spacing scale (general layout)
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // Semantic spacing
  static const double componentGap = 8; // --space-component-gap
  static const double cardInner = 24; // --space-card-inner
  static const double controlX = 16; // --space-control-x
  static const double controlY = 12; // --space-control-y
  static const double statusX = 12; // --space-status-x
  static const double statusY = 6; // --space-status-y
  static const double pageMarginMobile = 16; // mobile side margins
  static const double pageMarginTablet = 24; // tablet margins and gutters
  static const double pageMarginDesktop = 24; // desktop margins and gutters
  static const double pageSectionGap = 24; // spacing between page sections
  static const double sectionContentGap = 16; // heading / section to its content

  // Radius
  static const double radius = 12; // --radius-card
  static const double radiusControl = 8; // --radius-control
  static const double radiusPill = 9999; // --radius-pill

  // Strokes
  static const double strokeDivider = 1; // --stroke-divider (dividers, input and card borders)
  static const double strokeFocus = 2; // --stroke-focus
  static const double strokeIcon = 1.5; // --stroke-icon (Lucide icons)

  // Component sizes
  static const double buttonMinHeight = 48; // --size-button-min-height
  static const double touchTarget = 48; // --size-mobile-touch-target
  static const double bottomNavHeight = 64; // --size-mobile-bottom-nav
  static const double topBarHeight = 64; // --size-top-bar
  static const double sideNavWidth = 248; // --size-desktop-sidebar
  static const double sideNavItemWidth = 216;
  static const double bottomNavItemWidth = 72;
  static const double iconSize = 18;
  static const double chipHeight = 32;
  static const double stateDot = 8;

  // Dashboard layout (from the Dashboard frames)
  static const double sectionPadding = 24; // card header / quick-action card padding
  static const double tableHeaderHeight = 44;
  static const double tableColumnGap = spaceSm;
  static const double tableRowVerticalPadding = 12;
  static const double tableRowMinHeight = 68;
  static const double queueRowMinHeight = tableRowMinHeight;
  static const double appointmentRowMinHeight = tableRowMinHeight;
  static const double actionIconBox = 36;
  static const double attentionIconBox = 40;
  static const double tabletHeaderHeight = 88;
  static const double tabletBottomNavHeight = 76;
  static const double mobileHeaderHeight = 64;
  static const double badgePaddingX = 10;
  static const double badgePaddingY = 4;
  static const double dashboardTableMinWidth = 984;

  // Content widths used by this app's screens
  static const double maxContentWidth = 1200;
  static const double formMaxWidth = 420;

  // Desktop sliding drawers / panels
  static const double drawerWidth = 460;
}
