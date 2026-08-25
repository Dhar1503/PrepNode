import 'package:equatable/equatable.dart';

/// Represents a study resource (PDF, video, book, website, etc.)
class StudyResource extends Equatable {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String url;
  final String? thumbnailUrl;
  final String? subjectId;
  final String? topicId;
  final String author;
  final int durationMinutes; // For videos, null for others
  final int pageCount; // For PDFs, null for others
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final double rating;
  final int viewCount;
  final DateTime publishedDate;
  final List<String> tags;
  final bool isOfficial; // Government/official material
  final bool isDownloadable;
  // Added Phase 1A (production content foundation) — see database.dart's
  // Resources table for why sourceUrl is distinct from url.
  final String? sourceUrl;
  final ResourceLanguage language;
  final DateTime? verifiedAt;
  final VerificationStatus verificationStatus;

  const StudyResource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    required this.subjectId,
    this.topicId,
    required this.author,
    required this.durationMinutes,
    required this.pageCount,
    required this.difficulty,
    required this.rating,
    required this.viewCount,
    required this.publishedDate,
    required this.tags,
    required this.isOfficial,
    required this.isDownloadable,
    this.sourceUrl,
    this.language = ResourceLanguage.english,
    this.verifiedAt,
    this.verificationStatus = VerificationStatus.unverified,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        url,
        thumbnailUrl,
        subjectId,
        topicId,
        author,
        durationMinutes,
        pageCount,
        difficulty,
        rating,
        viewCount,
        publishedDate,
        tags,
        isOfficial,
        isDownloadable,
        sourceUrl,
        language,
        verifiedAt,
        verificationStatus,
      ];
}

enum ResourceLanguage { english, tamil, both }

enum VerificationStatus { verified, unverified }

enum ResourceType {
  pdf,
  book,
  notes,
  youtube,
  website,
  governmentMaterial,
  previousPapers,
}
