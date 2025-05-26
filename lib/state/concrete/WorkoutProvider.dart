import 'dart:convert';
import 'package:fit_timer/entity/Exercise.dart';
import 'package:fit_timer/entity/Workout.dart';
import 'package:fit_timer/state/abstract/WorkoutService.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutProvider with ChangeNotifier implements WorkoutService{

  final SharedPreferences? _prefs;

  WorkoutProvider._(this._prefs);

  static Future<WorkoutProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutProvider._(prefs);
  }

  @override
  Future<void> createWorkout(int id, String name, List<Exercise> exercises, DateTime dateCreated) async {
    final newWorkout = Workout(id, name, exercises, dateCreated);
    final String? workoutsString = _prefs?.getString('workouts');
    List<Map<String, dynamic>> workoutsList = [];

    if (workoutsString != null) {
      final decoded = jsonDecode(workoutsString);
      if (decoded is List) {
        workoutsList = List<Map<String, dynamic>>.from(decoded);
      }
    }
    workoutsList.add(newWorkout.toJson());

    await _prefs?.setString('workouts', jsonEncode(workoutsList));

    notifyListeners();
  }

  @override
  Future<Workout> getWorkoutById(int workoutId) async {
    final workoutsJson = _prefs?.getString('workouts');

    if (workoutsJson == null) {
      throw Exception("No workouts found.");
    }

    try {
      final List decoded = jsonDecode(workoutsJson);
      final workouts = decoded.map((e) => Workout.fromJson(e)).toList();

      final workout = workouts.firstWhere(
            (w) => w.id == workoutId,
        orElse: () => throw Exception("Workout with ID $workoutId not found."),
      );

      return workout;
    } catch (e) {
      throw Exception("Failed to get workout by ID: $e");
    }
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final String? workoutsJson = _prefs?.getString('workouts');
    if (workoutsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(workoutsJson);
      return decoded.map((e) => Workout.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Failed to decode workouts: $e");
      return [];
    }
  }

  @override
  Future<void> addExercise(int workoutId, String name, int sets, int reps) async {
    final workoutsJson = _prefs?.getString('workouts');

    if (workoutsJson == null) {
      throw Exception("No workouts found.");
    }

    final List decoded = jsonDecode(workoutsJson);
    final List<Workout> workouts = decoded.map((e) => Workout.fromJson(e)).toList();

    final workoutIndex = workouts.indexWhere((w) => w.id == workoutId);
    if (workoutIndex == -1) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    final allExercises = workouts.expand((w) => w.exercises).toList();
    final highestId = allExercises.map((e) => e.id).fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
    final uniqueId = highestId + 1;

    final newExercise = Exercise(uniqueId, name, sets, reps);

    workouts[workoutIndex].exercises.add(newExercise);

    await _prefs?.setString('workouts', jsonEncode(workouts.map((w) => w.toJson()).toList()));

    notifyListeners();
  }

  @override
  Future<Exercise> getExerciseById(int workoutId, int exerciseId) async {
    final workoutsJson = _prefs?.getString('workouts');

    if (workoutsJson == null) {
      throw Exception("No workouts found in storage.");
    }

    try {
      final List decoded = jsonDecode(workoutsJson);
      final workouts = decoded.map((e) => Workout.fromJson(e)).toList();

      final workout = workouts.firstWhere(
            (w) => w.id == workoutId,
        orElse: () => throw Exception("Workout with ID $workoutId not found."),
      );

      final exercise = workout.exercises.firstWhere(
            (e) => e.id == exerciseId,
        orElse: () => throw Exception("Exercise with ID $exerciseId not found in workout $workoutId."),
      );

      return exercise;
    } catch (e) {
      throw Exception("Error getting exercise: $e");
    }
  }

  @override
  Future<void> removeExercise(int workoutId, int exerciseId) async {
    final workoutsJson = _prefs?.getString('workouts');

    if (workoutsJson == null) {
      throw Exception("No workouts found.");
    }

    try {
      final List decoded = jsonDecode(workoutsJson);
      final List<Workout> workouts = decoded.map((e) => Workout.fromJson(e)).toList();

      final workoutIndex = workouts.indexWhere((w) => w.id == workoutId);
      if (workoutIndex == -1) {
        throw Exception("Workout with ID $workoutId not found.");
      }

      workouts[workoutIndex].exercises
          .removeWhere((exercise) => exercise.id == exerciseId);

      final updatedJson = jsonEncode(workouts.map((w) => w.toJson()).toList());
      await _prefs?.setString('workouts', updatedJson);

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to remove exercise: $e");
    }
  }


  @override
  Future<void> reorderExercises(int workoutId, int current, int next) async {
    final workoutsJson = _prefs?.getString('workouts');

    if (workoutsJson == null) {
      throw Exception("No workouts found.");
    }

    try {
      final List decoded = jsonDecode(workoutsJson);
      final List<Workout> workouts = decoded.map((e) => Workout.fromJson(e)).toList();

      final workoutIndex = workouts.indexWhere((w) => w.id == workoutId);
      if (workoutIndex == -1) {
        throw Exception("Workout with ID $workoutId not found.");
      }

      final exercises = workouts[workoutIndex].exercises;

      if (current < 0 || current >= exercises.length || next < 0 || next >= exercises.length) {
        throw Exception("Invalid index for reordering exercises.");
      }

      final Exercise item = exercises.removeAt(current);
      exercises.insert(next, item);

      final updatedJson = jsonEncode(workouts.map((w) => w.toJson()).toList());
      await _prefs?.setString('workouts', updatedJson);

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to reorder exercises: $e");
    }
  }


  @override
  Future<void> startWorkout(int workoutId) async {
    await _prefs?.setInt('current_workout_id', workoutId);
    await _prefs?.setBool('has_started', true);
    notifyListeners();
  }

  @override
  Future<void> stopWorkout() async {
    await _prefs?.remove('current_workout_id');
    await _prefs?.setBool('has_started', false);
    notifyListeners();
  }
}