import 'dart:math' as math;

import 'package:fit_timer/core/theme.dart';
import 'package:fit_timer/entity/ProgramState.dart';
import 'package:fit_timer/state/concrete/TimerProvider.dart';
import 'package:fit_timer/state/concrete/WorkoutProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class WorkoutTimerPage extends StatefulWidget {
  const WorkoutTimerPage({super.key});

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}

class _WorkoutTimerPageState extends State<WorkoutTimerPage>
    with SingleTickerProviderStateMixin {
  // ── Bubble sizing (fraction of screen width) ──────────────────────────────
  static const double _smFrac     = 400 / 1080; // inactive
  static const double _lgFrac     = 700 / 1080; // active
  static const double _smFontFrac = 39  / 1080;
  static const double _mdFontFrac = 75  / 1080;

  // Vertical position of each bubble centre inside the flex-5 Stack.
  // ±0.52 gives a ~25 px gap at the resting size on most phones.
  static const double _breakAlignY = -0.52;
  static const double _workAlignY  =  0.52;

  static const Duration _animDuration = Duration(milliseconds: 600);
  static const Curve    _animCurve    = Curves.elasticOut;

  // ── Shake animation ───────────────────────────────────────────────────────
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _triggerShake() => _shakeCtrl.forward(from: 0);

  double get _shakeOffset =>
      math.sin(_shakeCtrl.value * math.pi * 4) * 10 * (1 - _shakeCtrl.value);

  bool _isMenuOpen = false;
  void _toggleMenu() => setState(() => _isMenuOpen = !_isMenuOpen);

  // ── Break bubble (black, upper half) ─────────────────────────────────────
  Widget _buildBreakCircle(double sw, TimerProvider tp) {
    final bool isBreak = tp.isBreak;
    return Align(
      key: const ValueKey('B'),
      alignment: const Alignment(0, _breakAlignY),
      child: GestureDetector(
        onTap: () {
          tp.toggleBreak();
          if (isBreak) _triggerShake(); // shake only when already active
        },
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (_, child) => Transform.translate(
            // Apply shake only to the currently-active (large) bubble
            offset: Offset(isBreak ? _shakeOffset : 0, 0),
            child: child,
          ),
          child: AnimatedContainer(
            duration: _animDuration,
            curve: _animCurve,
            width:  isBreak ? sw * _lgFrac : sw * _smFrac,
            height: isBreak ? sw * _lgFrac : sw * _smFrac,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBreak ? const Color(0xBF000000) : const Color(0xFF000000),
              boxShadow: [
                BoxShadow(
                  color: isBreak ? Colors.black45 : Colors.transparent,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: _animDuration,
                curve: _animCurve,
                style: TextStyle(
                  fontSize: isBreak ? sw * _mdFontFrac : sw * _smFontFrac,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('BREAK'),
                    Text(tp.breakTimer),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Work / Sets bubble (green, lower half) ────────────────────────────────
  Widget _buildWorkCircle(double sw, TimerProvider tp, WorkoutProvider wp) {
    final bool isBreak = tp.isBreak;
    final ProgramState ps = wp.programState;

    final int setsCount = ps.selected
        ? (ps.setsCompleted[ps.currentExercise?.id] ?? 0)
        : tp.setsCompleted;
    final String setLabel = setsCount > 0 ? 'SET $setsCount' : 'SETS';

    return Align(
      key: const ValueKey('A'),
      alignment: const Alignment(0, _workAlignY),
      child: GestureDetector(
        onTap: () {
          tp.toggleWork();
          if (!isBreak) _triggerShake(); // shake only when already active
        },
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (_, child) => Transform.translate(
            offset: Offset(!isBreak ? _shakeOffset : 0, 0),
            child: child,
          ),
          child: AnimatedContainer(
            duration: _animDuration,
            curve: _animCurve,
            width:  isBreak ? sw * _smFrac : sw * _lgFrac,
            height: isBreak ? sw * _smFrac : sw * _lgFrac,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBreak ? AppTheme.neonGreen : const Color(0xE6C1FF72),
              boxShadow: [
                BoxShadow(
                  color: !isBreak ? Colors.black45 : Colors.transparent,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: _animDuration,
                curve: _animCurve,
                style: TextStyle(
                  fontSize: isBreak ? sw * _smFontFrac : sw * _mdFontFrac,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(setLabel),
                    Text(tp.setTimer),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Exercise navigator ────────────────────────────────────────────────────
  // Looks like a horizontal tape: prev (faded left) | current (bold) | next (faded right)
  Widget _buildExerciseNav(WorkoutProvider wp) {
    final ps = wp.programState;
    final exercises = ps.currentProgram?.exercises ?? [];
    final int currentIdx = ps.currentExercise == null
        ? -1
        : exercises.indexWhere((e) => e.id == ps.currentExercise!.id);

    final bool hasPrev = ps.selected && currentIdx > 0;
    final bool hasNext =
        ps.selected && currentIdx >= 0 && currentIdx < exercises.length - 1;
    final String prevName = hasPrev ? exercises[currentIdx - 1].name as String : '';
    final String nextName = hasNext ? exercises[currentIdx + 1].name as String : '';
    final String currName = ps.currentExercise?.name ?? 'No Program Selected';

    const TextStyle _sideStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0x44000000),
      letterSpacing: 0.2,
      height: 1.2,
    );
    const TextStyle _currStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      letterSpacing: 0.3,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Left: ← prev ─────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: hasPrev ? wp.prevExercise : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    prevName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: _sideStyle,
                  ),
                ),
                const SizedBox(width: 4),
                Opacity(
                  opacity: hasPrev ? 1.0 : 0.0,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: AppTheme.neonGreen, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Centre: current exercise ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(currName, style: _currStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),

        // ── Right: next → ─────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: hasNext ? wp.nextExercise : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Opacity(
                  opacity: hasNext ? 1.0 : 0.0,
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppTheme.neonGreen, size: 18),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    nextName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: _sideStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Main column ──────────────────────────────────────────────────
          Consumer2<WorkoutProvider, TimerProvider>(
            builder: (context, wp, tp, _) {
              return Column(
                children: [
                  // ── TOP: chevron + exercise nav ────────────────────────
                  Expanded(
                    flex: 2,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _toggleMenu,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black26, size: 32),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildExerciseNav(wp),
                        ],
                      ),
                    ),
                  ),

                  // ── MIDDLE: bubbles ────────────────────────────────────
                  Expanded(
                    flex: 5,
                    child: Stack(
                      clipBehavior: Clip.none,
                      // Inactive first (behind), active last (in front)
                      children: tp.isBreak
                          ? [
                              _buildWorkCircle(sw, tp, wp),
                              _buildBreakCircle(sw, tp),
                            ]
                          : [
                              _buildBreakCircle(sw, tp),
                              _buildWorkCircle(sw, tp, wp),
                            ],
                    ),
                  ),

                  // ── BOTTOM: set +/- and pause status display ───────────
                  Expanded(
                    flex: 2,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Set counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.black38, size: 26),
                                onPressed: tp.manualRemoveSet,
                              ),
                              const SizedBox(width: 28),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.black38, size: 26),
                                onPressed: tp.manualAddSet,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // ── Pause status indicator (display only, not a button) ──
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: tp.isPaused ? 1.0 : 0.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                const Text(
                                  'PAUSED',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Back (only when page is pushed, not the root /timer)
                          if (GoRouterState.of(context).uri.toString() != '/timer')
                            TextButton.icon(
                              icon: const Icon(Icons.arrow_back,
                                  color: AppTheme.neonGreen, size: 16),
                              label: const Text('Back',
                                  style: TextStyle(
                                      color: AppTheme.neonGreen, fontSize: 13)),
                              onPressed: context.pop,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Slide-down workout progress panel ─────────────────────────
          Consumer<WorkoutProvider>(builder: (context, wp, _) {
            final exercises = wp.programState.currentProgram?.exercises ?? [];
            final currentId = wp.programState.currentExercise?.id;
            final setsMap   = wp.programState.setsCompleted;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              top: _isMenuOpen ? 0 : -(sh * 0.75),
              left: 0,
              right: 0,
              height: sh * 0.75,
              child: GestureDetector(
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) > 150) _toggleMenu();
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundBlack,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          spreadRadius: 2),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Workout Progress',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: exercises.length,
                            itemBuilder: (context, i) {
                              final ex = exercises[i];
                              final isCurrent = ex.id == currentId;
                              final done = setsMap[ex.id] ?? 0;
                              return ListTile(
                                title: Text(ex.name,
                                    style: TextStyle(
                                      color: isCurrent
                                          ? AppTheme.neonGreen
                                          : Colors.white,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    )),
                                subtitle: Text('$done / ${ex.sets} sets',
                                    style: const TextStyle(color: Colors.grey)),
                                trailing: isCurrent
                                    ? const Icon(Icons.fitness_center,
                                        color: AppTheme.neonGreen)
                                    : null,
                              );
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleMenu,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Icon(Icons.keyboard_arrow_up,
                                color: AppTheme.neonGreen, size: 34),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
