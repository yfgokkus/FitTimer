import 'package:fit_timer/entity/Workout.dart';

import '../../entity/Exercise.dart';

abstract class IWorkoutDao {
  Future<List<Workout>> getAllWorkout();
  Future<String?> getWorkoutById(int id);
  Future<void> saveWorkout(Workout workout);
  Future<List<Exercise>> getAllExercises(int workoutId);
  Future<void> getExerciseById(int id);
  Future<void> addExercise(int workoutId, Exercise exercise);
  Future<void> removeExercise(int workoutId, int exerciseId);
  Future<void> reorderWorkout(int current, int next);
}