import 'package:fit_timer/core/router.dart';
import 'package:fit_timer/core/theme.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:fit_timer/state/concrete/TimerProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final workoutProvider = await WorkoutProvider.create();

  runApp(
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
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late WorkoutProvider _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _provider = Provider.of<WorkoutProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _provider.saveToPrefs(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitTimer',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
