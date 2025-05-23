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
  Future<void> addExercise(int workoutId, Exercise exercise) async {
    final workoutString = _prefs?.getString(workoutId.toString());
    if (workoutString == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }
    final workoutMap = jsonDecode(workoutString);
    final workout = Workout.fromJson(workoutMap);

    workout.exercises.add(exercise);

    final updatedWorkoutString = jsonEncode(workout.toJson());
    await _prefs?.setString(workoutId.toString(), updatedWorkoutString);

    notifyListeners();
  }

  @override
  Future<List<Exercise>> getAllExercises(int workoutId) async {
    final workoutString = _prefs?.getString(workoutId.toString());
    if (workoutString == null) {
      return [];
    }
    final workoutMap = jsonDecode(workoutString);
    final workout = Workout.fromJson(workoutMap);
    return workout.exercises;
  }

  @override
  Future<void> createWorkout(int id, String name, List<Exercise> exercises, DateTime dateCreated) async {
    final workout = Workout(id, name, exercises, dateCreated);
    final workoutJson = jsonEncode(workout.toJson());

    if (_prefs?.getString(id.toString()) == null) {
      await _prefs?.setString(id.toString(), workoutJson);
    }

    final ids = _prefs?.getStringList('workout_ids') ?? [];
    if (!ids.contains(id.toString())) {
      ids.add(id.toString());
      await _prefs?.setStringList('workout_ids', ids);
    }

    notifyListeners();
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final ids = _prefs?.getStringList('workout_ids') ?? [];
    List<Workout> workouts = [];

    for (final id in ids) {
      final jsonWorkout = _prefs?.getString(id);
      if (jsonWorkout != null) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(jsonWorkout);
          final workout = Workout.fromJson(jsonData);
          workouts.add(workout);
        } catch (e) {
          debugPrint("Skipping workout with id $id due to parse error: $e");
        }
      } else {
        debugPrint("Workout id $id is in id list but no workout found.");
      }
    }
    return workouts;
  }

  @override
  Future<Exercise> getExerciseById(int workoutId, int exerciseId) async {
    final workoutString = _prefs?.getString(workoutId.toString());

    if (workoutString == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    final Map<String, dynamic> workoutMap = jsonDecode(workoutString);
    final Workout workout = Workout.fromJson(workoutMap);

    try {
      final Exercise exercise = workout.exercises.firstWhere(
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
    final workoutString = _prefs?.getString(workoutId.toString());

    if (workoutString == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    final Map<String, dynamic> workoutMap = jsonDecode(workoutString);
    final Workout workout = Workout.fromJson(workoutMap);

    workout.exercises.removeWhere((exercise) => exercise.id == exerciseId);

    final updatedWorkoutString = jsonEncode(workout.toJson());
    await _prefs?.setString(workoutId.toString(), updatedWorkoutString);

    notifyListeners();
  }


  @override
  Future<void> reorderWorkout(int workoutId, int current, int next) async {
    final workoutString = _prefs?.getString(workoutId.toString());

    if (workoutString == null) {
      throw Exception("Workout with ID $workoutId not found.");
    }

    final Map<String, dynamic> workoutMap = jsonDecode(workoutString);
    final Workout workout = Workout.fromJson(workoutMap);

    final List<Exercise> exercises = workout.exercises;

    if (current < 0 || current >= exercises.length || next < 0 || next >= exercises.length) {
      throw Exception("Invalid current or next index.");
    }

    final Exercise item = exercises.removeAt(current);
    exercises.insert(next, item);

    final updatedWorkoutString = jsonEncode(workout.toJson());
    await _prefs?.setString(workoutId.toString(), updatedWorkoutString);

    notifyListeners();
  }

  @override
  Future<void> startWorkout(int workoutId) {
    // TODO: implement startWorkout
    throw UnimplementedError();
  }
}