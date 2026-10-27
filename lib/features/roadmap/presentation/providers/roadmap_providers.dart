import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';
import 'package:prepnode/features/progression/presentation/providers/progression_providers.dart';
import 'package:prepnode/features/roadmap/data/datasources/roadmap_local_datasource.dart';
import 'package:prepnode/features/roadmap/data/services/adaptive_roadmap_engine.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';

final roadmapDataSourceProvider = Provider<RoadmapLocalDataSource>((ref) {
  return RoadmapLocalDataSource(
    databaseService: ref.watch(databaseServiceProvider),
  );
});

/// Bumped whenever the roadmap changes on disk.
final roadmapRevisionProvider = StateProvider<int>((ref) => 0);

final _userIdProvider = Provider<String?>((ref) {
  final id = ref.watch(authProvider).userId;
  return (id == null || id.isEmpty) ? null : id;
});

final roadmapPreferencesProvider =
    FutureProvider<RoadmapPreferences?>((ref) async {
  ref.watch(roadmapRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return null;
  return ref.watch(roadmapDataSourceProvider).getPreferences(userId);
});

/// Whether the wizard still needs to run — drives the dashboard's "build my
/// roadmap" prompt rather than a route guard, so an existing user is never
/// blocked from the rest of the app by a feature they have not opted into.
final hasRoadmapProvider = FutureProvider<bool>((ref) async {
  ref.watch(roadmapRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return false;
  return ref.watch(roadmapDataSourceProvider).hasRoadmap(userId);
});

final roadmapProvider = FutureProvider<Roadmap>((ref) async {
  ref.watch(roadmapRevisionProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return const Roadmap(days: []);
  return ref.watch(roadmapDataSourceProvider).getRoadmap(userId);
});

/// Just today's day, which is what the dashboard card needs.
final todaysRoadmapProvider = FutureProvider<RoadmapDay?>((ref) async {
  final roadmap = await ref.watch(roadmapProvider.future);
  return roadmap.today;
});

/// Actions that mutate the roadmap. Kept as a controller rather than
/// scattered `ref.read` calls so every mutation ends with the same
/// invalidation, and completing a task always awards XP.
class RoadmapController {
  final Ref _ref;

  RoadmapController(this._ref);

  Future<void> generate(RoadmapPreferences preferences) async {
    final source = _ref.read(roadmapDataSourceProvider);
    await source.savePreferences(preferences);
    await source.generateAndSave(preferences);
    _ref.read(roadmapRevisionProvider.notifier).state++;
  }

  /// Completes a roadmap task and awards the XP its kind is worth.
  Future<int> completeTask(String taskId) async {
    final kind = await _ref.read(roadmapDataSourceProvider).completeTask(taskId);
    _ref.read(roadmapRevisionProvider.notifier).state++;
    if (kind == null) return 0;

    final activity = switch (kind) {
      RoadmapTaskKind.pyq => StudyActivity.pyqAnswered,
      RoadmapTaskKind.mock || RoadmapTaskKind.assessment =>
        StudyActivity.mockCompleted,
      RoadmapTaskKind.revision => StudyActivity.revisionDone,
      RoadmapTaskKind.resource => StudyActivity.resourceStudied,
      RoadmapTaskKind.study => StudyActivity.plannerTask,
    };

    return _ref.read(progressionRecorderProvider).record(
          activity,
          note: 'Roadmap task',
          // One award per task, ever — re-completing cannot farm XP.
          dedupeKey: 'roadmap-task-$taskId',
        );
  }

  /// Re-runs the adaptive engine. Returns what changed so the UI can say so.
  Future<AdaptationResult> adapt() async {
    final userId = _ref.read(_userIdProvider);
    if (userId == null) {
      return const AdaptationResult(days: [], changes: []);
    }
    final result = await _ref.read(roadmapDataSourceProvider).adaptRoadmap(userId);
    if (result.didAdapt) {
      _ref.read(roadmapRevisionProvider.notifier).state++;
    }
    return result;
  }
}

final roadmapControllerProvider = Provider<RoadmapController>((ref) {
  return RoadmapController(ref);
});
