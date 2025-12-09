import 'package:flutter/material.dart';

abstract class AppSpacing {
  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Border radius scale
  static const double radiusXl = 20;
  static const double radiusLg = 16;
  static const double radiusMd = 14;
  static const double radiusSm = 12;
  static const double radiusXs = 10;
  static const double radiusTiny = 8;

  // Common edge insets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXxxl = EdgeInsets.all(xxxl);

  // Border radius helpers
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusTiny => BorderRadius.circular(radiusTiny);

  // Vertical spacing helpers
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  // Horizontal spacing helpers
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);
  static const SizedBox horizontalXxxl = SizedBox(width: xxxl);
}
