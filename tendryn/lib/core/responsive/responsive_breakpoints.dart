/// Responsive thresholds in logical pixels. Native mobile platforms use the
/// shortest side so device layout stays consistent when orientation changes;
/// desktop platforms use window width.
///   mobile : dimension < mobile
///   tablet : mobile <= dimension < tablet
///   desktop: dimension >= tablet
abstract class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
}
