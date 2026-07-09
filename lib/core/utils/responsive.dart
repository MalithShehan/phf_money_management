import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 700.0;
  static const double tabletBreakpoint = 1100.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool showSidebar(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;
}
