import 'dart:async';

import 'package:fit_timer/entity/Exercise.dart';
import 'package:flutter/material.dart';

class WorkoutTimerPage extends StatefulWidget {
  final int? workoutId;
  const WorkoutTimerPage({super.key, this.workoutId});

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}


class _WorkoutTimerPageState extends State<WorkoutTimerPage> {
  final Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  Exercise? currentExercise;

  static String breakTimer = "00:00:00";
  static String setTimer = "00:00:00";
  bool isRunningBreak = false;
  bool isRunningSet = false;
  bool isBreak = false;

  final double smSizeFactor = 400/1080;
  final double lgSizeFactor = 700/1080;
  final double posYfactor = 1.3/1080;

  final double smFontFactor = 39/1080;
  final double mdFontFactor = 75/1080;

  static const Duration animDuration = Duration(milliseconds: 300);

  void start() {
    stopwatch.start();
    timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      setState(() {
        // Read stopwatch time and format it
        if(isBreak){
          breakTimer = format(stopwatch.elapsed);
        }else{
          setTimer = format(stopwatch.elapsed);
        }
      });
    });
  }

  void stop() {
    stopwatch.stop();
    timer?.cancel();
  }

  void reset() {
    stopwatch.reset();
    setState(() {
      if(isBreak){
        breakTimer = "00:00:00";
      }else{
        setTimer = "00:00:00";
      }
    });
  }

  String format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Widget _buildBreakCircle(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Align(
      key: const ValueKey('B'),
      alignment: Alignment(0, -screenWidth*posYfactor),
      child: GestureDetector(
        onTap: () => setState(() {
          if (isBreak) {
            isRunningBreak = !isRunningBreak;
            if (isRunningBreak) {
              start();
            } else {
              stop();
            }
          } else {
            isRunningSet = false;
            stop();
            reset();
            isBreak = true;
            isRunningBreak = true;
            stopwatch.reset();
            start();
          }
        }),
        child: AnimatedContainer(
          duration: animDuration,
          width: isBreak ? screenWidth*lgSizeFactor : screenWidth*smSizeFactor,
          height: isBreak ? screenWidth*lgSizeFactor : screenWidth*smSizeFactor,
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
                fontSize: isBreak ? screenWidth*mdFontFactor : screenWidth*smFontFactor,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("BREAK"),
                  Text(breakTimer)
                ],
              ),
            ),
          ),

        ),
      ),
    );
  }

  Widget _buildWorkCircle(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Align(
      key: const ValueKey('A'),
      alignment: Alignment(0, screenWidth*posYfactor),
      child: GestureDetector(
        onTap: () => setState(() {
          if (!isBreak) {
            isRunningSet = !isRunningSet;
            if (isRunningSet) {
              start();
            } else {
              stop();
            }
          } else {
            isRunningBreak = false;
            stop();
            reset();
            isBreak = false;
            isRunningSet = true;
            stopwatch.reset();
            start();
          }
        }),
        child: AnimatedContainer(
          duration: animDuration,
          width: isBreak ? screenWidth*smSizeFactor : screenWidth*lgSizeFactor,
          height: isBreak ? screenWidth*smSizeFactor : screenWidth*lgSizeFactor,
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
                fontSize: isBreak ? screenWidth*smFontFactor : screenWidth*mdFontFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("SET"),
                  Text(setTimer)
                ],
              ),
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
          Expanded(
              flex:1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Icon(Icons.play_arrow),
                  ),
                  Text("current exercise"),
                  GestureDetector(
                    child: Icon(Icons.play_arrow)
                  )
                ],
              ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: isBreak
                    ? [_buildWorkCircle(context), _buildBreakCircle(context)] // red (work) under, blue (break) on top
                    : [_buildBreakCircle(context), _buildWorkCircle(context)], // blue (break) under, red (work) on top
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
