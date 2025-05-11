import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WorkoutTimerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}


class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  bool isBreak = true;
  bool isRunning = false;

  final double smallSize = 135;
  final double largeSize = 220;
  final double shiftAmount = 20;
  final double smFont = 10;
  final double mdFont = 16;
  static const Duration animDuration = Duration(milliseconds: 300);

  void toggleTimer() {
    setState(() {
      isBreak = !isBreak;
    });
  }

  Widget _buildBreakCircle() {
    return Align(
      key: const ValueKey('B'),
      alignment: const Alignment(0, -0.45),
      child: GestureDetector(
        onTap: () => setState(() => isBreak = true),
        child: AnimatedContainer(
          duration: animDuration,
          width: isBreak ? largeSize : smallSize,
          height: isBreak ? largeSize : smallSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isBreak ? const Color(0xBF000000) : const Color(0xFF000000),
            boxShadow: [
              if (isBreak)
                const BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: animDuration,
              style: TextStyle(
                fontSize: isBreak ? mdFont : smFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              child: const Text("00:00:00:00"),
            ),
          ),

        ),
      ),
    );
  }

  Widget _buildWorkCircle() {
    return Align(
      key: const ValueKey('A'),
      alignment: const Alignment(0, 0.45),
      child: GestureDetector(
        onTap: () => setState(() => isBreak = false),
        child: AnimatedContainer(
          duration: animDuration,
          width: isBreak ? smallSize : largeSize,
          height: isBreak ? smallSize : largeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isBreak ? const Color(0xFFC1FF72) : const Color(0xE6C1FF72),
            boxShadow: [
              if (!isBreak)
                const BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: animDuration,
              style: TextStyle(
                fontSize: isBreak ? smFont : mdFont,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              child: const Text("00:00:00:00"),
            ),
          ),

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              const Expanded(
                  flex:1,
                  child: Row()
              ),
              Expanded(
                flex: 5,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: isBreak
                        ? [_buildWorkCircle(), _buildBreakCircle()] // red (work) under, blue (break) on top
                        : [_buildBreakCircle(), _buildWorkCircle()], // blue (break) under, red (work) on top
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Row(),
              ),
              const Expanded(
                flex: 1,
                child: Row(),
              ),
            ],
            ),
        );
    }
}
