/// Data Transfer Objects for Content-related entities
/// Exams, Subjects, Topics, Questions, Resources
library;

class ExamDto {
  final String examId;
  final String examName;
  final String? description;
  final String? conductingBody;
  final bool comingSoon;
  final DateTime createdAt;

  ExamDto({
    required this.examId,
    required this.examName,
    this.description,
    this.conductingBody,
    required this.comingSoon,
    required this.createdAt,
  });

  factory ExamDto.fromJson(Map<String, dynamic> json) {
    return ExamDto(
      examId: json['examId'] as String,
      examName: json['examName'] as String,
      description: json['description'] as String?,
      conductingBody: json['conductingBody'] as String?,
      comingSoon: json['comingSoon'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'examName': examName,
      'description': description,
      'conductingBody': conductingBody,
      'comingSoon': comingSoon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': examId,
      'name': examName,
      'description': description,
      'conductingBody': conductingBody,
      'comingSoon': comingSoon,
      'createdAt': createdAt,
    };
  }
}

class SubjectDto {
  final String subjectId;
  final String examId;
  final String subjectName;
  final double importanceWeight;

  SubjectDto({
    required this.subjectId,
    required this.examId,
    required this.subjectName,
    required this.importanceWeight,
  });

  factory SubjectDto.fromJson(Map<String, dynamic> json) {
    return SubjectDto(
      subjectId: json['subjectId'] as String,
      examId: json['examId'] as String,
      subjectName: json['subjectName'] as String,
      importanceWeight: (json['importanceWeight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'examId': examId,
      'subjectName': subjectName,
      'importanceWeight': importanceWeight,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': subjectId,
      'examId': examId,
      'name': subjectName,
      'importanceWeight': importanceWeight,
    };
  }
}

class TopicDto {
  final String topicId;
  final String subjectId;
  final String? parentTopicId;
  final String topicName;
  final String difficulty;
  final double importanceScore;

  TopicDto({
    required this.topicId,
    required this.subjectId,
    this.parentTopicId,
    required this.topicName,
    required this.difficulty,
    required this.importanceScore,
  });

  factory TopicDto.fromJson(Map<String, dynamic> json) {
    return TopicDto(
      topicId: json['topicId'] as String,
      subjectId: json['subjectId'] as String,
      parentTopicId: json['parentTopicId'] as String?,
      topicName: json['topicName'] as String,
      difficulty: json['difficulty'] as String? ?? 'medium',
      importanceScore: (json['importanceScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'subjectId': subjectId,
      'parentTopicId': parentTopicId,
      'topicName': topicName,
      'difficulty': difficulty,
      'importanceScore': importanceScore,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': topicId,
      'subjectId': subjectId,
      'parentTopicId': parentTopicId,
      'name': topicName,
      'difficulty': difficulty,
      'importanceScore': importanceScore,
    };
  }
}

class ConceptRelationshipDto {
  final String relationId;
  final String sourceTopicId;
  final String targetTopicId;
  final String relationshipType;

  ConceptRelationshipDto({
    required this.relationId,
    required this.sourceTopicId,
    required this.targetTopicId,
    required this.relationshipType,
  });

  factory ConceptRelationshipDto.fromJson(Map<String, dynamic> json) {
    return ConceptRelationshipDto(
      relationId: json['relationId'] as String,
      sourceTopicId: json['sourceTopicId'] as String,
      targetTopicId: json['targetTopicId'] as String,
      relationshipType: json['relationshipType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relationId': relationId,
      'sourceTopicId': sourceTopicId,
      'targetTopicId': targetTopicId,
      'relationshipType': relationshipType,
    };
  }
}

class QuestionDto {
  final String questionId;
  final String examId;
  final String subjectId;
  final String topicId;
  final int year;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String? explanation;
  final String difficulty;
  final DateTime createdAt;
  // Added Phase 1B — the Drift Questions table gained these in Phase 1A's
  // migration, but nothing at the DTO/seed layer ever set them until now.
  final String language; // 'english' | 'tamil' | 'both'
  final String? source; // e.g. "TNPSC Group 2 2023 Prelims — official paper"
  final String verificationStatus; // 'verified' | 'unverified'

  QuestionDto({
    required this.questionId,
    required this.examId,
    required this.subjectId,
    required this.topicId,
    required this.year,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
    required this.difficulty,
    required this.createdAt,
    this.language = 'english',
    this.source,
    this.verificationStatus = 'unverified',
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    return QuestionDto(
      questionId: json['questionId'] as String,
      examId: json['examId'] as String,
      subjectId: json['subjectId'] as String,
      topicId: json['topicId'] as String,
      year: json['year'] as int,
      questionText: json['questionText'] as String,
      optionA: json['optionA'] as String,
      optionB: json['optionB'] as String,
      optionC: json['optionC'] as String,
      optionD: json['optionD'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'examId': examId,
      'subjectId': subjectId,
      'topicId': topicId,
      'year': year,
      'questionText': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': questionId,
      'examId': examId,
      'subjectId': subjectId,
      'topicId': topicId,
      'year': year,
      'text': questionText,
      'options': [optionA, optionB, optionC, optionD],
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'createdAt': createdAt,
    };
  }
}

class ResourceDto {
  final String resourceId;
  final String topicId;
  final String title;
  final String type;
  final String link;
  final double averageRating;
  final int ratingCount;

  ResourceDto({
    required this.resourceId,
    required this.topicId,
    required this.title,
    required this.type,
    required this.link,
    required this.averageRating,
    required this.ratingCount,
  });

  factory ResourceDto.fromJson(Map<String, dynamic> json) {
    return ResourceDto(
      resourceId: json['resourceId'] as String,
      topicId: json['topicId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      link: json['link'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'topicId': topicId,
      'title': title,
      'type': type,
      'link': link,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': resourceId,
      'topicId': topicId,
      'title': title,
      'type': type,
      'link': link,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }
}

/// Full resource catalog DTO — Phase 1A. Replaces [ResourceDto]/
/// `SeedData.getResources()` as the seed source for the `resources` table:
/// that older seed used topicIds like 'topic-fundamental-rights' that don't
/// match any real seeded Topics row (a silent FK mismatch), and the thinner
/// schema couldn't hold the real catalog fields anyway. This DTO matches
/// the schema-v3 Resources table added for the resource-catalog
/// consolidation (see database.dart's migration for why two sources of
/// truth existed).
class ResourceCatalogDto {
  final String resourceId;
  final String topicId;
  final String title;
  final String type;
  final String link;
  final double averageRating;
  final int ratingCount;
  final String? description;
  final String? subjectId;
  final String? author;
  final String? difficulty;
  final int viewCount;
  final DateTime? publishedDate;
  final List<String> tags;
  final bool isOfficial;
  final bool isDownloadable;
  final int durationMinutes;
  final int pageCount;
  final String? thumbnailUrl;
  final String? sourceUrl;
  final String language; // 'english' | 'tamil' | 'both'
  final DateTime? verifiedAt;
  final String verificationStatus; // 'verified' | 'unverified'

  ResourceCatalogDto({
    required this.resourceId,
    required this.topicId,
    required this.title,
    required this.type,
    required this.link,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.description,
    this.subjectId,
    this.author,
    this.difficulty,
    this.viewCount = 0,
    this.publishedDate,
    this.tags = const [],
    this.isOfficial = false,
    this.isDownloadable = false,
    this.durationMinutes = 0,
    this.pageCount = 0,
    this.thumbnailUrl,
    this.sourceUrl,
    this.language = 'english',
    this.verifiedAt,
    this.verificationStatus = 'unverified',
  });
}

class ResourceRatingDto {
  final String ratingId;
  final String resourceId;
  final String userId;
  final int rating;
  final DateTime createdAt;

  ResourceRatingDto({
    required this.ratingId,
    required this.resourceId,
    required this.userId,
    required this.rating,
    required this.createdAt,
  });

  factory ResourceRatingDto.fromJson(Map<String, dynamic> json) {
    return ResourceRatingDto(
      ratingId: json['ratingId'] as String,
      resourceId: json['resourceId'] as String,
      userId: json['userId'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratingId': ratingId,
      'resourceId': resourceId,
      'userId': userId,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CutoffDatumDto {
  final String cutoffId;
  final String examId;
  final int year;
  final String category;
  final double cutoffMark;
  final int? vacancyCount;
  // Added Phase 1B — the Drift CutoffData table gained these in Phase 1A
  // (sourceUrl/notificationNumber/verifiedAt) but nothing at the DTO/seed
  // layer ever set them. Every existing seed row defaults to
  // 'unverified'/no source — see getCutoffData's doc comment for why: two
  // genuine attempts to source real official figures both hit only
  // secondary aggregators, one of which directly conflicts with these
  // seed numbers, so neither was used to overwrite the other.
  final String? sourceUrl;
  final String? notificationNumber;
  final DateTime? verifiedAt;
  final String verificationStatus; // 'verified' | 'unverified'

  CutoffDatumDto({
    required this.cutoffId,
    required this.examId,
    required this.year,
    required this.category,
    required this.cutoffMark,
    this.vacancyCount,
    this.sourceUrl,
    this.notificationNumber,
    this.verifiedAt,
    this.verificationStatus = 'unverified',
  });

  factory CutoffDatumDto.fromJson(Map<String, dynamic> json) {
    return CutoffDatumDto(
      cutoffId: json['cutoffId'] as String,
      examId: json['examId'] as String,
      year: json['year'] as int,
      category: json['category'] as String,
      cutoffMark: (json['cutoffMark'] as num).toDouble(),
      vacancyCount: json['vacancyCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cutoffId': cutoffId,
      'examId': examId,
      'year': year,
      'category': category,
      'cutoffMark': cutoffMark,
      'vacancyCount': vacancyCount,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': cutoffId,
      'examId': examId,
      'year': year,
      'category': category,
      'cutoffMark': cutoffMark,
      'vacancyCount': vacancyCount,
    };
  }
}
