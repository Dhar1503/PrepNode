import 'package:equatable/equatable.dart';

/// Represents a user bookmarked resource
class Bookmark extends Equatable {
  final String id;
  final String userId;
  final String resourceId;
  final DateTime bookmarkedAt;
  final String? notes; // User notes about the resource

  const Bookmark({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.bookmarkedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, resourceId, bookmarkedAt, notes];
}
