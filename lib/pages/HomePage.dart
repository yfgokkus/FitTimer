import 'package:fit_timer/pages/WorkoutListPage.dart';
import 'package:fit_timer/pages/WorkoutTimerPage.dart';
import 'package:fit_timer/widgets/ClickAnimatedTextButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/concrete/WorkoutProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClickAnimatedTextButton(
            text: "Programs",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutListPage()));
            },
          ),
          const SizedBox(height: 20),

          Consumer<WorkoutProvider>(
            builder: (context, provider, child) {
              final id = provider.currentProgramId;
              final workout = provider.getWorkoutById(id);

              if (id == -1 || workout == null) {
                return const SizedBox.shrink();
              }

              return ClickAnimatedTextButton(
                text: "Continue: ${workout.name}",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutTimerPage()));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}




