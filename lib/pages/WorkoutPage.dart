import 'package:fit_timer/entity/Workout.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:fit_timer/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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

  Widget _inputField(TextEditingController controller, String label, {bool numbersOnly = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 50,
            child: TextField(
              controller: controller,
              keyboardType: numbersOnly ? TextInputType.number : TextInputType.text,
              inputFormatters: numbersOnly
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.greyCard,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Consumer<WorkoutProvider>(builder: (context, provider, child) {
            Workout? workout = provider.getWorkoutById(widget.id);
            List<Exercise> exercises = workout?.exercises ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      workout?.name ?? "Not Found",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                      ),
                      onPressed: () {
                        if (workout != null && workout.exercises.isNotEmpty) {
                          provider.selectWorkout(workout.id, null);
                          context.go('/timer');
                        }
                      },
                      child: const Text(
                        "Start Workout",
                        style: TextStyle(color: AppTheme.backgroundBlack, fontWeight: FontWeight.bold),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _inputField(nameController, "Name"),
                    const SizedBox(width: 10),
                    _inputField(setsController, "Sets", numbersOnly: true),
                    const SizedBox(width: 10),
                    _inputField(repsController, "Repeats", numbersOnly: true),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addExercise,
                      child: const Icon(Icons.add, color: AppTheme.neonGreen, size: 30),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      provider.reorderExercises(widget.id, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ListTile(
                        key: ValueKey(exercise.id),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        leading: GestureDetector(
                          onTap: () => _removeExercise(exercise.id),
                          child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        trailing: Text(
                          '${exercise.sets}x${exercise.reps}',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.neonGreen),
                    onPressed: () {
                      context.pop();
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
