import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';

/// What the engine observed about the user, gathered from tables that
/// already exist (attempts, mock tests, roadmap task completion).
class LearningSignals {
  /// Roadmap days in the past that were fully completed.
  final int completedDays;

  /// Past days with at least one task still pending.
  final int missedDays;

  /// Per-subject mastery, 0-100.
  final Map<String, double> subjectMastery;

  /// Mean mock score as a percentage, or null if none taken.
  final double? averageMockScore;

  /// Tasks finished versus tasks scheduled, over days that have passed.
  final double completionRate;

  const LearningSignals({
    required this.completedDays,
    required this.missedDays,
    required this.subjectMastery,
    required this.completionRate,
    this.averageMockScore,
  });

  static const empty = LearningSignals(
    completedDays: 0,
    missedDays: 0,
    subjectMastery: {},
    completionRate: 0,
  );

  /// Subjects the user is demonstrably struggling with. 50% is the line
  /// because below it the user is scoring worse than a coin flip on a
  /// four-option paper's worth of study — that is a real gap, not noise.
  List<String> get strugglingSubjects => subjectMastery.entries
      .where((e) => e.value > 0 && e.value < 50)
      .map((e) => e.key)
      .toList();

  List<String> get strongSubjects => subjectMastery.entries
      .where((e) => e.value >= 80)
      .map((e) => e.key)
      .toList();
}

/// The decision the engine made, so the UI can explain itself rather than
/// silently rearranging the user's week.
class AdaptationResult {
  final List<RoadmapDay> days;
  final List<String> changes;

  const AdaptationResult({required this.days, required this.changes});

  bool get didAdapt => changes.isNotEmpty;

  /// One-line summary for the dashboard.
  String get headline => changes.isEmpty
      ? 'Your roadmap is on track.'
      : 'Roadmap optimized for you.';
}

/// Reshapes an existing roadmap in response to how the user is actually
/// doing.
///
/// This runs entirely on local data. It is rule-based rather than learned,
/// and the rules are the ones a tutor would apply: if you are behind, cut
/// the load; if you are failing a subject, revisit it; if you have mastered
/// something, stop repeating it.
class AdaptiveRoadmapEngine {
  const AdaptiveRoadmapEngine();

  /// Only reshapes days from [fromDayNumber] onward — rewriting days the
  /// user already completed would erase their record of what they did.
  AdaptationResult adapt({
    required List<RoadmapDay> days,
    required LearningSignals signals,
    required RoadmapPreferences preferences,
    required int fromDayNumber,
  }) {
    if (days.isEmpty) {
      return const AdaptationResult(days: [], changes: []);
    }

    final changes = <String>[];
    var working = List<RoadmapDay>.from(days);

    // Rule 1 — falling behind: lighten future days rather than let the
    // backlog compound. A plan the user is already failing gets abandoned;
    // a smaller plan they can hit rebuilds the habit.
    if (signals.missedDays >= 3 && signals.completionRate < 0.5) {
      working = _mapFuture(working, fromDayNumber, (day) {
        if (day.tasks.length <= 2) return day;
        final trimmed = day.tasks.take(2).toList();
        return day.copyWith(tasks: trimmed);
      });
      changes.add(
        'You missed ${signals.missedDays} days, so upcoming days are lighter — '
        'two focused tasks instead of a full load.',
      );
    }

    // Rule 2 — struggling in a subject: insert revision for it.
    for (final subjectId in signals.strugglingSubjects) {
      working = _insertRevisionFor(working, subjectId, fromDayNumber);
    }
    if (signals.strugglingSubjects.isNotEmpty) {
      changes.add(
        'Added revision for ${signals.strugglingSubjects.length} subject'
        '${signals.strugglingSubjects.length == 1 ? '' : 's'} you are scoring '
        'below 50% in.',
      );
    }

    // Rule 3 — mastered material: stop repeating it. Repetition past
    // mastery is the most common way a plan wastes a user's evenings.
    if (signals.strongSubjects.isNotEmpty) {
      final before = _taskCount(working);
      working = _mapFuture(working, fromDayNumber, (day) {
        final kept = day.tasks
            .where((t) => t.kind != RoadmapTaskKind.revision || !_isStrong(t, signals))
            .toList();
        return kept.isEmpty ? day : day.copyWith(tasks: kept);
      });
      if (_taskCount(working) < before) {
        changes.add(
          'Dropped repeat revision on subjects you have already mastered.',
        );
      }
    }

    // Rule 4 — consistently strong: raise the ceiling.
    if (signals.completionRate >= 0.8 && signals.completedDays >= 5) {
      working = _mapFuture(working, fromDayNumber, (day) {
        if (day.weekNumber < 2) return day;
        if (day.tasks.any((t) => t.kind == RoadmapTaskKind.mock)) return day;
        final extra = RoadmapTask(
          id: '${day.id}-task-bonus',
          dayId: day.id,
          title: 'Stretch set: harder PYQs',
          kind: RoadmapTaskKind.pyq,
          estimatedMinutes: 20,
          orderIndex: day.tasks.length,
        );
        return day.copyWith(tasks: [...day.tasks, extra]);
      });
      changes.add(
        'You are completing ${(signals.completionRate * 100).round()}% of your '
        'tasks — added a harder practice set to keep it challenging.',
      );
    }

    // Rule 5 — weak mock performance late on: convert a study day into a
    // mock day so exam temperament gets practised, not just content.
    final mockScore = signals.averageMockScore;
    if (mockScore != null && mockScore < 40) {
      working = _mapFuture(working, fromDayNumber, (day) {
        if (day.weekNumber != 3) return day;
        if (day.dayNumber % 3 != 0) return day;
        return day.copyWith(tasks: [
          RoadmapTask(
            id: '${day.id}-task-mock',
            dayId: day.id,
            title: 'Timed sectional mock — build exam pacing',
            kind: RoadmapTaskKind.mock,
            estimatedMinutes: preferences.dailyMinutes,
            orderIndex: 0,
          ),
        ]);
      });
      changes.add(
        'Your mock average is ${mockScore.round()}% — added timed mocks in '
        'week 3 to work on pacing.',
      );
    }

    return AdaptationResult(days: working, changes: changes);
  }

  /// Recomputes each day's status from its tasks and the calendar. Kept
  /// separate from [adapt] because it must run on every read, not only when
  /// the engine reshapes something.
  List<RoadmapDay> recomputeStatuses(List<RoadmapDay> days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return days.map((day) {
      final date = DateTime(day.date.year, day.date.month, day.date.day);
      if (day.isFullyComplete) {
        return day.copyWith(status: RoadmapDayStatus.completed);
      }
      if (date.isAtSameMomentAs(today)) {
        return day.copyWith(status: RoadmapDayStatus.current);
      }
      if (date.isBefore(today)) {
        // Partially done reads as "weak" (worth returning to) rather than
        // "missed" (a write-off) — the distinction is what makes the orange
        // state actionable.
        return day.copyWith(
          status: day.completedCount > 0
              ? RoadmapDayStatus.weak
              : RoadmapDayStatus.missed,
        );
      }
      return day.copyWith(status: RoadmapDayStatus.locked);
    }).toList();
  }

  bool _isStrong(RoadmapTask task, LearningSignals signals) {
    // Task-level subject is not carried on the entity, so this errs toward
    // keeping the task: only drop revision when *every* tracked subject is
    // strong, which is the unambiguous case.
    return signals.strugglingSubjects.isEmpty &&
        signals.strongSubjects.isNotEmpty;
  }

  int _taskCount(List<RoadmapDay> days) =>
      days.fold(0, (sum, d) => sum + d.tasks.length);

  List<RoadmapDay> _mapFuture(
    List<RoadmapDay> days,
    int fromDayNumber,
    RoadmapDay Function(RoadmapDay) transform,
  ) {
    return days
        .map((d) => d.dayNumber >= fromDayNumber ? transform(d) : d)
        .toList();
  }

  /// Puts a revision task at the front of the next future day that does not
  /// already carry one, so revision lands soon rather than all at once.
  List<RoadmapDay> _insertRevisionFor(
    List<RoadmapDay> days,
    String subjectId,
    int fromDayNumber,
  ) {
    final result = List<RoadmapDay>.from(days);
    for (var i = 0; i < result.length; i++) {
      final day = result[i];
      if (day.dayNumber < fromDayNumber) continue;
      if (day.tasks.any((t) => t.id.endsWith('-revision-$subjectId'))) continue;
      if (day.tasks.any((t) => t.kind == RoadmapTaskKind.revision)) continue;

      final task = RoadmapTask(
        id: '${day.id}-revision-$subjectId',
        dayId: day.id,
        title: 'Targeted revision — your weakest subject',
        kind: RoadmapTaskKind.revision,
        estimatedMinutes: 30,
        orderIndex: 0,
      );
      result[i] = day.copyWith(tasks: [task, ...day.tasks]);
      return result;
    }
    return result;
  }
}
