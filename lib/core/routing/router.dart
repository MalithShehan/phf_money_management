import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

CustomTransitionPage<void> _customTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0.0), // subtle horizontal slide
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _customTransition(const SplashScreen(), state),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _customTransition(const DashboardScreen(), state),
    ),
    GoRoute(
      path: '/accounts',
      pageBuilder: (context, state) => _customTransition(const AccountsScreen(), state),
    ),
    GoRoute(
      path: '/categories',
      pageBuilder: (context, state) => _customTransition(const CategoriesScreen(), state),
    ),
    GoRoute(
      path: '/transactions',
      pageBuilder: (context, state) => _customTransition(const TransactionsScreen(), state),
    ),
    GoRoute(
      path: '/add-transaction',
      pageBuilder: (context, state) => _customTransition(const AddTransactionScreen(), state),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) => _customTransition(const ReportsScreen(), state),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _customTransition(const SettingsScreen(), state),
    ),
  ],
);
