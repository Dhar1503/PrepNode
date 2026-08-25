import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/content_local_datasource.dart';
import '../datasources/practice_local_datasource.dart';
import '../datasources/engagement_local_datasource.dart';
import 'package:prepgraph/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:prepgraph/features/pyq/data/datasources/pyq_local_datasource.dart';
import 'package:prepgraph/features/mock_test/data/datasources/mock_test_local_datasource.dart';
import '../repositories/user_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/practice_repository.dart';
import '../repositories/engagement_repository.dart';
import '../cache/cache_manager.dart';

/// Provider for Database Service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Provider for Cache Manager
final cacheManagerProvider = FutureProvider<CacheManager>((ref) async {
  return await CacheManager.create();
});

/// Provider for User Local Data Source
final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return UserLocalDataSource(database);
});

/// Provider for Content Local Data Source
final contentLocalDataSourceProvider = Provider<ContentLocalDataSource>((ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return ContentLocalDataSource(database);
});

/// Provider for Practice Local Data Source
final practiceLocalDataSourceProvider = Provider<PracticeLocalDataSource>((ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return PracticeLocalDataSource(database);
});

/// Provider for Engagement Local Data Source
final engagementLocalDataSourceProvider = Provider<EngagementLocalDataSource>((ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return EngagementLocalDataSource(database);
});

/// Provider for Planner Local Data Source (features package)
final plannerLocalDataSourceProvider = Provider<PlannerLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return PlannerLocalDataSource(databaseService: databaseService);
});

/// Provider for PYQ Local Data Source
final pyqLocalDataSourceProvider = Provider<PyqLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return PyqLocalDataSource(databaseService: databaseService);
});

/// Provider for Mock Test Local Data Source
final mockTestLocalDataSourceProvider = Provider<MockTestLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return MockTestLocalDataSource(databaseService: databaseService);
});

/// Provider for User Repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepository(localDataSource);
});

/// Provider for Content Repository
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final localDataSource = ref.watch(contentLocalDataSourceProvider);
  return ContentRepository(localDataSource);
});

/// Provider for Practice Repository
final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  final localDataSource = ref.watch(practiceLocalDataSourceProvider);
  return PracticeRepository(localDataSource);
});

/// Provider for Engagement Repository
final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  final localDataSource = ref.watch(engagementLocalDataSourceProvider);
  return EngagementRepository(localDataSource);
});

/// Provider for database initialization
final databaseInitializationProvider = FutureProvider<void>((ref) async {
  final result = await DatabaseService.instance.initialize(seedData: true);
  return result.fold(
    onSuccess: (_) => null,
    onFailure: (failure) => throw Exception('Database initialization failed: $failure'),
  );
});
