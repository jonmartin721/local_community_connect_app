import 'package:flutter/widgets.dart';

/// Responsive breakpoint constants for consistent layout behavior.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Width threshold for wide layouts (tablet/small desktop).
  static const double wide = 800;

  /// Width threshold for extra-wide layouts (large desktop).
  static const double extraWide = 1200;
}

/// Extension on BuildContext for responsive layout queries.
extension ResponsiveContext on BuildContext {
  /// Current screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns true if screen width exceeds the wide breakpoint (800px).
  bool get isWide => screenWidth > ResponsiveBreakpoints.wide;

  /// Returns true if screen width exceeds the extra-wide breakpoint (1200px).
  bool get isExtraWide => screenWidth > ResponsiveBreakpoints.extraWide;

  /// Returns the appropriate grid column count based on screen width.
  int get gridColumnCount {
    if (isExtraWide) return 3;
    if (isWide) return 2;
    return 1;
  }
}
