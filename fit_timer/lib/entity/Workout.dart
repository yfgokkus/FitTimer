import 'package:fit_timer/entity/Exercise.dart';

class Workout{

  int id;
  String name;
  List<Exercise> exercises;
  DateTime dateCreated;

  Workout(this.id, this.name, this.exercises, this.dateCreated);
}