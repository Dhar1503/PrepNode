import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prepnode/core/widgets/bottom_navigation_bar.dart';
import 'package:prepnode/features/auth/presentation/screens/splash_screen.dart';
import 'package:prepnode/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:prepnode/features/auth/presentation/screens/login_screen.dart';
import 'package:prepnode/features/auth/presentation/screens/register_screen.dart';
import 'package:prepnode/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:prepnode/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:prepnode/features/auth/presentation/screens/profile_screen.dart';
import 'package:prepnode/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:prepnode/features/knowledge_graph/presentation/screens/knowledge_graph_home_screen.dart';
import 'package:prepnode/features/knowledge_graph/presentation/screens/topic_list_screen.dart';
import 'package:prepnode/features/knowledge_graph/presentation/screens/topic_detail_screen.dart';
import 'package:prepnode/features/knowledge_graph/presentation/screens/graph_view_screen.dart';
import 'package:prepnode/features/planner/presentation/screens/planner_screen.dart';
import 'package:prepnode/features/strategy/presentation/screens/my_strategy_screen.dart';
import 'package:prepnode/features/settings/presentation/screens/settings_screen.dart';
import 'package:prepnode/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:prepnode/features/pyq/presentation/screens/pyq_home_screen.dart';
import 'package:prepnode/features/pyq/presentation/screens/practice_session_screen.dart';
import 'package:prepnode/features/pyq/presentation/screens/session_summary_screen.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepnode/features/mock_test/presentation/screens/mock_test_home_screen.dart';
import 'package:prepnode/features/mock_test/presentation/screens/test_instructions_screen.dart';
import 'package:prepnode/features/mock_test/presentation/screens/test_interface_screen.dart';
import 'package:prepnode/features/mock_test/presentation/screens/result_screen.dart';
import 'package:prepnode/features/mock_test/presentation/screens/review_screen.dart';
import 'package:prepnode/features/mock_test/presentation/screens/detailed_analysis_screen.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepnode/features/insights/presentation/screens/insights_home_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/mastery_overview_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/score_detail_screen.dart';
import 'package:prepnode/features/cutoff/presentation/screens/cutoff_home_screen.dart';
import 'package:prepnode/features/cutoff/presentation/screens/historical_cutoffs_screen.dart';
import 'package:prepnode/features/cutoff/presentation/screens/year_trend_screen.dart';
import 'package:prepnode/features/cutoff/presentation/screens/category_comparison_screen.dart';
import 'package:prepnode/features/cutoff/presentation/screens/readiness_prediction_screen.dart';
import 'package:prepnode/features/cutoff/presentation/screens/recommendation_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/subject_performance_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/study_time_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/pyq_performance_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/mock_test_trends_screen.dart';
import 'package:prepnode/features/insights/presentation/screens/weak_areas_screen.dart';
import 'package:prepnode/features/resources/presentation/screens/resource_home_screen.dart';
import 'package:prepnode/features/resources/presentation/screens/subject_resources_screen.dart';
import 'package:prepnode/features/resources/presentation/screens/resource_detail_screen.dart';
import 'package:prepnode/features/resources/presentation/screens/recommended_resources_screen.dart';
import 'package:prepnode/features/resources/presentation/screens/bookmarked_resources_screen.dart';
import 'package:prepnode/features/resources/presentation/screens/downloads_screen.dart';
import 'package:prepnode/features/ai_assistant/presentation/screens/ai_assistant_home_screen.dart';
import 'package:prepnode/features/ai_assistant/presentation/screens/chat_screen.dart';
import 'package:prepnode/features/ai_assistant/presentation/screens/conversation_history_screen.dart';
import 'package:prepnode/features/ai_assistant/presentation/screens/doubt_explanation_screen.dart';
import 'package:prepnode/features/ai_assistant/presentation/screens/ai_study_recommendation_screen.dart';
import 'package:prepnode/features/ai_assistant/presentation/screens/ai_revision_recommendation_screen.dart';
import 'package:prepnode/features/roadmap/presentation/screens/roadmap_wizard_screen.dart';
import 'package:prepnode/features/roadmap/presentation/screens/roadmap_timeline_screen.dart';

/// PrepNode GoRouter Configuration
/// Initial routing structure with placeholder routes
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen (S0.1)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Onboarding (S0.2)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Authentication Routes (S0.3-S0.5)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Profile Setup (S1.1-S1.5)
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      // Main App with Bottom Navigation
      // Each branch keeps its own navigation stack, and the shell preserves
      // back-button behavior between tabs instead of exiting the app.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                name: 'learn',
                builder: (context, state) => const KnowledgeGraphHomeScreen(),
                onExit: _exitToHome,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                name: 'practice',
                builder: (context, state) => const PyqHomeScreen(),
                onExit: _exitToHome,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                name: 'insights',
                builder: (context, state) => const InsightsHomeScreen(),
                onExit: _exitToHome,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                onExit: _exitToHome,
              ),
            ],
          ),
        ],
      ),
      // AI Planner Routes (S4.1-S4.4)
      GoRoute(
        path: '/planner',
        name: 'planner',
        builder: (context, state) {
          final addTopicId = state.uri.queryParameters['addTopic'];
          final topicName = state.uri.queryParameters['topicName'];
          return PlannerScreen(addTopicId: addTopicId, addTopicName: topicName);
        },
      ),
      // Strategy Engine — capacity classification, ranked next-best-topics,
      // and roadmap, composed entirely from existing repositories.
      GoRoute(
        path: '/strategy',
        name: 'my-strategy',
        builder: (context, state) => const MyStrategyScreen(),
      ),
      // Settings (S10.4)
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // Reminders — built from Planner tasks + Insights weak areas, see
      // NotificationsScreen's own doc comment for why (no push-notification
      // infrastructure exists in this app).
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      // Adaptive roadmap. Both sit outside the bottom-nav shell: the wizard
      // is a focused flow that should not offer tab-switching midway, and
      // the timeline is a detail view reached from the dashboard card.
      GoRoute(
        path: '/roadmap/setup',
        name: 'roadmapSetup',
        builder: (context, state) => const RoadmapWizardScreen(),
      ),
      GoRoute(
        path: '/roadmap',
        name: 'roadmap',
        builder: (context, state) => const RoadmapTimelineScreen(),
      ),
      // Knowledge Graph Routes (S3.1-S3.4)
      GoRoute(
        path: '/learn/subject/:subjectId',
        name: 'topic-list',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          final subjectName = state.uri.queryParameters['subjectName'] ?? 'Subject';
          return TopicListScreen(
            subjectId: subjectId,
            subjectName: subjectName,
          );
        },
      ),
      GoRoute(
        path: '/learn/topic/:topicId',
        name: 'topic-detail',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          return TopicDetailScreen(topicId: topicId);
        },
      ),
      GoRoute(
        path: '/learn/graph/:topicId',
        name: 'graph-view',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final topicName = state.uri.queryParameters['topicName'] ?? 'Topic';
          return GraphViewScreen(
            topicId: topicId,
            topicName: topicName,
          );
        },
      ),
      // PYQ Practice Routes (S5.1-S5.6)
      GoRoute(
        path: '/practice/session/:sessionId',
        name: 'practice-session',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          // Real sessions (topic practice, retry-incorrect, bookmarked,
          // single search result) are passed in via `extra`; a missing
          // extra (e.g. a direct deep link) has no real questions to show.
          final session = state.extra is PyqSession ? state.extra as PyqSession : null;
          return PracticeSessionScreen(
            sessionId: sessionId,
            questions: session?.questions ?? const [],
            topicName: session?.topicName ?? 'Topic',
          );
        },
      ),
      GoRoute(
        path: '/practice/summary/:sessionId',
        name: 'session-summary',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final session = state.extra is PyqSession
              ? state.extra as PyqSession
              : PyqSession(
                  id: sessionId,
                  userId: '',
                  examId: '',
                  subjectId: '',
                  topicId: '',
                  topicName: 'Topic',
                  mode: SessionMode.batch,
                  questions: const [],
                  currentIndex: 0,
                  startedAt: DateTime.now(),
                );
          return SessionSummaryScreen(session: session);
        },
      ),
      // Mock Test Routes (S6.1-S6.6)
      GoRoute(
        path: '/mock-tests',
        name: 'mock-tests',
        builder: (context, state) => const MockTestHomeScreen(),
      ),
      GoRoute(
        path: '/mock-tests/instructions/:testId',
        name: 'test-instructions',
        builder: (context, state) {
          final testId = state.pathParameters['testId']!;
          // The real test config comes from mockTestsProvider (already
          // loaded by MockTestHomeScreen) via `extra` — a missing extra
          // (e.g. a direct deep link) has no real catalog entry to show,
          // so it falls back to an explicit empty test rather than
          // fabricated numbers.
          final test = state.extra is MockTest
              ? state.extra as MockTest
              : MockTest(
                  id: testId,
                  examId: '',
                  title: 'Test',
                  type: MockTestType.full,
                  durationMinutes: 0,
                  totalQuestions: 0,
                  totalMarks: 0,
                  negativeMarking: 0,
                  sections: const [],
                  subjectIds: const [],
                );
          return TestInstructionsScreen(test: test);
        },
      ),
      GoRoute(
        path: '/mock-tests/test/:attemptId',
        name: 'test-interface',
        builder: (context, state) {
          final attemptId = state.pathParameters['attemptId']!;
          // The real attempt (with its real questions) comes from
          // TestAttemptNotifier.startTest() via `extra` — see the
          // /mock-tests/instructions route above for the same reasoning
          // on a missing extra falling back to an explicit empty attempt
          // (TestInterfaceScreen already renders its own empty state for
          // an attempt with no questions).
          final attempt = state.extra is MockTestAttempt
              ? state.extra as MockTestAttempt
              : MockTestAttempt(
                  id: attemptId,
                  userId: '',
                  testId: '',
                  startedAt: DateTime.now(),
                  questions: const [],
                );
          return TestInterfaceScreen(attempt: attempt);
        },
      ),
      GoRoute(
        path: '/mock-tests/result/:attemptId',
        name: 'test-result',
        builder: (context, state) {
          final attemptId = state.pathParameters['attemptId']!;
          // The real result is computed by TestAttemptNotifier.submitTest()
          // and passed here via `extra`. A missing extra (e.g. a direct
          // deep link with no submitted attempt) has no real data to show,
          // so it falls back to an explicit empty result rather than a
          // fabricated score.
          final result = state.extra is MockTestResult
              ? state.extra as MockTestResult
              : MockTestResult(attemptId: attemptId, testId: '', userId: '');
          return ResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/mock-tests/review/:attemptId',
        name: 'test-review',
        builder: (context, state) {
          final attemptId = state.pathParameters['attemptId']!;
          // Passed from ResultScreen's "Review Answers" button via `extra`
          // (the real submitted result plus the real answered questions,
          // still held in testAttemptProvider at that point) — a missing
          // extra falls back to an explicit empty review rather than
          // fabricated scores/questions.
          final extra = state.extra;
          final result = extra is Map && extra['result'] is MockTestResult
              ? extra['result'] as MockTestResult
              : MockTestResult(attemptId: attemptId, testId: '', userId: '');
          final questions = extra is Map && extra['questions'] is List<MockTestQuestion>
              ? extra['questions'] as List<MockTestQuestion>
              : const <MockTestQuestion>[];
          return ReviewScreen(result: result, questions: questions);
        },
      ),
      GoRoute(
        path: '/mock-tests/analysis/:attemptId',
        name: 'test-analysis',
        builder: (context, state) {
          final attemptId = state.pathParameters['attemptId']!;
          // Passed forward from ResultScreen's "Detailed Analysis" button
          // via `extra`; see the /mock-tests/result route for why a missing
          // extra falls back to an empty (not fabricated) result.
          final result = state.extra is MockTestResult
              ? state.extra as MockTestResult
              : MockTestResult(attemptId: attemptId, testId: '', userId: '');
          return DetailedAnalysisScreen(result: result);
        },
      ),
      // Insights Routes (S8.1-S8.5)
      GoRoute(
        path: '/insights/strength-map',
        name: 'strength-map',
        builder: (context, state) => const MasteryOverviewScreen(),
      ),
      GoRoute(
        path: '/insights/subject/:subjectId',
        name: 'subject-performance',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          return SubjectPerformanceScreen(subjectId: subjectId);
        },
      ),
      GoRoute(
        path: '/insights/time-invested',
        name: 'time-invested',
        builder: (context, state) => const StudyTimeScreen(),
      ),
      GoRoute(
        path: '/insights/pyq-performance',
        name: 'pyq-performance',
        builder: (context, state) => const PyqPerformanceScreen(),
      ),
      GoRoute(
        path: '/insights/mock-test-trends',
        name: 'mock-test-trends',
        builder: (context, state) => const MockTestTrendsScreen(),
      ),
      GoRoute(
        path: '/insights/weak-areas',
        name: 'weak-areas',
        builder: (context, state) => const WeakAreasScreen(),
      ),
      GoRoute(
        path: '/insights/score-detail',
        name: 'score-detail',
        builder: (context, state) => const ScoreDetailScreen(),
      ),
      // Cutoff Intelligence Routes (M7)
      GoRoute(
        path: '/cutoff',
        name: 'cutoff-home',
        builder: (context, state) => const CutoffHomeScreen(),
      ),
      GoRoute(
        path: '/cutoff/:examId',
        name: 'cutoff-detail',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return HistoricalCutoffsScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/cutoff/:examId/trend',
        name: 'cutoff-trend',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return YearTrendScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/cutoff/:examId/category',
        name: 'cutoff-category',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return CategoryComparisonScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/cutoff/:examId/readiness',
        name: 'cutoff-readiness',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return ReadinessPredictionScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/cutoff/:examId/recommendations',
        name: 'cutoff-recommendations',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return RecommendationScreen(examId: examId);
        },
      ),
      // Resources Routes (M9 - S9.1-S9.2)
      GoRoute(
        path: '/resources',
        name: 'resources-home',
        builder: (context, state) => const ResourceHomeScreen(),
      ),
      GoRoute(
        path: '/resources/subject/:subjectId',
        name: 'subject-resources',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          return SubjectResourcesScreen(subjectId: subjectId);
        },
      ),
      GoRoute(
        path: '/resources/:resourceId',
        name: 'resource-detail',
        builder: (context, state) {
          final resourceId = state.pathParameters['resourceId']!;
          return ResourceDetailScreen(resourceId: resourceId);
        },
      ),
      GoRoute(
        path: '/resources/recommended',
        name: 'recommended-resources',
        builder: (context, state) => const RecommendedResourcesScreen(),
      ),
      GoRoute(
        path: '/resources/bookmarks',
        name: 'bookmarked-resources',
        builder: (context, state) => const BookmarkedResourcesScreen(),
      ),
      GoRoute(
        path: '/resources/downloads',
        name: 'downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      // M12 AI Assistant Routes
      GoRoute(
        path: '/ai-assistant',
        name: 'ai-assistant-home',
        builder: (context, state) => const AiAssistantHomeScreen(),
      ),
      GoRoute(
        path: '/ai-assistant/chat',
        name: 'ai-assistant-chat',
        builder: (context, state) {
          final contextModule = state.uri.queryParameters['contextModule'];
          final contextId = state.uri.queryParameters['contextId'];
          return ChatScreen(
            contextModule: contextModule,
            contextId: contextId,
          );
        },
      ),
      GoRoute(
        path: '/ai-assistant/chat/:conversationId',
        name: 'ai-assistant-chat-with-id',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/ai-assistant/history',
        name: 'ai-assistant-history',
        builder: (context, state) => const ConversationHistoryScreen(),
      ),
      GoRoute(
        path: '/ai-assistant/explain',
        name: 'ai-assistant-explain',
        builder: (context, state) {
          final topicId = state.uri.queryParameters['topicId'];
          final questionId = state.uri.queryParameters['questionId'];
          final subjectId = state.uri.queryParameters['subjectId'];
          final moduleId = state.uri.queryParameters['moduleId'];
          final initialQuestion = state.uri.queryParameters['initialQuestion'];
          return DoubtExplanationScreen(
            topicId: topicId,
            questionId: questionId,
            subjectId: subjectId,
            moduleId: moduleId,
            initialQuestion: initialQuestion,
          );
        },
      ),
      GoRoute(
        path: '/ai-assistant/recommendations',
        name: 'ai-assistant-recommendations',
        builder: (context, state) => const AiStudyRecommendationScreen(),
      ),
      GoRoute(
        path: '/ai-assistant/revision',
        name: 'ai-assistant-revision',
        builder: (context, state) => const AiRevisionRecommendationScreen(),
      ),
    ],
  );
}

/// Shell for the 5 bottom-navigation tabs (Home, Learn, Practice, Insights,
/// Profile). Each branch keeps its own navigation stack via
/// [StatefulNavigationShell], so switching tabs preserves history and the
/// Android back button pops naturally instead of exiting the app.
class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Only the Home tab's root is allowed to actually pop (and exit the
      // app) on back. Every other tab's root instead jumps to Home, matching
      // standard Android bottom-nav back behavior. This replaces the old
      // GoRoute.onExit-based approach (see _exitToHome below), which only
      // intercepts GoRouter-driven navigation and is not reliably invoked by
      // the system back button or the predictive-back edge swipe gesture.
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

/// Guards [_exitToHome] against its own redirect re-triggering itself: see
/// that function's doc comment for why this is needed.
bool _allowHomeRedirect = false;

/// Sends the Android back button to Home instead of exiting the app when
/// pressed from the root of a non-Home bottom-navigation branch (Learn,
/// Practice, Insights, Profile).
///
/// GoRouterDelegate.popRoute() falls back to [GoRoute.onExit] only when both
/// the root Navigator and the active shell branch's Navigator report
/// canPop() == false (see go_router's delegate.dart) — which is exactly the
/// case at a branch root, since PopScope's canPop/maybePop path is never
/// reached in that situation.
///
/// Redirecting to Home is not as simple as calling context.go('/home')
/// here: GoRouter's setNewRoutePath() also invokes onExit for every route it
/// considers "exiting", and /learn (etc.) is still the current route right
/// up until that redirect completes. So the redirect's own go() call
/// re-enters this same onExit — and since it unconditionally returned
/// false, the redirect would veto itself forever. [_allowHomeRedirect] marks
/// the one re-entrant call that should be let through.
FutureOr<bool> _exitToHome(BuildContext context) {
  if (_allowHomeRedirect) {
    _allowHomeRedirect = false;
    return true;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      _allowHomeRedirect = true;
      context.go('/home');
    }
  });
  return false;
}


