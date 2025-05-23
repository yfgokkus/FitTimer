import '../../entity/Exercise.dart';
import '../../entity/Workout.dart';

abstract class WorkoutService {
  Future<void> createWorkout(int id, String name, List<Exercise> exercises, DateTime dateCreated);
  Future<List<Workout>> getAllWorkouts();
  Future<List<Exercise>>? getAllExercises(int workoutId);
  Future<Exercise> getExerciseById(int workoutId, int exerciseId);
  Future<void> addExercise(int workoutId, Exercise exercise);
  Future<void> removeExercise(int workoutId, int exerciseId);
  Future<void> reorderWorkout(int workoutId, int current, int next);
  Future<void> startWorkout(int workoutId);
}