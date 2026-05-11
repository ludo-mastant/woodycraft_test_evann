import 'package:flutter/material.dart';

import '../composants/app_colors.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'puzzle_list_page.dart';
import 'stocks_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  // Crée l'état de navigation.
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    PuzzleListPage(),
    AdminOrdersPage(),
    StocksPage(),
  ];

  // Affiche le menu du bas.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension),
            label: 'Puzzles',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stocks',
          ),
        ],
      ),
    );
  }
}
