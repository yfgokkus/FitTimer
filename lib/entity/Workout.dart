import 'package:fit_timer/entity/Exercise.dart';

class Workout {
  int id;
  String name;
  List<Exercise> exercises;
  DateTime dateCreated;

  Workout(this.id, this.name, this.exercises, this.dateCreated);

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      json['id'],
      json['name'],
      (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      DateTime.parse(json['dateCreated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'dateCreated': dateCreated.toIso8601String(),
    };
  }
}