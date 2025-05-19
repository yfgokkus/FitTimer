import 'package:fit_timer/dataAccess/abstract/IWorkoutDao.dart';
import 'package:fit_timer/entity/Workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entity/Exercise.dart';

class WorkoutDao implements IWorkoutDao{
  SharedPreferences? _prefs;
  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  static const _keyWorkouts = 'programs';


  @override
  Future<List<Workout>> getAllWorkout() {
    // TODO: implement reorderWorkout
    throw UnimplementedError();
  }

  @override
  Future<String?> getWorkoutById(int id) async {
    return _prefs?.getString(_keyWorkouts);
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    _prefs?.getString(_keyWorkouts);
  }

  @override
  Future<List<Exercise>> getAllExercises(int workoutId) {
    // TODO: implement getAllExercises
    throw UnimplementedError();
  }

  @override
  Future<void> getExerciseById(int id) async {
    final prefs = await _instance;
    await prefs.remove(_keyWorkouts);
  }

  @override
  Future<void> addExercise(int workoutId, Exercise exercise) {
    // TODO: implement reorderWorkout
    throw UnimplementedError();
  }

  @override
  Future<void> removeExercise(int workoutId, int exerciseId) {
    // TODO: implement reorderWorkout
    throw UnimplementedError();
  }

  @override
  Future<void> reorderWorkout(int current, int next) {
    // TODO: implement reorderWorkout
    throw UnimplementedError();
  }





  
}
