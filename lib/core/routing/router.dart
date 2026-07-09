import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/presentation/pages/transaction_form_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

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
      pageBuilder: (context, state) => _customTransition(const SplashPage(), state),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _customTransition(const DashboardPage(), state),
    ),
    GoRoute(
      path: '/accounts',
      pageBuilder: (context, state) => _customTransition(const AccountsPage(), state),
    ),
    GoRoute(
      path: '/categories',
      pageBuilder: (context, state) => _customTransition(const CategoriesPage(), state),
    ),
    GoRoute(
      path: '/transactions',
      pageBuilder: (context, state) => _customTransition(const TransactionsPage(), state),
    ),
    GoRoute(
      path: '/add-transaction',
      pageBuilder: (context, state) => _customTransition(const TransactionFormPage(), state),
    ),
    GoRoute(
      path: '/edit-transaction/:id',
      pageBuilder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = idStr != null ? int.tryParse(idStr) : null;
        return _customTransition(TransactionFormPage(editTransactionId: id), state);
      },
    ),
    GoRoute(
      path: '/budgets',
      pageBuilder: (context, state) => _customTransition(const BudgetsPage(), state),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) => _customTransition(const ReportsPage(), state),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _customTransition(const SettingsPage(), state),
    ),
  ],
);
