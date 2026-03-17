import 'dart:async';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:flutter/cupertino.dart';

class TimerProvider with ChangeNotifier {
  final WorkoutProvider workoutProvider;

  TimerProvider({required this.workoutProvider});

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  bool isBreak = false;
  bool isRunningBreak = false;
  bool isRunningSet = false;
  bool isPaused = false;   // ← global pause flag
  int _setsCompleted = 0; // fallback if no program is selected

  String _breakTimer = '00:00:00';
  String _setTimer = '00:00:00';

  String get breakTimer => _breakTimer;
  String get setTimer => _setTimer;
  int get setsCompleted => _setsCompleted;

  /// True when either the set or break timer is actively running.
  bool get isActive => isRunningSet || isRunningBreak;

  void _tick(Timer timer) {
    if (isBreak) {
      _breakTimer = _format(_stopwatch.elapsed);
    } else {
      _setTimer = _format(_stopwatch.elapsed);
    }
    notifyListeners();
  }

  void startTiming() {
    _stopwatch.start();
    _timer ??= Timer.periodic(const Duration(milliseconds: 100), _tick);
  }

  void stopTiming() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resetTiming() {
    _stopwatch.reset();
    if (isBreak) {
      _breakTimer = '00:00:00';
    } else {
      _setTimer = '00:00:00';
    }
    notifyListeners();
  }

  /// Freeze / unfreeze whichever timer is currently active.
  void togglePause() {
    if (!isActive) return; // nothing running — nothing to pause
    isPaused = !isPaused;
    if (isPaused) {
      _stopwatch.stop();
      _timer?.cancel();
      _timer = null;
    } else {
      startTiming();
    }
    notifyListeners();
  }

  void toggleBreak() {
    isPaused = false; // switching mode clears pause
    if (isBreak) {
      isRunningBreak = !isRunningBreak;
      if (isRunningBreak) {
        startTiming();
      } else {
        stopTiming();
      }
    } else {
      workoutProvider.finishSet();
      isRunningSet = false;
      stopTiming();
      resetTiming();
      isBreak = true;
      isRunningBreak = true;
      _stopwatch.reset();
      startTiming();
    }
    notifyListeners();
  }

  void toggleWork() {
    isPaused = false; // switching mode clears pause
    if (!isBreak) {
      isRunningSet = !isRunningSet;
      if (isRunningSet) {
        startTiming();
      } else {
        stopTiming();
      }
    } else {
      isRunningBreak = false;
      stopTiming();
      resetTiming();
      isBreak = false;
      isRunningSet = true;
      _stopwatch.reset();
      startTiming();
    }
    notifyListeners();
  }

  void manualAddSet() {
    if (workoutProvider.programState.selected) {
      workoutProvider.finishSet();
    } else {
      _setsCompleted++;
    }
    notifyListeners();
  }

  void manualRemoveSet() {
    if (workoutProvider.programState.selected) {
      workoutProvider.undoOneSet();
    } else {
      if (_setsCompleted > 0) _setsCompleted--;
    }
    notifyListeners();
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
