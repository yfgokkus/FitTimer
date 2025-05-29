import 'package:fit_timer/entity/Workout.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/Exercise.dart';

class WorkoutPage extends StatefulWidget {
  final int id;
  const WorkoutPage({super.key, required this.id});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();


  void _addExercise() {
    final String name = nameController.text.trim();
    final int sets = int.tryParse(setsController.text.trim()) ?? -1;
    final int reps = int.tryParse(repsController.text.trim()) ?? -1;

    if (name.isNotEmpty && sets>0 && reps>0) {
      Provider.of<WorkoutProvider>(context, listen: false)
          .addExercise(widget.id, name, sets, reps);
      setState(() {
        nameController.clear();
        setsController.clear();
        repsController.clear();
        FocusScope.of(context).unfocus();
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

  void _removeExercise(int exerciseId) {
    Provider.of<WorkoutProvider>(context, listen: false)
        .removeExerciseById(widget.id, exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Consumer<WorkoutProvider>(builder: (context, provider, child) {
            Workout? workout = provider.getWorkoutById(widget.id);
            List<Exercise> exercises = workout?.exercises ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout?.name ?? "bulunamadı",
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
                      if (actualNewIndex > actualOldIndex) actualNewIndex -= 1;

                      provider.reorderExercises(widget.id, actualOldIndex, actualNewIndex);
                    },
                    itemBuilder: (context, index) {
                      // Because list is reversed, map index to correct data:
                      final exercise = exercises[exercises.length - 1 - index];
                      return ListTile(
                        key: ValueKey(exercise.id),
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        leading: GestureDetector(
                          onTap: () => _removeExercise(exercise.id),
                          child: Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                        ),
                        title: Text(
                          exercise.name,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        trailing: Text(
                          '${exercise.sets}x${exercise.reps}',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
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
                ),
              ],
            );
          })
        ),
      ),
    );
  }
}
