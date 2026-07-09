import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive.dart';
import 'app_sidebar.dart';

class ResponsiveLayoutShell extends StatelessWidget {
  final Widget child;

  const ResponsiveLayoutShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final activeRoute = GoRouterState.of(context).uri.path;

    if (Responsive.isMobile(context)) {
      return child;
    }

    final isCompact = Responsive.isTablet(context);

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            activeRoute: activeRoute,
            isCompact: isCompact,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
