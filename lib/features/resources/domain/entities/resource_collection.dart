import 'package:equatable/equatable.dart';

/// Represents a curated collection of resources
class ResourceCollection extends Equatable {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final List<String> resourceIds;
  final String curator;
  final int totalResources;
  final DateTime createdAt;
  final bool isOfficial;

  const ResourceCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.resourceIds,
    required this.curator,
    required this.totalResources,
    required this.createdAt,
    required this.isOfficial,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        coverImage,
        resourceIds,
        curator,
        totalResources,
        createdAt,
        isOfficial,
      ];
}
