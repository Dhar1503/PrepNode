import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/progression/data/datasources/progression_local_datasource.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';

final progressionDataSourceProvider = Provider<ProgressionLocalDataSource>((ref) {
  return ProgressionLocalDataSource(
    databaseService: ref.watch(databaseServiceProvider),
  );
});

/// Bumped after any XP award so every progression view re-reads at once.
/// A single token beats invalidating five providers by hand and forgetting
/// one — the classic way a streak widget goes stale while the XP ring moves.
final progressionRevisionProvider = StateProvider<int>((ref) => 0);

/// The signed-in user id, or null. Every provider below returns empty state
/// rather than throwing when it is null, so the dashboard renders during the
/// brief window before the session is restored.
final _userIdProvider = Provider<String?>((ref) {
  final id = ref.watch(authProvider).userId;
  return (id == null || id.isEmpty) ? null : id;
});

final streakProvider = FutureProvider<StreakState>((ref) async {
  ref.watch(progressionRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return const StreakState();
  return ref.watch(progressionDataSourceProvider).getStreak(userId);
});

final xpProvider = FutureProvider<XpState>((ref) async {
  ref.watch(progressionRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return const XpState();
  return ref.watch(progressionDataSourceProvider).getXp(userId);
});

final badgesProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(progressionRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return const [];
  return ref.watch(progressionDataSourceProvider).getBadgeCodes(userId);
});

final dailyChallengeProvider = FutureProvider<Objective?>((ref) async {
  ref.watch(progressionRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return null;
  return ref.watch(progressionDataSourceProvider).getDailyChallenge(userId);
});

final weeklyMissionProvider = FutureProvider<Objective?>((ref) async {
  ref.watch(progressionRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return null;
  return ref.watch(progressionDataSourceProvider).getWeeklyMission(userId);
});

/// The single entry point every feature calls when the user does something
/// that counts as studying.
///
/// Centralising it is what keeps the streak honest: PYQ, mock test, planner
/// and resources all route through here, so there is exactly one definition
/// of "studied today" and one place that awards XP.
class ProgressionRecorder {
  final Ref _ref;

  ProgressionRecorder(this._ref);

  /// Returns the XP awarded (0 if the award was deduplicated).
  Future<int> record(
    StudyActivity activity, {
    String? note,
    String? dedupeKey,
  }) async {
    final userId = _ref.read(_userIdProvider);
    if (userId == null) return 0;

    final awarded = await _ref.read(progressionDataSourceProvider).awardXp(
          userId,
          activity,
          note: note,
          dedupeKey: dedupeKey,
        );

    _ref.read(progressionRevisionProvider.notifier).state++;
    return awarded;
  }
}

final progressionRecorderProvider = Provider<ProgressionRecorder>((ref) {
  return ProgressionRecorder(ref);
});

/// Headline counts for the profile header. Reads existing tables only.
final profileStatsProvider = FutureProvider<({
  int daysStudied,
  int questionsAttempted,
  int topicsExplored,
  int mockTests,
})>((ref) async {
  ref.watch(progressionRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) {
    return (daysStudied: 0, questionsAttempted: 0, topicsExplored: 0, mockTests: 0);
  }
  return ref.watch(progressionDataSourceProvider).getProfileStats(userId);
});
