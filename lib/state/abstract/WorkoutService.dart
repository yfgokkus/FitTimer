import '../../entity/Exercise.dart';
import '../../entity/Workout.dart';

abstract class WorkoutService {
  Workout? getWorkoutById(int workoutId);
  void addWorkout(String name, List<Exercise> exercises, DateTime dateCreated);
  void removeWorkout(int id);
  List<Workout> getAllWorkouts();
  Exercise? getExerciseById(int workoutId, int exerciseId);
  void addExercise(int workoutId, String name, int sets, int reps);
  void removeExercise(int workoutId, int exerciseId);
  void reorderExercises(int workoutId, int current, int next);
  void startWorkout(int workoutId);
  void stopWorkout();
}