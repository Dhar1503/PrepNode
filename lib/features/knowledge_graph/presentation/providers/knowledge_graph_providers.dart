import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepgraph/core/data/providers/data_providers.dart';
import 'package:prepgraph/core/network/providers/network_providers.dart';
import 'package:prepgraph/features/knowledge_graph/data/datasources/knowledge_graph_local_datasource.dart';
import 'package:prepgraph/features/knowledge_graph/data/datasources/knowledge_graph_remote_datasource.dart';
import 'package:prepgraph/features/knowledge_graph/data/repositories/knowledge_graph_repository_impl.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic_detail.dart';
import 'package:prepgraph/features/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';

/// Knowledge Graph Repository Provider
final knowledgeGraphRepositoryProvider = Provider<KnowledgeGraphRepository>((ref) {
  final remoteDataSource = ref.watch(knowledgeGraphRemoteDataSourceProvider);
  final localDataSource = ref.watch(knowledgeGraphLocalDataSourceProvider);
  return KnowledgeGraphRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final knowledgeGraphRemoteDataSourceProvider =
    Provider<KnowledgeGraphRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KnowledgeGraphRemoteDataSource(apiClient: apiClient);
});

final knowledgeGraphLocalDataSourceProvider =
    Provider<KnowledgeGraphLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return KnowledgeGraphLocalDataSource(databaseService: databaseService);
});

/// Subjects State Provider
class SubjectsState {
  final bool isLoading;
  final String? errorMessage;
  final List<GraphNode> subjects;

  const SubjectsState({
    this.isLoading = true,
    this.errorMessage,
    this.subjects = const [],
  });

  SubjectsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GraphNode>? subjects,
  }) {
    return SubjectsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      subjects: subjects ?? this.subjects,
    );
  }
}

/// Subjects State Notifier
class SubjectsNotifier extends StateNotifier<SubjectsState> {
  final KnowledgeGraphRepository _repository;

  SubjectsNotifier(this._repository) : super(const SubjectsState());

  Future<void> loadSubjects({required String examId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getSubjects(examId: examId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (subjects) {
        state = state.copyWith(
          isLoading: false,
          subjects: subjects,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Subjects Provider
final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>((ref) {
  final repository = ref.watch(knowledgeGraphRepositoryProvider);
  return SubjectsNotifier(repository);
});

/// Topics State Provider
class TopicsState {
  final bool isLoading;
  final String? errorMessage;
  final List<GraphNode> topics;

  const TopicsState({
    this.isLoading = true,
    this.errorMessage,
    this.topics = const [],
  });

  TopicsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GraphNode>? topics,
  }) {
    return TopicsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      topics: topics ?? this.topics,
    );
  }
}

/// Topics State Notifier
class TopicsNotifier extends StateNotifier<TopicsState> {
  final KnowledgeGraphRepository _repository;

  TopicsNotifier(this._repository) : super(const TopicsState());

  Future<void> loadTopics({required String subjectId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getTopics(subjectId: subjectId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (topics) {
        state = state.copyWith(
          isLoading: false,
          topics: topics,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Topics Provider
final topicsProvider = StateNotifierProvider<TopicsNotifier, TopicsState>((ref) {
  final repository = ref.watch(knowledgeGraphRepositoryProvider);
  return TopicsNotifier(repository);
});

/// Topic Detail State Provider
class TopicDetailState {
  final bool isLoading;
  final String? errorMessage;
  final TopicDetail? topicDetail;

  const TopicDetailState({
    this.isLoading = true,
    this.errorMessage,
    this.topicDetail,
  });

  TopicDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    TopicDetail? topicDetail,
  }) {
    return TopicDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      topicDetail: topicDetail ?? this.topicDetail,
    );
  }
}

/// Topic Detail State Notifier
class TopicDetailNotifier extends StateNotifier<TopicDetailState> {
  final KnowledgeGraphRepository _repository;

  TopicDetailNotifier(this._repository) : super(const TopicDetailState());

  Future<void> loadTopicDetail({required String topicId, String? userId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getTopicDetail(topicId: topicId, userId: userId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (topicDetail) {
        state = state.copyWith(
          isLoading: false,
          topicDetail: topicDetail,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Topic Detail Provider
final topicDetailProvider = StateNotifierProvider<TopicDetailNotifier, TopicDetailState>((ref) {
  final repository = ref.watch(knowledgeGraphRepositoryProvider);
  return TopicDetailNotifier(repository);
});

/// Graph Data State Provider
class GraphDataState {
  final bool isLoading;
  final String? errorMessage;
  final GraphData? graphData;

  const GraphDataState({
    this.isLoading = true,
    this.errorMessage,
    this.graphData,
  });

  GraphDataState copyWith({
    bool? isLoading,
    String? errorMessage,
    GraphData? graphData,
  }) {
    return GraphDataState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      graphData: graphData ?? this.graphData,
    );
  }
}

/// Graph Data State Notifier
class GraphDataNotifier extends StateNotifier<GraphDataState> {
  final KnowledgeGraphRepository _repository;

  GraphDataNotifier(this._repository) : super(const GraphDataState());

  Future<void> loadGraphData({required String topicId, int radius = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getTopicGraph(topicId: topicId, radius: radius);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (graphData) {
        state = state.copyWith(
          isLoading: false,
          graphData: graphData,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Graph Data Provider
final graphDataProvider = StateNotifierProvider<GraphDataNotifier, GraphDataState>((ref) {
  final repository = ref.watch(knowledgeGraphRepositoryProvider);
  return GraphDataNotifier(repository);
});

/// Search State Provider
class SearchState {
  final bool isLoading;
  final String? errorMessage;
  final List<GraphNode> results;

  const SearchState({
    this.isLoading = false,
    this.errorMessage,
    this.results = const [],
  });

  SearchState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GraphNode>? results,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      results: results ?? this.results,
    );
  }
}

/// Search State Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final KnowledgeGraphRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> searchTopics({required String query, String? subjectId}) async {
    if (query.isEmpty) {
      state = state.copyWith(results: []);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.searchTopics(query: query, subjectId: subjectId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (results) {
        state = state.copyWith(
          isLoading: false,
          results: results,
        );
      },
    );
  }

  void clearResults() {
    state = state.copyWith(results: []);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Search Provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(knowledgeGraphRepositoryProvider);
  return SearchNotifier(repository);
});
