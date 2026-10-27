import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/features/roadmap/data/services/adaptive_roadmap_engine.dart';
import 'package:prepnode/features/roadmap/data/services/roadmap_generator.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';

RoadmapPreferences _prefs({
  PreparationLevel level = PreparationLevel.beginner,
  int hours = 3,
  StudentType type = StudentType.fullTime,
}) {
  return RoadmapPreferences(
    userId: 'u1',
    examId: 'tnpsc-group2',
    level: level,
    hoursPerDay: hours,
    preferredTime: PreferredStudyTime.morning,
    targetMonth: 6,
    targetYear: DateTime.now().year + 1,
    studentType: type,
  );
}

List<SyllabusTopic> _syllabus() {
  return [
    // A parent with children — the parent must not be scheduled itself.
    const SyllabusTopic(
      topicId: 'polity',
      subjectId: 'gs',
      name: 'Indian Constitution',
      importanceScore: 0.95,
    ),
    const SyllabusTopic(
      topicId: 'rights',
      subjectId: 'gs',
      name: 'Fundamental Rights',
      parentTopicId: 'polity',
      importanceScore: 0.9,
    ),
    const SyllabusTopic(
      topicId: 'judiciary',
      subjectId: 'gs',
      name: 'Judiciary',
      parentTopicId: 'polity',
      importanceScore: 0.82,
    ),
    const SyllabusTopic(
      topicId: 'algebra',
      subjectId: 'apt',
      name: 'Algebra',
      importanceScore: 0.78,
      mastery: 85,
    ),
    const SyllabusTopic(
      topicId: 'numbers',
      subjectId: 'apt',
      name: 'Number System',
      importanceScore: 0.85,
    ),
    const SyllabusTopic(
      topicId: 'grammar',
      subjectId: 'tamil',
      name: 'Tamil Grammar',
      importanceScore: 0.85,
    ),
  ];
}

void main() {
  const generator = RoadmapGenerator();
  final start = DateTime(2026, 3, 1);

  group('RoadmapGenerator', () {
    test('produces exactly 30 days across 4 week bands with the right focus',
        () {
      final days = generator.generate(
        preferences: _prefs(),
        topics: _syllabus(),
        startDate: start,
      );

      expect(days.length, 30);
      expect(days.first.dayNumber, 1);
      expect(days.last.dayNumber, 30);
      expect(days.map((d) => d.weekNumber).toSet(), {1, 2, 3, 4, 5});

      expect(days.firstWhere((d) => d.weekNumber == 1).focusLabel, 'Foundations');
      expect(days.firstWhere((d) => d.weekNumber == 2).focusLabel, 'Core Subjects');
      expect(days.firstWhere((d) => d.weekNumber == 3).focusLabel,
          'Current Affairs & Revision');
      expect(days.firstWhere((d) => d.weekNumber == 4).focusLabel,
          'Mock Tests & Assessment');
    });

    test('every day has tasks and dates advance by one day', () {
      final days = generator.generate(
        preferences: _prefs(),
        topics: _syllabus(),
        startDate: start,
      );

      for (var i = 0; i < days.length; i++) {
        expect(days[i].tasks, isNotEmpty,
            reason: 'day ${days[i].dayNumber} has nothing to do');
        expect(days[i].date, start.add(Duration(days: i)));
      }
    });

    test('respects the daily time budget', () {
      final prefs = _prefs(hours: 2);
      final days = generator.generate(
        preferences: prefs,
        topics: _syllabus(),
        startDate: start,
      );

      for (final day in days) {
        expect(day.totalMinutes, lessThanOrEqualTo(prefs.dailyMinutes + 5),
            reason: 'day ${day.dayNumber} over-schedules the user');
      }
    });

    test('a working student gets a lighter day than a full-time one', () {
      final working = _prefs(type: StudentType.working).dailyMinutes;
      final fullTime = _prefs(type: StudentType.fullTime).dailyMinutes;
      expect(working, lessThan(fullTime));
    });

    test('never schedules a parent topic that has children', () {
      final days = generator.generate(
        preferences: _prefs(),
        topics: _syllabus(),
        startDate: start,
      );

      final scheduled = days
          .expand((d) => d.tasks)
          .map((t) => t.topicId)
          .whereType<String>()
          .toSet();

      expect(scheduled, isNot(contains('polity')),
          reason: 'a container topic would double-book its own children');
    });

    test('already-mastered topics are scheduled as revision, not fresh study',
        () {
      final days = generator.generate(
        preferences: _prefs(level: PreparationLevel.intermediate),
        topics: _syllabus(),
        startDate: start,
      );

      final algebraTasks =
          days.expand((d) => d.tasks).where((t) => t.topicId == 'algebra');
      expect(algebraTasks, isNotEmpty);
      expect(
        algebraTasks.every((t) => t.kind != RoadmapTaskKind.study),
        isTrue,
        reason: 'a topic at 85% mastery should not be taught from scratch',
      );
    });

    test('week 4 is assessment-led and ends with a final assessment', () {
      final days = generator.generate(
        preferences: _prefs(),
        topics: _syllabus(),
        startDate: start,
      );

      final week4 = days.where((d) => d.weekNumber >= 4).toList();
      expect(
        week4.any((d) => d.tasks.any((t) => t.kind == RoadmapTaskKind.mock)),
        isTrue,
      );
      expect(
        days.last.tasks.any((t) => t.kind == RoadmapTaskKind.assessment),
        isTrue,
      );
    });

    test('is deterministic — same inputs, same plan', () {
      final a = generator.generate(
          preferences: _prefs(), topics: _syllabus(), startDate: start);
      final b = generator.generate(
          preferences: _prefs(), topics: _syllabus(), startDate: start);

      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].tasks.map((t) => t.title).toList(),
            b[i].tasks.map((t) => t.title).toList());
      }
    });

    test('an empty syllabus yields no plan rather than empty days', () {
      final days = generator.generate(
        preferences: _prefs(),
        topics: const [],
        startDate: start,
      );
      expect(days, isEmpty);
    });
  });

  group('AdaptiveRoadmapEngine', () {
    const engine = AdaptiveRoadmapEngine();

    List<RoadmapDay> baseDays() => generator.generate(
          preferences: _prefs(),
          topics: _syllabus(),
          startDate: start,
        );

    test('does nothing when the user is on track', () {
      final result = engine.adapt(
        days: baseDays(),
        signals: const LearningSignals(
          completedDays: 2,
          missedDays: 0,
          subjectMastery: {},
          completionRate: 0.7,
        ),
        preferences: _prefs(),
        fromDayNumber: 3,
      );

      expect(result.didAdapt, isFalse);
      expect(result.headline, 'Your roadmap is on track.');
    });

    test('lightens future days when the user keeps missing them', () {
      final before = baseDays();
      final result = engine.adapt(
        days: before,
        signals: const LearningSignals(
          completedDays: 0,
          missedDays: 4,
          subjectMastery: {},
          completionRate: 0.2,
        ),
        preferences: _prefs(),
        fromDayNumber: 5,
      );

      expect(result.didAdapt, isTrue);
      for (final day in result.days.where((d) => d.dayNumber >= 5)) {
        expect(day.tasks.length, lessThanOrEqualTo(2));
      }
      // Past days are untouched — the user's record must not be rewritten.
      final pastBefore = before.firstWhere((d) => d.dayNumber == 2);
      final pastAfter = result.days.firstWhere((d) => d.dayNumber == 2);
      expect(pastAfter.tasks.length, pastBefore.tasks.length);
    });

    test('inserts revision for a subject scoring under 50%', () {
      final result = engine.adapt(
        days: baseDays(),
        signals: const LearningSignals(
          completedDays: 3,
          missedDays: 0,
          subjectMastery: {'gs': 35.0},
          completionRate: 0.7,
        ),
        preferences: _prefs(),
        fromDayNumber: 3,
      );

      expect(result.didAdapt, isTrue);
      expect(
        result.days.any((d) => d.tasks.any((t) => t.id.endsWith('-revision-gs'))),
        isTrue,
      );
      expect(result.changes.join(' '), contains('below 50%'));
    });

    test('adds a harder set for a consistently strong user', () {
      final result = engine.adapt(
        days: baseDays(),
        signals: const LearningSignals(
          completedDays: 6,
          missedDays: 0,
          subjectMastery: {},
          completionRate: 0.9,
        ),
        preferences: _prefs(),
        fromDayNumber: 8,
      );

      expect(
        result.days.any((d) => d.tasks.any((t) => t.title.contains('Stretch set'))),
        isTrue,
      );
    });

    test('adds timed mocks when the mock average is poor', () {
      final result = engine.adapt(
        days: baseDays(),
        signals: const LearningSignals(
          completedDays: 3,
          missedDays: 0,
          subjectMastery: {},
          completionRate: 0.7,
          averageMockScore: 28,
        ),
        preferences: _prefs(),
        fromDayNumber: 3,
      );

      expect(result.didAdapt, isTrue);
      expect(result.changes.join(' '), contains('pacing'));
      expect(
        result.days.any((d) =>
            d.weekNumber == 3 && d.tasks.any((t) => t.kind == RoadmapTaskKind.mock)),
        isTrue,
      );
    });

    test('recomputeStatuses marks a fully-done past day completed and a '
        'partly-done one weak', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final days = [
        RoadmapDay(
          id: 'd1',
          dayNumber: 1,
          weekNumber: 1,
          date: yesterday,
          focusLabel: 'Foundations',
          status: RoadmapDayStatus.locked,
          tasks: [
            const RoadmapTask(
              id: 't1',
              dayId: 'd1',
              title: 'A',
              kind: RoadmapTaskKind.study,
              estimatedMinutes: 30,
              isCompleted: true,
            ),
          ],
        ),
        RoadmapDay(
          id: 'd2',
          dayNumber: 2,
          weekNumber: 1,
          date: yesterday,
          focusLabel: 'Foundations',
          status: RoadmapDayStatus.locked,
          tasks: [
            const RoadmapTask(
              id: 't2',
              dayId: 'd2',
              title: 'A',
              kind: RoadmapTaskKind.study,
              estimatedMinutes: 30,
              isCompleted: true,
            ),
            const RoadmapTask(
              id: 't3',
              dayId: 'd2',
              title: 'B',
              kind: RoadmapTaskKind.study,
              estimatedMinutes: 30,
            ),
          ],
        ),
        RoadmapDay(
          id: 'd3',
          dayNumber: 3,
          weekNumber: 1,
          date: yesterday,
          focusLabel: 'Foundations',
          status: RoadmapDayStatus.locked,
          tasks: [
            const RoadmapTask(
              id: 't4',
              dayId: 'd3',
              title: 'A',
              kind: RoadmapTaskKind.study,
              estimatedMinutes: 30,
            ),
          ],
        ),
      ];

      final result = engine.recomputeStatuses(days);
      expect(result[0].status, RoadmapDayStatus.completed);
      expect(result[1].status, RoadmapDayStatus.weak);
      expect(result[2].status, RoadmapDayStatus.missed);
    });
  });
}
