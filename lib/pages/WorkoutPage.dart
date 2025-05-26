import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  List<Map<String, String>> exercises = [
    {'name': 'Leg Press', 'sets': '4x12'},
    {'name': 'Bench Press', 'sets': '4x12'},
    {'name': 'Pull down', 'sets': '3x12'},
    {'name': 'Shoulder Press', 'sets': '4x10'},
    {'name': 'Incline Press', 'sets': '4x10'},
    {'name': 'Face pull', 'sets': '4x10'},
    {'name': 'Push down', 'sets': '4x10'},
    {'name': 'Biceps curl', 'sets': '4x10'},
    {'name': 'Crunch', 'sets': '3x15'},
    {'name': 'Stretch', 'sets': '4x10'},
  ];

  void _addExercise() {
    final name = nameController.text.trim();
    final sets = setsController.text.trim();
    final reps = repsController.text.trim();

    if (name.isNotEmpty && sets.isNotEmpty && reps.isNotEmpty) {
      setState(() {
        exercises.add({'name': name, 'sets': '${sets}x$reps'});
        nameController.clear();
        setsController.clear();
        repsController.clear();
      });
    }
  }

  Widget _inputField(TextEditingController controller, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFFB4FF00),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 50, // control total height here
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.black, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kardeşler Fitness Special",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _inputField(nameController, "Name"),
                  const SizedBox(width: 10),
                  _inputField(setsController, "Sets"),
                  const SizedBox(width: 10),
                  _inputField(repsController, "Repeats"),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _addExercise,
                    child: Icon(Icons.add, color: Color(0xFFB4FF00), size: 30),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ReorderableListView.builder(
                  reverse: true, // key: items start accumulating at bottom
                  itemCount: exercises.length,
                  onReorder: (oldIndex, newIndex) {
                    // Since the list is reversed visually, swap indices accordingly:
                    int actualOldIndex = exercises.length - 1 - oldIndex;
                    int actualNewIndex = exercises.length - 1 - newIndex;

                    setState(() {
                      if (actualNewIndex > actualOldIndex) actualNewIndex -= 1;
                      final item = exercises.removeAt(actualOldIndex);
                      exercises.insert(actualNewIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    // Because list is reversed, map index to correct data:
                    final exercise = exercises[exercises.length - 1 - index];
                    return ListTile(
                      key: ValueKey(exercise['name']),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      leading: Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                      title: Text(
                        exercise['name']!,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      trailing: Text(
                        exercise['sets']!,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      onTap: () {
                        // remove with correct index in data list
                        setState(() {
                          exercises.removeAt(exercises.length - 1 - index);
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFFB4FF00)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
