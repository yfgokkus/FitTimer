import 'package:fit_timer/dataAccess/abstract/IWorkoutDao.dart';
import 'package:fit_timer/entity/Exercise.dart';
import 'package:fit_timer/entity/Workout.dart';
import 'package:fit_timer/state/abstract/WorkoutService.dart';
import 'package:flutter/cupertino.dart';

class WorkoutProvider with ChangeNotifier implements WorkoutService{
  final IWorkoutDao _dao;         // ← injected
  List<Workout> programs = [];

  WorkoutProvider({ required IWorkoutDao dao }) : _dao = dao {
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    programs = await _dao.getAllWorkout();
    notifyListeners();
  }

  @override
  Future<void> addExercise(int workoutId, Exercise exercise) {
    // TODO: implement addExercise
    throw UnimplementedError();
  }

  @override
  Future<List<Exercise>> getAllExercises(int workoutId) {
    // TODO: implement getAllExercises
    throw UnimplementedError();
  }

  @override
  Future<List<Workout>> getAllWorkout() {
    // TODO: implement getAllWorkout
    throw UnimplementedError();
  }

  @override
  Future<void> getExerciseById(int id) {
    // TODO: implement getExerciseById
    throw UnimplementedError();
  }

  @override
  Future<String?> getWorkoutById(int id) {
    // TODO: implement getWorkoutById
    throw UnimplementedError();
  }

  @override
  Future<void> removeExercise(int workoutId, int exerciseId) {
    // TODO: implement removeExercise
    throw UnimplementedError();
  }

  @override
  Future<void> reorderWorkout(int current, int next) {
    // TODO: implement reorderWorkout
    throw UnimplementedError();
  }

  @override
  Future<void> saveWorkout(Workout workout) {
    // TODO: implement saveWorkout
    throw UnimplementedError();
  }


}