import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class WorkoutListPage extends StatefulWidget {
  const WorkoutListPage({super.key});

  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Program Adı',
                style: TextStyle(
                  color: Color(0xFFC1FF72),
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => {}, //Provider.of<WorkoutProvider>(context, listen: false).addWorkout(name, [], dateCreated)
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => {},
                    child: Text(
                      'Ekle',
                      style: TextStyle(
                        color: Color(0xFFC1FF72),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (context, provider, child) {
                    final workoutList = provider.getAllWorkouts();

                    return ListView.builder(
                      itemCount: workoutList.length,
                      itemBuilder: (context, index) {
                        final workout = workoutList[index];
                        return Dismissible(
                          key: Key((workout.id).toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => provider.removeWorkout(workout.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    workout.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },

                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(0xFFC1FF72),
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
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
