import 'package:equatable/equatable.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';

/// Represents a resource recommended to a user
class RecommendedResource extends Equatable {
  final String id;
  final String userId;
  final StudyResource resource;
  final String reason; // Why this resource is recommended
  final double relevanceScore; // 0.0 to 1.0
  final DateTime recommendedAt;
  final String? sourceTopicId; // Topic that triggered recommendation
  final String? sourceModule; // 'planner', 'pyq', 'mock_test', etc.

  const RecommendedResource({
    required this.id,
    required this.userId,
    required this.resource,
    required this.reason,
    required this.relevanceScore,
    required this.recommendedAt,
    this.sourceTopicId,
    this.sourceModule,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        resource,
        reason,
        relevanceScore,
        recommendedAt,
        sourceTopicId,
        sourceModule,
      ];
}
