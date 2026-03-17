import 'Workout.dart';
import 'Exercise.dart';

class ProgramState {
  bool selected;
  Workout? currentProgram;
  Exercise? currentExercise;
  Map<int, int> setsCompleted; // key = exercise ID, value = sets done

  ProgramState([
    this.selected = false,
    this.currentProgram,
    this.currentExercise,
    Map<int, int>? setsCompleted,
  ]) : setsCompleted = setsCompleted ??
      (currentProgram != null
          ? {for (var e in currentProgram.exercises) e.id: 0}
          : {});


  Map<String, dynamic> toJson() => {
    'selected': selected,
    'currentProgram': currentProgram?.toJson(),
    'currentExercise': currentExercise?.toJson(),
    'setsCompleted': setsCompleted.map((k, v) => MapEntry(k.toString(), v)), // Convert int keys to String for JSON
  };

  factory ProgramState.fromJson(Map<String, dynamic> json) => ProgramState(
    json['selected'] ?? false,
    json['currentProgram'] != null ? Workout.fromJson(json['currentProgram']) : null,
    json['currentExercise'] != null ? Exercise.fromJson(json['currentExercise']) : null,
    (json['setsCompleted'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(int.parse(k), v)),
  );
}
