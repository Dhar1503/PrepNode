import 'package:equatable/equatable.dart';

/// Represents a category for organizing resources
class ResourceCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int resourceCount;
  final String? subjectId; // Optional subject association

  const ResourceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.resourceCount,
    this.subjectId,
  });

  @override
  List<Object?> get props => [id, name, icon, resourceCount, subjectId];
}
