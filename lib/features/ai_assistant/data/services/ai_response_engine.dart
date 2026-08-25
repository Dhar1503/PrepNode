/// AI Response Engine
/// Generates rule-based, contextual replies entirely from this device's
/// real local data (Insights, Planner, PYQ, Mock Test, Cutoff, Knowledge
/// Graph, Profile) — no online LLM, no remote calls. Every response is
/// either grounded in a real repository result or an honest "not enough
/// data yet" message; nothing here is fabricated placeholder text.
library;

import 'package:prepgraph/features/auth/domain/entities/user.dart';
import 'package:prepgraph/features/auth/domain/repositories/profile_repository.dart';
import 'package:prepgraph/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepgraph/features/cutoff/domain/repositories/cutoff_repository.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/pyq_performance.dart';
import 'package:prepgraph/features/insights/domain/entities/study_habits.dart';
import 'package:prepgraph/features/insights/domain/entities/weak_area.dart';
import 'package:prepgraph/features/insights/domain/repositories/insights_repository.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic_detail.dart';
import 'package:prepgraph/features/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepgraph/features/mock_test/domain/repositories/mock_test_repository.dart';
import 'package:prepgraph/features/planner/domain/entities/daily_plan.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';
import 'package:prepgraph/features/planner/domain/repositories/planner_repository.dart';
import 'package:prepgraph/features/pyq/domain/repositories/pyq_repository.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';
import 'package:prepgraph/features/resources/domain/repositories/resource_repository.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/ai_insight.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/ai_recommendation.dart';
import 'package:prepgraph/features/strategy/domain/entities/study_capacity.dart';
import 'package:prepgraph/features/strategy/domain/repositories/strategy_repository.dart';

class AiResponseEngine {
  final InsightsRepository _insights;
  final PlannerRepository _planner;
  final PyqRepository _pyq;
  final MockTestRepository _mockTest;
  final CutoffRepository _cutoff;
  final KnowledgeGraphRepository _knowledgeGraph;
  final ProfileRepository _profile;
  final ResourceRepository _resources;
  final StrategyRepository _strategy;

  AiResponseEngine({
    required InsightsRepository insightsRepository,
    required PlannerRepository plannerRepository,
    required PyqRepository pyqRepository,
    required MockTestRepository mockTestRepository,
    required CutoffRepository cutoffRepository,
    required KnowledgeGraphRepository knowledgeGraphRepository,
    required ProfileRepository profileRepository,
    required ResourceRepository resourceRepository,
    required StrategyRepository strategyRepository,
  })  : _insights = insightsRepository,
        _planner = plannerRepository,
        _pyq = pyqRepository,
        _mockTest = mockTestRepository,
        _cutoff = cutoffRepository,
        _knowledgeGraph = knowledgeGraphRepository,
        _profile = profileRepository,
        _resources = resourceRepository,
        _strategy = strategyRepository;

  // ==================== Chat intent routing ====================

  /// Routes a free-text message to the matching real-data handler. Order
  /// matters: more specific intents are checked before generic ones.
  Future<String> reply({required String userId, required String message}) async {
    if (userId.isEmpty) {
      return "I don't have a signed-in learner to look up progress for right now — please log in first.";
    }

    final text = message.toLowerCase();

    if (_matchesAny(text, ['hi', 'hello', 'hey', 'help', 'what can you do'])) {
      return _capabilitiesMessage();
    }
    if (_matchesAny(text, ['motivat', 'give up', 'tired', 'discourag', 'stressed', 'anxious'])) {
      return _motivationMessage(userId);
    }
    // Category self-identification ("I am BC", "I'm SC category") — checked
    // before the generic cutoff intent so it answers with THAT category's
    // real cutoff, not whatever's globally selected in Cutoff Intelligence.
    final mentionedCategory = _extractCategory(text);
    if (mentionedCategory != null) {
      return _categoryMessage(userId, mentionedCategory);
    }
    // Timeline framing ("I have only 20 days", "20 days left") — routes to
    // the Strategy Engine's roadmap rather than the generic planner intent.
    final mentionedDays = _extractDayCount(text);
    if (mentionedDays != null) {
      return _timelineMessage(userId, mentionedDays);
    }
    if (_matchesAny(text, ['fastest way', 'best way to clear', 'what should i study', 'next best topic', 'what to study'])) {
      return _strategyMessage(userId);
    }
    if (_matchesAny(text, ['career', 'promotion', 'salary', 'pay scale', 'which post', 'job prospect', 'future scope', 'after selection', 'what job'])) {
      return _careerGuidanceMessage();
    }
    if (_matchesAny(text, ['cutoff', 'readiness', 'chance', 'qualify', 'will i pass'])) {
      return _cutoffMessage(userId);
    }
    if (_matchesAny(text, ['revis', 'review'])) {
      return _revisionMessage(userId);
    }
    if (_matchesAny(text, ['weak', 'struggl', 'improve', 'difficult topic'])) {
      return _weakAreasMessage(userId);
    }
    if (_matchesAny(text, ['plan', 'today', 'schedule', 'what should i study'])) {
      return _plannerMessage(userId);
    }
    if (_matchesAny(text, ['mock test', 'mock-test', 'test score', 'my test'])) {
      return _mockTestMessage(userId);
    }
    if (_matchesAny(text, ['pyq', 'previous year', 'past paper'])) {
      return _pyqMessage(userId);
    }
    if (_matchesAny(text, ['mastery', 'understand', 'concept', 'topic progress'])) {
      return _masteryMessage(userId);
    }
    if (_matchesAny(text, ['study hours', 'target exam', 'exam date', 'my profile'])) {
      return _profileMessage(userId);
    }

    return _fallbackMessage();
  }

  // Leading word-boundary, not raw substring — text.contains('hi') was
  // matching inside ordinary words like "this" or "within", silently
  // hijacking unrelated questions into the greeting/capabilities response
  // (e.g. "...approach studying THIS resource" matched the 'hi' keyword).
  // Only a leading \b (not also trailing) because several keywords here
  // are deliberate truncated stems relying on prefix matching to catch
  // every inflection — 'struggl' for struggling/struggled, 'concept' for
  // concepts, 'revis' for revise/revision — a trailing \b would break all
  // of those. The one remaining gap a leading-only \b can't close is a
  // 2-letter keyword prefix-matching into an unrelated longer word (e.g.
  // 'hi' at the start of "history", a real TNPSC subject) — those get an
  // exact whole-word match instead, since a bare 2-letter fragment is
  // never a deliberate stem in this list.
  bool _matchesAny(String text, List<String> keywords) => keywords.any((k) {
        final pattern = k.length <= 2 ? r'\b' + RegExp.escape(k) + r'\b' : r'\b' + RegExp.escape(k);
        return RegExp(pattern).hasMatch(text);
      });

  // Longest codes first — "BCM"/"SCA" would otherwise also match the "BC"/
  // "SC" check since they contain those letters.
  static const _categoryCodes = ['BCM', 'SCA', 'OC', 'BC', 'MBC', 'SC', 'ST'];

  String? _extractCategory(String lowerText) {
    for (final code in _categoryCodes) {
      final pattern = RegExp(r'\b' + code.toLowerCase() + r'\b');
      if (pattern.hasMatch(lowerText)) return code;
    }
    return null;
  }

  int? _extractDayCount(String lowerText) {
    final match = RegExp(r'(\d+)\s*days?\b').firstMatch(lowerText);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  String _capabilitiesMessage() {
    return "I can help using your real PrepGraph data — try asking things like:\n\n"
        '• "What\'s the fastest way to clear the cutoff?"\n'
        '• "I have only 20 days — what\'s my plan?"\n'
        '• "I am BC — how far am I from the cutoff?"\n'
        '• "What are my weak areas?"\n'
        '• "What\'s on my plan today?"\n'
        '• "How did my last mock test go?"\n'
        '• "How\'s my PYQ practice going?"\n'
        '• "What\'s my topic mastery?"\n'
        '• "How close am I to the cutoff?"\n'
        '• "What\'s my target exam and study plan?"\n'
        '• "What career does this post lead to?"\n\n'
        "I only answer from your actual PrepGraph activity — not general web knowledge — so the more you've practiced, the more specific I can be.";
  }

  Future<String> _strategyMessage(String userId) async {
    User? user;
    (await _profile.getProfile(userId: userId)).fold((_) {}, (u) => user = u);
    final examId = user?.examId;
    if (examId == null) {
      return "You haven't selected a target exam yet — set it in Profile Setup and I can give you a real ranked study plan.";
    }

    final recommendations = (await _strategy.getNextBestTopics(userId: userId, examId: examId, category: 'OC', limit: 3))
        .fold((_) => null, (list) => list);
    if (recommendations == null || recommendations.isEmpty) {
      return "I don't have enough PYQ/mastery data yet to rank topics for you — attempt a few PYQ questions first, then ask me again.";
    }

    final top = recommendations.first;
    final buffer = StringBuffer(
      'Based on real PYQ frequency and your current mastery, the fastest lever right now is ${top.topicName}: ${top.reason}',
    );
    if (recommendations.length > 1) {
      final rest = recommendations.skip(1).map((r) => r.topicName).join(', ');
      buffer.write('\n\nAfter that: $rest.');
    }
    buffer.write('\n\nSee the full ranked list and roadmap in My Strategy on your Dashboard.');
    return buffer.toString();
  }

  Future<String> _categoryMessage(String userId, String category) async {
    User? user;
    (await _profile.getProfile(userId: userId)).fold((_) {}, (u) => user = u);
    final examId = user?.examId;
    if (examId == null) {
      return "You haven't selected a target exam yet — set it in Profile Setup so I can compare you against the $category cutoff.";
    }

    final prediction = (await _cutoff.getReadinessPrediction(userId, examId, category: category))
        .fold((_) => null, (p) => p);
    if (prediction == null) {
      return "I couldn't load $category cutoff data for your exam right now.";
    }

    final gap = prediction.targetCutoff - prediction.predictedScore;
    final gapText = gap <= 0
        ? "you're projected ${gap.abs().toStringAsFixed(1)} marks above the $category cutoff (${prediction.targetCutoff.toStringAsFixed(1)})"
        : "you're projected ${gap.toStringAsFixed(1)} marks below the $category cutoff (${prediction.targetCutoff.toStringAsFixed(1)})";

    return "Comparing you against the $category cutoff specifically (not OC): $gapText, based on your current PrepGraph Score. "
        "${gap > 0 && prediction.weakAreas.isNotEmpty ? 'Closing the gap in ${prediction.weakAreas.first} would help most.' : ''}\n\n"
        'This uses the $category-specific cutoff from Cutoff Intelligence, not a generic OC comparison.';
  }

  Future<String> _timelineMessage(String userId, int days) async {
    User? user;
    (await _profile.getProfile(userId: userId)).fold((_) {}, (u) => user = u);
    final examId = user?.examId;
    if (examId == null) {
      return "You haven't selected a target exam yet — set it in Profile Setup and I can build a $days-day plan.";
    }

    final capacity = (await _strategy.getStudyCapacity(userId)).fold((_) => null, (c) => c);
    final recommendations = (await _strategy.getNextBestTopics(userId: userId, examId: examId, category: 'OC', limit: 3))
        .fold((_) => <dynamic>[], (list) => list);

    final planStyle = days <= 7 ? 'crash plan' : days <= 30 ? 'focused plan' : 'long-term plan';
    final buffer = StringBuffer('With $days days left, this calls for a $planStyle');
    if (capacity != null && capacity.profile != CapacityProfile.buildingMomentum) {
      buffer.write(' — your study pattern right now reads as "${capacity.profile.label}", so ');
      buffer.write(capacity.profile == CapacityProfile.lowConsistency
          ? 'the highest-leverage change is showing up daily, even for short sessions.'
          : 'stick to your usual rhythm and just tighten the topic focus.');
    } else {
      buffer.write('.');
    }
    if (recommendations.isNotEmpty) {
      buffer.write('\n\nPriority topics for this window: ${recommendations.map((r) => r.topicName).join(', ')}.');
    }
    buffer.write('\n\nOpen My Strategy on your Dashboard for the full day-by-day roadmap.');
    return buffer.toString();
  }

  /// Career-path context for TNPSC Group 2 / 2A — the exam this app
  /// actually tracks. Figures are sourced from public TNPSC-adjacent
  /// reference sites, not scraped live, so they're presented as
  /// approximate and the student is pointed to the official TNPSC
  /// notification for exact, current numbers rather than treating this as
  /// authoritative — the same honesty standard as every other response
  /// here, just for content that can't be computed from local data.
  String _careerGuidanceMessage() {
    return "Some real context on where a Group 2/2A post leads (general reference — always confirm exact figures against the current TNPSC notification, since pay scales and posts do get revised):\n\n"
        "• Typical posts: Assistant Section Officer, Sub-Registrar Grade II, Deputy Commercial Tax Officer, Probation Officer, Municipal Commissioner Grade II, Assistant Inspector of Labour.\n"
        "• Pay range: roughly ₹37,200 – ₹1,17,600/month basic pay, plus DA/HRA under the state pay matrix.\n"
        "• Typical promotion ladder: Assistant → Assistant Section Officer → Section Officer → Under Secretary → Deputy Secretary, through seniority and departmental exams.\n\n"
        "I can't give you exact current-year figures with confidence — those change with each notification. For the authoritative numbers, check the latest TNPSC notification directly at tnpsc.gov.in before making a decision based on pay.\n\n"
        "What I *can* help with directly from your real data: your current readiness gap against the cutoff, and which topics would close it fastest — ask me either of those.";
  }

  String _fallbackMessage() {
    return "I'm not sure how to answer that from your PrepGraph data specifically. I can help with your weak areas, today's plan, recent mock test results, PYQ practice, topic mastery, cutoff comparison, or your study profile — try asking about one of those, or say \"help\" for examples.";
  }

  Future<String> _weakAreasMessage(String userId) async {
    WeakArea? weakArea;
    String? err;
    (await _insights.getWeakAreas(userId)).fold((f) => err = f.message, (w) => weakArea = w);

    if (weakArea == null) {
      return "I couldn't load your weak-area analysis right now${err != null ? ' ($err)' : ''}.";
    }
    if (weakArea!.weakTopics.isEmpty) {
      return "You don't have enough attempt data yet for me to identify weak topics. Try a few PYQ questions or a mock test, then ask me again.";
    }

    final lines = weakArea!.weakTopics.take(3).map((t) =>
        '• ${t.topicName} (${t.subjectName}) — ${(t.currentAccuracy * 100).toStringAsFixed(0)}% accuracy over ${t.attempts} attempts').join('\n');
    return 'Based on your actual attempt history, your weakest topics right now are:\n\n$lines\n\n'
        "These are pulled straight from your PYQ/mock test accuracy — focus revision time here first.";
  }

  Future<String> _revisionMessage(String userId) async {
    WeakArea? weakArea;
    (await _insights.getWeakAreas(userId)).fold((_) {}, (w) => weakArea = w);

    if (weakArea == null) {
      return "I couldn't load revision suggestions right now.";
    }

    final revisionRecs = weakArea!.recommendations.where((r) => r.type == 'revision').toList();
    if (revisionRecs.isNotEmpty) {
      final lines = revisionRecs.take(3).map((r) => '• ${r.title} — ${r.reason}').join('\n');
      return "Here's what I'd revise first, based on your real activity:\n\n$lines";
    }
    if (weakArea!.weakTopics.isEmpty) {
      return "You don't have enough attempt history yet for me to suggest specific revision topics. Attempt some PYQ questions or a mock test first.";
    }
    final topics = weakArea!.weakTopics.take(3).map((t) => t.topicName).join(', ');
    return 'Based on your accuracy history, good candidates for revision are: $topics.';
  }

  Future<String> _plannerMessage(String userId) async {
    DailyPlan? plan;
    String? err;
    (await _planner.getDailyPlan(userId: userId, date: DateTime.now()))
        .fold((f) => err = f.message, (p) => plan = p);

    if (plan == null) {
      return "I couldn't load today's plan${err != null ? ' ($err)' : ''}.";
    }
    final tasks = plan!.tasks;
    if (tasks.isEmpty) {
      return "You don't have any tasks scheduled for today yet. Open the Planner tab to add one.";
    }
    final pending = tasks.where((t) => t.status != TaskStatus.completed).toList();
    if (pending.isEmpty) {
      return "You've completed all ${tasks.length} of today's planned tasks — nice work! Check the Planner tab if you'd like to add more.";
    }
    final lines = pending.take(5).map((t) => '• ${t.title} (${t.durationMinutes} min)').join('\n');
    return "Here's what's still on today's plan:\n\n$lines\n\n"
        "${pending.length} task${pending.length == 1 ? '' : 's'} left, ${plan!.completedMinutes} of ${plan!.totalStudyMinutes} minutes done so far.";
  }

  Future<String> _mockTestMessage(String userId) async {
    List<MockTestResult>? results;
    String? err;
    (await _mockTest.getTestHistory(userId: userId)).fold((f) => err = f.message, (r) => results = r);

    if (results == null) {
      return "I couldn't load your mock test history${err != null ? ' ($err)' : ''}.";
    }
    if (results!.isEmpty) {
      return "You haven't completed any mock tests yet. Take one from the Mock Tests tab and I can analyze your performance afterward.";
    }

    final latest = results!.first;
    final avgAccuracy =
        results!.map((r) => r.accuracy).reduce((a, b) => a + b) / results!.length;
    final avgPct = (avgAccuracy * 100).toStringAsFixed(0);
    final advice = avgAccuracy < 0.5
        ? "That's below halfway — revisit the topics you got wrong before your next attempt."
        : 'Keep it up — try to beat this on your next attempt.';

    return 'Your most recent mock test: ${latest.correctAnswers}/${latest.totalQuestions} correct '
        '(${(latest.accuracy * 100).toStringAsFixed(0)}% accuracy, '
        '${latest.obtainedMarks.toStringAsFixed(0)}/${latest.totalMarks.toStringAsFixed(0)} marks).\n\n'
        "Across your last ${results!.length} test${results!.length == 1 ? '' : 's'}, your average accuracy is $avgPct%. $advice";
  }

  Future<String> _pyqMessage(String userId) async {
    PyqPerformance? perf;
    String? err;
    (await _insights.getPyqPerformance(userId)).fold((f) => err = f.message, (p) => perf = p);

    if (perf == null) {
      return "I couldn't load your PYQ performance${err != null ? ' ($err)' : ''}.";
    }
    if (perf!.overallStats.totalQuestionsAttempted == 0) {
      return "You haven't attempted any PYQ questions yet. Head to the Practice tab — I can point out weak topics once you've attempted a few.";
    }

    final subjectStats = [...perf!.subjectStats]..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    final focus = subjectStats.isNotEmpty ? subjectStats.first : null;
    final streak = perf!.overallStats.currentStreak;

    final buffer = StringBuffer(
      "You've attempted ${perf!.overallStats.totalQuestionsAttempted} PYQ questions with "
      '${(perf!.overallStats.overallAccuracy * 100).toStringAsFixed(0)}% overall accuracy.',
    );
    if (focus != null) {
      buffer.write(
        '\n\nYour weakest subject is ${focus.subjectName} at ${(focus.accuracy * 100).toStringAsFixed(0)}% — '
        'that\'s a good place to focus next.',
      );
    }
    if (streak > 0) {
      buffer.write('\n\nYou\'re on a $streak-day PYQ practice streak.');
    }
    return buffer.toString();
  }

  Future<String> _masteryMessage(String userId) async {
    MasteryAnalytics? analytics;
    String? err;
    (await _insights.getMasteryAnalytics(userId)).fold((f) => err = f.message, (a) => analytics = a);

    if (analytics == null) {
      return "I couldn't load your topic mastery data${err != null ? ' ($err)' : ''}.";
    }
    final masteries = [...analytics!.topicMasteries];
    if (masteries.isEmpty) {
      return "You don't have mastery data yet — mastery builds up as you study topics and attempt questions. Try exploring a topic in the Knowledge Graph.";
    }
    masteries.sort((a, b) => b.masteryPercentage.compareTo(a.masteryPercentage));
    final strongest = masteries.first;
    final weakest = masteries.last;
    return "You've made progress on ${masteries.length} topic${masteries.length == 1 ? '' : 's'}.\n\n"
        'Strongest: ${strongest.topicName} at ${(strongest.masteryPercentage * 100).toStringAsFixed(0)}% mastery.\n'
        'Needs the most work: ${weakest.topicName} at ${(weakest.masteryPercentage * 100).toStringAsFixed(0)}%.';
  }

  Future<String> _cutoffMessage(String userId) async {
    User? user;
    (await _profile.getProfile(userId: userId)).fold((_) {}, (u) => user = u);

    if (user == null) {
      return "I couldn't load your profile to check cutoff data.";
    }
    final examId = user!.examId;
    if (examId == null) {
      return "You haven't selected a target exam yet, so I can't compare you against a cutoff. Set your exam in Profile first.";
    }

    ExamCutoff? examCutoff;
    (await _cutoff.getExamCutoff(examId)).fold((_) {}, (c) => examCutoff = c);
    if (examCutoff == null || examCutoff!.yearlyTrends.isEmpty) {
      return "I don't have historical cutoff data for your selected exam yet — check the Cutoff Intelligence tab directly.";
    }

    LearnerProgress? progress;
    (await _insights.getLearnerProgress(userId)).fold((_) {}, (p) => progress = p);

    final latest = examCutoff!.yearlyTrends.last;
    final buffer = StringBuffer(
      'For ${examCutoff!.examName}, the most recent cutoff data I have is from ${latest.year}: '
      'an average of ${latest.averageCutoff.toStringAsFixed(1)} marks across ${latest.totalVacancies} vacancies.',
    );
    if (progress != null) {
      buffer.write('\n\nYour PrepGraph Score is ${progress!.prepGraphScore.toStringAsFixed(0)}/100 — '
          'a rough comparison, not a certified prediction.');
    }
    buffer.write('\n\nCheck the Cutoff Intelligence tab for the full category-wise breakdown.');
    return buffer.toString();
  }

  Future<String> _profileMessage(String userId) async {
    User? user;
    String? err;
    (await _profile.getProfile(userId: userId)).fold((f) => err = f.message, (u) => user = u);

    if (user == null) {
      return "I couldn't load your profile${err != null ? ' ($err)' : ''}.";
    }
    final u = user!;

    var examName = u.examId ?? 'not set';
    (await _profile.getExams()).fold((_) {}, (exams) {
      final match = exams.where((e) => e.id == u.examId);
      if (match.isNotEmpty) examName = match.first.name;
    });

    final daysLeft = u.targetDate?.difference(DateTime.now()).inDays;
    final lines = <String>[
      'Target exam: $examName',
      if (u.dailyStudyHours != null) 'Daily study goal: ${u.dailyStudyHours} hours',
      if (daysLeft != null)
        (daysLeft > 0
            ? '$daysLeft days remaining until your target date'
            : 'Your target date has passed — consider updating it in Profile'),
      if (u.preparationLevel != null) 'Preparation level: ${u.preparationLevel}',
    ];

    if (lines.length == 1 && u.examId == null) {
      return "Your profile doesn't have exam/study details set yet. Add them from the Profile tab so I can give more specific guidance.";
    }
    return lines.join('\n');
  }

  Future<String> _motivationMessage(String userId) async {
    LearnerProgress? progress;
    (await _insights.getLearnerProgress(userId)).fold((_) {}, (p) => progress = p);
    StudyHabits? habits;
    (await _insights.getStudyHabits(userId)).fold((_) {}, (h) => habits = h);
    final capacity = (await _strategy.getStudyCapacity(userId)).fold((_) => null, (c) => c);

    final pieces = <String>[];
    final streak = habits?.weeklyStats.currentStreak ?? 0;
    if (streak > 0) {
      pieces.add("you're on a $streak-day study streak");
    }
    if (progress != null) {
      pieces.add('your PrepGraph Score is ${progress!.prepGraphScore.toStringAsFixed(0)}/100');
    }

    if (pieces.isEmpty) {
      return "You haven't logged much activity yet, so there's nothing concrete for me to point to — but every session from here builds your record. Start with one small task today.";
    }
    final summary = pieces.join(' and ');
    final capitalized = summary[0].toUpperCase() + summary.substring(1);

    // Respond to the actual pattern the student is in, not a generic
    // pep-talk — this is the same capacity classification My Strategy
    // shows, reused here instead of restated with different wording.
    final capacityLine = capacity == null || capacity.profile == CapacityProfile.buildingMomentum
        ? ''
        : switch (capacity.profile) {
            CapacityProfile.lowConsistency =>
              " Right now your pattern reads as irregular study rather than a knowledge gap — the single highest-leverage thing you can do is show up for a short session today, even 15 minutes, to rebuild the habit.",
            CapacityProfile.needsRevision =>
              " You've genuinely built mastery in what you've covered, but it's fading from lack of revisiting — that's not a motivation problem, it's a scheduling one. A short daily revision block would fix this faster than more new topics.",
            CapacityProfile.weakFoundation =>
              " Both accuracy and coverage are still low, which is completely normal this early — resist the urge to rush to mock tests yet; concept-building now will make everything after this faster.",
            CapacityProfile.examReady =>
              " Your numbers genuinely support this: strong coverage, accuracy, and consistency together. The risk at this stage isn't ability, it's burnout — protect your rest as much as your study time.",
            _ => '',
          };

    return "$capitalized. That's real, earned progress — keep showing up, even for short sessions, and it compounds.$capacityLine";
  }

  // ==================== Structured content (recommendations/insights) ====================

  /// Builds real recommendations from the same weak-area analysis Insights
  /// already computes (Phase 10) — no separate recommendation engine.
  Future<List<AIRecommendation>> buildRecommendations(String userId) async {
    List<Recommendation>? recs;
    (await _insights.getWeakAreas(userId)).fold((_) {}, (w) => recs = w.recommendations);
    if (recs == null) return [];

    return recs!
        .map((r) => AIRecommendation(
              id: r.id,
              title: r.title,
              description: r.description,
              type: _mapRecommendationType(r.type),
              targetModule: r.topicId != null ? 'knowledge_graph' : null,
              targetId: r.topicId,
              priority: (r.priority / 10.0).clamp(0.0, 1.0),
              reason: r.reason,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  RecommendationType _mapRecommendationType(String type) {
    switch (type) {
      case 'revision':
        return RecommendationType.revision;
      case 'practice':
        return RecommendationType.practiceSession;
      case 'learn':
        return RecommendationType.topicFocus;
      default:
        return RecommendationType.studyPlan;
    }
  }

  /// Builds real insights from mastery/weak-area/study-habit data. Returns
  /// only the categories that have real data behind them (an empty list
  /// when the learner has no activity yet, rather than fabricated filler).
  Future<List<AIInsight>> buildInsights(String userId) async {
    final now = DateTime.now();
    final insights = <AIInsight>[];

    (await _insights.getMasteryAnalytics(userId)).fold((_) {}, (analytics) {
      if (analytics.topicMasteries.isEmpty) return;
      final sorted = [...analytics.topicMasteries]
        ..sort((a, b) => b.masteryPercentage.compareTo(a.masteryPercentage));
      final strongest = sorted.first;
      if (strongest.masteryPercentage <= 0) return;
      insights.add(AIInsight(
        id: 'insight-strength-${strongest.topicId}',
        userId: userId,
        title: 'Strong in ${strongest.topicName}',
        insight:
            'You have ${(strongest.masteryPercentage * 100).toStringAsFixed(0)}% mastery in '
            '${strongest.topicName} (${strongest.subjectName}), your strongest tracked topic.',
        category: InsightCategory.strength,
        relatedTopics: [strongest.topicId],
        suggestedActions: const [
          'Keep reinforcing this topic with periodic revision',
          'Use it as a confidence base for related topics',
        ],
        createdAt: now,
      ));
    });

    (await _insights.getWeakAreas(userId)).fold((_) {}, (weakArea) {
      if (weakArea.weakTopics.isEmpty) return;
      final weakest = weakArea.weakTopics.first;
      insights.add(AIInsight(
        id: 'insight-weakness-${weakest.topicId}',
        userId: userId,
        title: '${weakest.topicName} needs attention',
        insight: 'Your accuracy in ${weakest.topicName} is '
            '${(weakest.currentAccuracy * 100).toStringAsFixed(0)}% over ${weakest.attempts} attempts, '
            'below your ${(weakest.targetAccuracy * 100).toStringAsFixed(0)}% target.',
        category: InsightCategory.weakness,
        relatedTopics: [weakest.topicId],
        suggestedActions: weakArea.recommendations
            .where((r) => r.topicId == weakest.topicId)
            .map((r) => r.title)
            .toList(),
        createdAt: now,
      ));
    });

    (await _insights.getStudyHabits(userId)).fold((_) {}, (habits) {
      if (habits.weeklyStats.currentStreak <= 0) return;
      insights.add(AIInsight(
        id: 'insight-streak-${habits.weeklyStats.currentStreak}',
        userId: userId,
        title: '${habits.weeklyStats.currentStreak}-day study streak',
        insight: 'You have studied for ${habits.weeklyStats.currentStreak} consecutive days, '
            'averaging ${habits.weeklyStats.averageDailyMinutes} minutes/day this week.',
        category: InsightCategory.trend,
        relatedTopics: const [],
        suggestedActions: const ['Keep the streak going with at least one task per day'],
        createdAt: now,
      ));
    });

    return insights;
  }

  // ==================== Context-aware helpers ====================
  // These back AiAssistantRepository's explain*/analyze*/recommend*
  // methods — real data-driven text, reusing the same repositories as
  // above (Knowledge Graph, PYQ, Mock Test, Resources).

  /// Explains a topic using the real Knowledge Graph aggregation (Phase
  /// RC-1): prerequisites, related/next topics, and this user's mastery —
  /// instead of a canned "[Detailed explanation]" placeholder.
  Future<String> explainConceptText({required String topicId, String? userId}) async {
    TopicDetail? detail;
    (await _knowledgeGraph.getTopicDetail(topicId: topicId, userId: userId))
        .fold((_) {}, (d) => detail = d);
    if (detail == null) {
      return "I don't have Knowledge Graph data for this topic yet.";
    }
    final topicDetail = detail!;

    final node = topicDetail.node;
    final buffer = StringBuffer('${node.name}\n\n');
    buffer.write('Your mastery: ${(node.masteryPercentage * 100).toStringAsFixed(0)}%.\n');
    if (topicDetail.prerequisites.isNotEmpty) {
      buffer.write(
          '\nPrerequisites: ${topicDetail.prerequisites.map((t) => t.topicName).join(', ')}.');
    }
    if (topicDetail.relatedTopics.isNotEmpty) {
      buffer.write(
          '\nRelated topics: ${topicDetail.relatedTopics.map((t) => t.topicName).join(', ')}.');
    }
    if (topicDetail.nextTopics.isNotEmpty) {
      buffer.write('\nGood next step: ${topicDetail.nextTopics.map((t) => t.topicName).join(', ')}.');
    }
    buffer.write(
        '\n\n${topicDetail.pyqCount} PYQ question${topicDetail.pyqCount == 1 ? '' : 's'} and '
        '${topicDetail.resourceCount} resource${topicDetail.resourceCount == 1 ? '' : 's'} available for this topic.');
    return buffer.toString();
  }

  /// Reuses PyqRepository.getAiHint (Phase 8's real template-based hints)
  /// rather than a separate, duplicated hint generator.
  Future<String> generateHintText({required String questionId}) async {
    String? hint;
    String? err;
    (await _pyq.getAiHint(questionId: questionId)).fold((f) => err = f.message, (h) => hint = h);
    return hint ?? "I couldn't generate a hint for this question${err != null ? ' ($err)' : ''}.";
  }

  /// Analyzes a specific mock test result, falling back to the user's most
  /// recent test when the exact id isn't found in their real history.
  Future<String> analyzeMistakesText({required String testResultId, required String userId}) async {
    List<MockTestResult>? results;
    (await _mockTest.getTestHistory(userId: userId)).fold((_) {}, (r) => results = r);
    if (results == null || results!.isEmpty) {
      return "You don't have any completed mock tests yet, so there's nothing to analyze.";
    }

    final match = results!.where((r) => r.attemptId == testResultId);
    final result = match.isNotEmpty ? match.first : results!.first;

    return 'Result: ${result.correctAnswers}/${result.totalQuestions} correct '
        '(${(result.accuracy * 100).toStringAsFixed(0)}% accuracy).\n\n'
        '${result.correctAnswers} correct, ${result.incorrectAnswers} incorrect'
        '${result.skippedQuestions > 0 ? ', ${result.skippedQuestions} skipped' : ''}.\n\n'
        '${result.accuracy < 0.5 ? 'Review the topics behind your incorrect answers before your next attempt.' : 'Solid result — keep reinforcing your weaker topics to push this higher.'}';
  }

  /// Explains readiness by comparing the real PrepGraph Score against real
  /// historical cutoff data — the same sources _cutoffMessage uses.
  Future<String> explainReadinessText({required String examId, required String userId}) async {
    LearnerProgress? progress;
    (await _insights.getLearnerProgress(userId)).fold((_) {}, (p) => progress = p);
    ExamCutoff? cutoff;
    (await _cutoff.getExamCutoff(examId)).fold((_) {}, (c) => cutoff = c);

    if (progress == null || cutoff == null || cutoff!.yearlyTrends.isEmpty) {
      return "I don't have enough real data yet to compare your readiness against the cutoff for this exam.";
    }
    final latest = cutoff!.yearlyTrends.last;
    return 'Your PrepGraph Score is ${progress!.prepGraphScore.toStringAsFixed(0)}/100.\n\n'
        'The most recent (${latest.year}) average cutoff for ${cutoff!.examName} was '
        '${latest.averageCutoff.toStringAsFixed(1)} marks.\n\n'
        'This is a rough comparison, not a certified prediction — see the Cutoff Intelligence tab for the full breakdown.';
  }

  /// Recommends real study resources tied to a topic/subject, reusing
  /// ResourceRepository rather than a separate recommendation catalog.
  Future<List<AIRecommendation>> recommendResourcesList({
    required String userId,
    String? topicId,
    String? subjectId,
  }) async {
    List<StudyResource>? resources;
    if (topicId != null) {
      (await _resources.getRelatedResources(topicId)).fold((_) {}, (r) => resources = r);
    } else if (subjectId != null) {
      (await _resources.getResourcesBySubject(subjectId)).fold((_) {}, (r) => resources = r);
    }
    if (resources == null || resources!.isEmpty) return [];

    return resources!
        .map((resource) => AIRecommendation(
              id: 'resource-${resource.id}',
              title: resource.title,
              description: resource.description,
              type: RecommendationType.resource,
              targetModule: 'resources',
              targetId: resource.id,
              priority: (resource.rating / 5.0).clamp(0.0, 1.0),
              reason: 'Matched to your ${topicId != null ? 'topic' : 'subject'} focus',
              createdAt: resource.publishedDate,
            ))
        .toList();
  }
}
