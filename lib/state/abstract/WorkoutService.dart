import '../../entity/Exercise.dart';
import '../../entity/Workout.dart';

abstract class WorkoutService {
  Future<Workout> getWorkoutById(int workoutId);
  Future<void> createWorkout(int id, String name, List<Exercise> exercises, DateTime dateCreated);
  Future<List<Workout>> getAllWorkouts();
  Future<Exercise> getExerciseById(int workoutId, int exerciseId);
  Future<void> addExercise(int workoutId, String name, int sets, int reps);
  Future<void> removeExercise(int workoutId, int exerciseId);
  Future<void> reorderExercises(int workoutId, int current, int next);
  Future<void> startWorkout(int workoutId);
  Future<void> stopWorkout();
}