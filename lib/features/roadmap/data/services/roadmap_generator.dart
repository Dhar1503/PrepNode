import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';

/// A syllabus topic as the generator needs it — deliberately a plain value
/// type so the generator can be unit-tested without a database.
class SyllabusTopic {
  final String topicId;
  final String subjectId;
  final String name;
  final String? parentTopicId;
  final double importanceScore;

  /// 0-100. Drives which topics become revision rather than fresh study.
  final double mastery;

  const SyllabusTopic({
    required this.topicId,
    required this.subjectId,
    required this.name,
    required this.importanceScore,
    this.parentTopicId,
    this.mastery = 0,
  });
}

/// Builds a 30-day study plan from the user's preferences and the real
/// syllabus.
///
/// Deterministic on purpose: the same inputs always produce the same plan.
/// A randomised plan would be impossible to test, impossible to explain to
/// the user ("why did today change?"), and would reshuffle itself on every
/// rebuild. What varies is the *input* — as mastery and completion change,
/// regenerating produces a genuinely different plan.
class RoadmapGenerator {
  const RoadmapGenerator();

  /// The four-week arc. Week 1-2 build coverage, week 3 consolidates,
  /// week 4 tests under exam conditions — the standard structure TNPSC
  /// coaching uses, and the one the brief asks for.
  static const List<String> weekFocus = [
    'Foundations',
    'Core Subjects',
    'Current Affairs & Revision',
    'Mock Tests & Assessment',
  ];

  /// Subjects are visited in a fixed rotation so that no subject goes more
  /// than a few days without attention — spacing beats blocking for
  /// retention, and it also means a user who quits on day 9 has still
  /// touched every subject.
  List<RoadmapDay> generate({
    required RoadmapPreferences preferences,
    required List<SyllabusTopic> topics,
    required DateTime startDate,
    int dayCount = 30,
  }) {
    if (topics.isEmpty) return const [];

    final studyPool = _orderTopics(preferences, topics);
    final days = <RoadmapDay>[];
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    var poolCursor = 0;

    for (var i = 0; i < dayCount; i++) {
      final dayNumber = i + 1;
      final weekNumber = (i ~/ 7) + 1;
      final date = start.add(Duration(days: i));
      final dayId = '${preferences.userId}-day-$dayNumber';
      final focus = weekFocus[(weekNumber - 1).clamp(0, weekFocus.length - 1)];

      final tasks = _tasksForDay(
        preferences: preferences,
        dayId: dayId,
        dayNumber: dayNumber,
        weekNumber: weekNumber,
        pool: studyPool,
        poolCursor: poolCursor,
      );
      poolCursor += tasks.where((t) => t.kind == RoadmapTaskKind.study).length;

      days.add(RoadmapDay(
        id: dayId,
        dayNumber: dayNumber,
        weekNumber: weekNumber,
        date: date,
        focusLabel: focus,
        status: _statusFor(date, start),
        tasks: tasks,
      ));
    }

    return days;
  }

  /// Orders the syllabus so the plan opens with what actually pays.
  ///
  /// A beginner gets the highest-importance, lowest-difficulty material
  /// first so early days feel winnable. An advanced user gets their weakest
  /// topics first, because they do not need the easy wins — they need the
  /// gaps closed.
  List<SyllabusTopic> _orderTopics(
    RoadmapPreferences preferences,
    List<SyllabusTopic> topics,
  ) {
    // Leaf topics only: a parent like "Indian Constitution" is a container,
    // and scheduling it alongside its own children double-books the same
    // material.
    final parentIds = topics
        .map((t) => t.parentTopicId)
        .whereType<String>()
        .toSet();
    var pool = topics.where((t) => !parentIds.contains(t.topicId)).toList();
    if (pool.isEmpty) pool = List.of(topics);

    pool.sort((a, b) {
      if (preferences.level == PreparationLevel.advanced) {
        final byMastery = a.mastery.compareTo(b.mastery);
        if (byMastery != 0) return byMastery;
      }
      final byImportance = b.importanceScore.compareTo(a.importanceScore);
      if (byImportance != 0) return byImportance;
      return a.name.compareTo(b.name);
    });

    // Interleave by subject so consecutive days are not all one subject.
    return _interleaveBySubject(pool);
  }

  List<SyllabusTopic> _interleaveBySubject(List<SyllabusTopic> ordered) {
    final bySubject = <String, List<SyllabusTopic>>{};
    for (final topic in ordered) {
      bySubject.putIfAbsent(topic.subjectId, () => []).add(topic);
    }

    final queues = bySubject.values.toList();
    final result = <SyllabusTopic>[];
    var index = 0;
    while (result.length < ordered.length) {
      var placedAny = false;
      for (final queue in queues) {
        if (index < queue.length) {
          result.add(queue[index]);
          placedAny = true;
        }
      }
      if (!placedAny) break;
      index++;
    }
    return result;
  }

  List<RoadmapTask> _tasksForDay({
    required RoadmapPreferences preferences,
    required String dayId,
    required int dayNumber,
    required int weekNumber,
    required List<SyllabusTopic> pool,
    required int poolCursor,
  }) {
    final budget = preferences.dailyMinutes;
    final tasks = <RoadmapTask>[];
    var order = 0;

    RoadmapTask make({
      required String title,
      required RoadmapTaskKind kind,
      required int minutes,
      String? topicId,
    }) {
      final task = RoadmapTask(
        id: '$dayId-task-${order + 1}',
        dayId: dayId,
        topicId: topicId,
        title: title,
        kind: kind,
        estimatedMinutes: minutes,
        orderIndex: order,
      );
      order++;
      return task;
    }

    // Week 4 is assessment-led; the other weeks are study-led with a PYQ
    // chaser, which is what actually converts reading into marks.
    if (weekNumber >= 4) {
      final isFinalDay = dayNumber >= 29;
      if (isFinalDay) {
        tasks.add(make(
          title: 'Final assessment — full-length mock',
          kind: RoadmapTaskKind.assessment,
          minutes: (budget * 0.7).round(),
        ));
        tasks.add(make(
          title: 'Review every incorrect answer',
          kind: RoadmapTaskKind.revision,
          minutes: budget - tasks.first.estimatedMinutes,
        ));
        return tasks;
      }

      // Alternate mock days with weak-topic repair days, so a mock is
      // always followed by acting on what it exposed.
      if (dayNumber.isEven) {
        tasks.add(make(
          title: 'Sectional mock test',
          kind: RoadmapTaskKind.mock,
          minutes: (budget * 0.6).round(),
        ));
        tasks.add(make(
          title: 'Analyse mistakes and note weak areas',
          kind: RoadmapTaskKind.revision,
          minutes: budget - (budget * 0.6).round(),
        ));
      } else {
        final topic = _topicAt(pool, poolCursor);
        tasks.add(make(
          title: 'Weak topic revision: ${topic?.name ?? 'your lowest-mastery topics'}',
          kind: RoadmapTaskKind.revision,
          topicId: topic?.topicId,
          minutes: (budget * 0.5).round(),
        ));
        tasks.add(make(
          title: 'Previous-year questions on the same topic',
          kind: RoadmapTaskKind.pyq,
          topicId: topic?.topicId,
          minutes: budget - (budget * 0.5).round(),
        ));
      }
      return tasks;
    }

    if (weekNumber == 3) {
      tasks.add(make(
        title: 'Current affairs round-up',
        kind: RoadmapTaskKind.study,
        minutes: (budget * 0.25).round(),
      ));
    }

    // How many fresh topics fit today. A beginner gets one topic with room
    // to actually absorb it; an advanced user can carry two.
    final topicsToday = preferences.level == PreparationLevel.beginner ? 1 : 2;
    final studyBudget = weekNumber == 3 ? (budget * 0.45).round() : (budget * 0.6).round();
    final perTopic = (studyBudget / topicsToday).round().clamp(15, 180);

    for (var i = 0; i < topicsToday; i++) {
      final topic = _topicAt(pool, poolCursor + i);
      if (topic == null) break;
      final isRevision = topic.mastery >= 70;
      tasks.add(make(
        title: isRevision
            ? 'Revise ${topic.name}'
            : 'Study ${topic.name}',
        kind: isRevision ? RoadmapTaskKind.revision : RoadmapTaskKind.study,
        topicId: topic.topicId,
        minutes: perTopic,
      ));
    }

    final used = tasks.fold<int>(0, (sum, t) => sum + t.estimatedMinutes);
    final remaining = budget - used;
    if (remaining >= 15) {
      final topic = _topicAt(pool, poolCursor);
      tasks.add(make(
        title: 'Practise PYQs${topic == null ? '' : ' — ${topic.name}'}',
        kind: RoadmapTaskKind.pyq,
        topicId: topic?.topicId,
        minutes: remaining,
      ));
    }

    return tasks;
  }

  /// Wraps around the pool rather than running dry, so day 30 still has
  /// work even for a small syllabus.
  SyllabusTopic? _topicAt(List<SyllabusTopic> pool, int index) {
    if (pool.isEmpty) return null;
    return pool[index % pool.length];
  }

  RoadmapDayStatus _statusFor(DateTime date, DateTime start) {
    final today = DateTime.now();
    final normalisedToday = DateTime(today.year, today.month, today.day);
    if (date.isAtSameMomentAs(normalisedToday)) return RoadmapDayStatus.current;
    if (date.isBefore(normalisedToday)) return RoadmapDayStatus.missed;
    return RoadmapDayStatus.locked;
  }
}
