import 'package:fit_timer/entity/Workout.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:fit_timer/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class WorkoutListPage extends StatefulWidget {
  const WorkoutListPage({super.key});

  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  final TextEditingController _controller = TextEditingController();
  // Track which program accordion is open
  final Set<int> _expandedIds = {};

  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              const Text(
                'My Programs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create and manage your workout routines',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // ── New program input ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.greyCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_box_outlined, color: AppTheme.neonGreen, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'New program name…',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (value) => _addWorkout(context, value),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _addWorkout(context, _controller.text),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Program list ─────────────────────────────────────────────
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (context, provider, child) {
                    final workouts = provider.getAllWorkouts();
                    if (workouts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No programs yet.\nTap "Add" to create one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        return _ProgramCard(
                          workout: workout,
                          isExpanded: _expandedIds.contains(workout.id),
                          onToggle: () => _toggleExpanded(workout.id),
                          onDelete: () => provider.removeWorkout(workout.id),
                          onEdit: () => context.go('/programs/${workout.id}'),
                          onStart: () {
                            if (workout.exercises.isNotEmpty) {
                              provider.selectWorkout(workout.id, null);
                              context.go('/timer');
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addWorkout(BuildContext context, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      Provider.of<WorkoutProvider>(context, listen: false)
          .addWorkout(trimmed, [], DateTime.now());
      _controller.clear();
    }
  }
}

// ── Accordion program card ──────────────────────────────────────────────────
class _ProgramCard extends StatelessWidget {
  final Workout workout;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onStart;

  const _ProgramCard({
    required this.workout,
    required this.isExpanded,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('workout_${workout.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppTheme.greyCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpanded ? AppTheme.neonGreen.withOpacity(0.4) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // ── Header row ─────────────────────────────────────────────
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
                  child: Row(
                    children: [
                      // Neon dot indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.neonGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${workout.exercises.length} exercise${workout.exercises.length == 1 ? '' : 's'}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                        tooltip: 'Edit program',
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      // Expand chevron
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Collapsible exercise list ──────────────────────────────
              // ClipRect + AnimatedSize reveals content without squishing text
              // (AnimatedCrossFade was distorting letters during collapse).
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.white12, height: 1),
                            if (workout.exercises.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 18),
                                child: Text(
                                  'No exercises yet — tap ✏️ to add some.',
                                  style:
                                      TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              )
                            else
                              ...workout.exercises.asMap().entries.map((entry) {
                                final i = entry.key;
                                final ex = entry.value;
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 0),
                                  leading: Text(
                                    '${i + 1}.',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                  title: Text(
                                    ex.name,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  trailing: Text(
                                    '${ex.sets}×${ex.reps}',
                                    style: const TextStyle(
                                        color: AppTheme.neonGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }),
                            // Start button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.neonGreen,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  icon: const Icon(Icons.play_arrow, size: 20),
                                  label: const Text(
                                    'Start Workout',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  onPressed:
                                      workout.exercises.isEmpty ? null : onStart,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
