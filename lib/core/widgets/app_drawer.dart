import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final activeRoute = GoRouterState.of(context).uri.path;

    Widget buildMenuItem(IconData icon, String title, String path) {
      final isSelected = activeRoute == path;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: () {
            Navigator.of(context).pop(); // close drawer
            context.go(path);
          },
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide.none),
                ),
                child: Column(
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
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PHF Money Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    buildMenuItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
                    buildMenuItem(Icons.account_balance_rounded, 'Accounts', '/accounts'),
                    buildMenuItem(Icons.category_rounded, 'Categories', '/categories'),
                    buildMenuItem(Icons.compare_arrows_rounded, 'Transactions', '/transactions'),
                    buildMenuItem(Icons.bar_chart_rounded, 'Reports', '/reports'),
                    buildMenuItem(Icons.settings_rounded, 'Settings', '/settings'),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
