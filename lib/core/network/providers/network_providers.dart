/// Network Providers
/// Dependency Injection for API services using Riverpod
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/core/network/api_client.dart';
import 'package:prepnode/core/network/secure_storage_service.dart';
import 'package:prepnode/core/network/retry_interceptor.dart';
import 'package:prepnode/features/cutoff/data/datasources/cutoff_remote_datasource.dart';
import 'package:prepnode/features/planner/data/datasources/planner_remote_datasource.dart';
import 'package:prepnode/features/pyq/data/datasources/pyq_remote_datasource.dart';
import 'package:prepnode/features/mock_test/data/datasources/mock_test_remote_datasource.dart';

/// Secure Storage Service Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Retry Interceptor Provider
final retryInterceptorProvider = Provider<RetryInterceptor>((ref) {
  return RetryInterceptor();
});

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final retryInterceptor = ref.watch(retryInterceptorProvider);
  
  return ApiClient(
    secureStorage: secureStorage,
    retryPolicy: retryInterceptor,
    enableLogging: true, // Can be configured based on environment
  );
});

/// Cutoff Remote Data Source Provider
final cutoffRemoteDataSourceProvider = Provider<CutoffRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CutoffRemoteDataSource(apiClient: apiClient);
});

/// Planner Remote Data Source Provider
final plannerRemoteDataSourceProvider = Provider<PlannerRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlannerRemoteDataSource(apiClient: apiClient);
});

/// PYQ Remote Data Source Provider
final pyqRemoteDataSourceProvider = Provider<PyqRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PyqRemoteDataSource(apiClient: apiClient);
});

/// Mock Test Remote Data Source Provider
final mockTestRemoteDataSourceProvider = Provider<MockTestRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MockTestRemoteDataSource(apiClient: apiClient);
});
