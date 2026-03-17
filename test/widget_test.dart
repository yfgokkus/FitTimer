import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_timer/main.dart';
import 'package:provider/provider.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:fit_timer/state/concrete/TimerProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final workoutProvider = await WorkoutProvider.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkoutProvider>.value(
            value: workoutProvider,
          ),
          ChangeNotifierProvider<TimerProvider>(
            create: (_) => TimerProvider(workoutProvider: workoutProvider),
          ),
        ],
        child: const MyApp(),
      ),
    );
    
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
