//import 'package:fit_timer/pages/HomePage.dart';
import 'package:fit_timer/pages/ProgramListPage.dart';
//import 'package:fit_timer/pages/WorkoutTimerPage.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final workoutProvider = await WorkoutProvider.create();

  runApp(
    ChangeNotifierProvider<WorkoutProvider>.value(
      value: workoutProvider,
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProgramListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


