import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  final String activeRoute;
  final bool isCompact;

  const AppSidebar({
    super.key,
    required this.activeRoute,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildMenuItem(IconData icon, String title, String path) {
      final isSelected = activeRoute == path;

      if (isCompact) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Tooltip(
            message: title,
            preferBelow: false,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (activeRoute != path) {
                    context.go(path);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? const Color(0xFF1976D2) : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey[700],
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey[900],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedTileColor: const Color(0xFFE3F2FD),
            hoverColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onTap: () {
              if (activeRoute != path) {
                context.go(path);
              }
            },
          ),
        ),
      );
    }

    return Container(
      width: isCompact ? 72 : 260,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: isCompact
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1976D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'PHF Money',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'Management',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Navigation Links
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  buildMenuItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
                  buildMenuItem(Icons.account_balance_wallet, 'Accounts', '/accounts'),
                  buildMenuItem(Icons.category, 'Categories', '/categories'),
                  buildMenuItem(Icons.payments, 'Transactions', '/transactions'),
                  buildMenuItem(Icons.track_changes_rounded, 'Budgets', '/budgets'),
                  buildMenuItem(Icons.bar_chart, 'Reports', '/reports'),
                  buildMenuItem(Icons.settings, 'Settings', '/settings'),
                ],
              ),
            ),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                isCompact ? 'v1.0' : 'v1.0.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
