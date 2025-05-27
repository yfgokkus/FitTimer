import 'package:fit_timer/pages/WorkoutPage.dart';
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
    _provider = _provider = Provider.of<WorkoutProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Save to prefs when app is backgrounded or closed
      _provider.saveToPrefs(); // Your custom method
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WorkoutPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}



