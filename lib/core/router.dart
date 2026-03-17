import 'package:fit_timer/pages/HomePage.dart';
import 'package:fit_timer/pages/WorkoutListPage.dart';
import 'package:fit_timer/pages/WorkoutPage.dart';
import 'package:fit_timer/pages/WorkoutTimerPage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/timer',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return HomePage(child: child);
      },
      routes: [
        GoRoute(
          path: '/timer',
          builder: (context, state) => const WorkoutTimerPage(),
        ),
        GoRoute(
          path: '/programs',
          builder: (context, state) => const WorkoutListPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return WorkoutPage(id: id);
              },
            ),
          ]
        ),
      ],
    ),
  ],
);
