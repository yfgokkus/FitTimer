import 'package:fit_timer/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final Widget child;
  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/programs')) {
      return 1;
    }
    return 0; // default to timer
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 0) {
      context.go('/timer');
    } else {
      context.go('/programs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.greyCard,
        selectedItemColor: AppTheme.neonGreen,
        unselectedItemColor: Colors.white70,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Programs',
          ),
        ],
      ),
    );
  }
}
