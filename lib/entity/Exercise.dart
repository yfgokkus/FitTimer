
class Exercise {
  int id;
  String name;
  int sets;
  int reps;

  Exercise(this.id, this.name, this.sets, this.reps);

  // Convert Exercise to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets,
    'reps': reps,
  };

  // Convert JSON to Exercise
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    json['id'],
    json['name'],
    json['sets'],
    json['reps'],
  );
}