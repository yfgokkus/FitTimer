import 'dart:convert';
import 'package:fit_timer/entity/Exercise.dart';
import 'package:fit_timer/entity/ProgramState.dart';
import 'package:fit_timer/entity/Workout.dart';
import 'package:fit_timer/state/abstract/WorkoutService.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class WorkoutProvider with ChangeNotifier implements WorkoutService {
  final SharedPreferences? _prefs;
  List<Workout> _workouts = [];

  bool hasStarted = false;
  ProgramState programState = ProgramState();
  int lastId = 0;
  WorkoutProvider._(this._prefs);

  static Future<WorkoutProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = WorkoutProvider._(prefs);
    await provider._loadPrefs(); // <- pre-load
    return provider;
  }

  Future<void> _loadPrefs() async {
    lastId = _prefs?.getInt('last_id') ?? 0;

    final workoutsJson = _prefs?.getString('workouts');
    if (workoutsJson == null) {
      _workouts = [];
    } else {
      final List decoded = jsonDecode(workoutsJson);
      _workouts = decoded.map((e) => Workout.fromJson(e)).toList();
    }

    final progStateJson = _prefs?.getString('program_state');
    if (progStateJson == null) {
      programState = ProgramState();
    } else {
      final decoded = jsonDecode(progStateJson);
      programState = ProgramState.fromJson(decoded);
    }
    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    final encWorkouts = jsonEncode(_workouts.map((w) => w.toJson()).toList());
    final encProgState = jsonEncode(programState);
    await _prefs?.setInt("last_id", lastId);
    await _prefs?.setString('workouts', encWorkouts);
    await _prefs?.setString('program_state', encProgState);
  }

  @override
  void addWorkout(String name, List<Exercise> exercises, DateTime dateCreated) {
    lastId++;
    final newWorkout = Workout(lastId, name, exercises, dateCreated);
    _workouts.add(newWorkout);
    notifyListeners();
  }

  @override
  void removeWorkout(int id) {
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  @override
  Workout? getWorkoutById(int id) =>
      _workouts.firstWhereOrNull((w) => w.id == id);

  @override
  List<Workout> getAllWorkouts() {
    return _workouts;
  }

  @override
  void addExercise(int workoutId, String name, int sets, int reps) {
    Workout? workout = getWorkoutById(workoutId);
    if (workout == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }
    lastId++;
    final newExercise = Exercise(lastId, name, sets, reps);
    workout.exercises.add(newExercise);
    notifyListeners();
  }

  @override
  Exercise? getExerciseById(int workoutId, int exerciseId) {
    Workout? workout = getWorkoutById(workoutId);
    if (workout == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    try {
      final exercise = workout.exercises.firstWhere((e) => e.id == exerciseId);

      return exercise;
    } catch (e) {
      return null;
    }
  }

  @override
  void removeExerciseById(int workoutId, int exerciseId) {
    Workout? workout = getWorkoutById(workoutId);
    if (workout == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    try {
      workout.exercises.removeWhere((exercise) => exercise.id == exerciseId);

      notifyListeners();
    } catch (e, stack) {
      debugPrint("Failed to remove exercise: $e\n$stack");
      rethrow;
    }
  }

  @override
  void reorderExercises(int workoutId, int current, int next) {
    Workout? workout = getWorkoutById(workoutId);
    if (workout == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    try {
      final exercises = workout.exercises;

      if (current < 0 ||
          current >= exercises.length ||
          next < 0 ||
          next >= exercises.length) {
        throw Exception("Invalid index for reordering exercises.");
      }

      final Exercise item = exercises.removeAt(current);
      exercises.insert(next, item);

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to reorder exercises: $e");
    }
  }

  @override
  void finishSet() {
    if(!programState.selected || programState.currentExercise == null) {
      return;
    }
    int exerciseId = programState.currentExercise!.id;
    programState.setsCompleted[exerciseId] = (programState.setsCompleted[exerciseId] ?? 0) + 1;
    notifyListeners();
  }

  @override
  void undoOneSet(){
    if(!programState.selected || programState.currentExercise == null) {
      return;
    }
    int exerciseId = programState.currentExercise!.id;
    final current = programState.setsCompleted[exerciseId] ?? 0;
    if(current > 0){
      programState.setsCompleted[exerciseId] = current - 1;
      notifyListeners();
    }
  }

  @override
  void selectWorkout(int workoutId, int? exerciseId) {
    if (programState.selected) return;

    Workout? workout = getWorkoutById(workoutId);
    if (workout == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    final exercise = exerciseId != null
        ? workout.exercises.firstWhere(
          (e) => e.id == exerciseId,
      orElse: () => throw Exception("Exercise with ID $exerciseId not found in workout."),
    )
        : workout.exercises.first;

    programState = ProgramState(true, workout, exercise);
    notifyListeners();
  }

  @override
  void leaveWorkout() {
    if (!programState.selected) {
      return;
    }
    programState = ProgramState();
    notifyListeners();
  }

  @override
  void nextExercise() {
    if (!programState.selected ||
        programState.currentProgram == null ||
        programState.currentExercise == null) {
      return;
    }

    List<Exercise> exercises = programState.currentProgram!.exercises;
    int currentIndex = exercises.indexWhere(
      (e) => e.id == programState.currentExercise!.id,
    );

    if (currentIndex + 1 < exercises.length) {
      programState.currentExercise = exercises[currentIndex + 1];
      notifyListeners();
    }
  }

  @override
  void prevExercise() {
    if (!programState.selected ||
        programState.currentProgram == null ||
        programState.currentExercise == null) {
      return;
    }
    List<Exercise> exercises = programState.currentProgram!.exercises;
    int currentIndex = exercises.indexWhere(
      (e) => e.id == programState.currentExercise!.id,
    );
    if (currentIndex > 0) {
      programState.currentExercise = exercises[currentIndex - 1];
      notifyListeners();
    }
  }
}
