import '../dtos/content_dto.dart';

/// Mapping extensions for Content entities (Exam, Subject, Topic, etc.)

extension ExamDtoMapping on ExamDto {
  /// Convert ExamDto to Domain Exam entity (if exists in domain layer)
  // For now, this is a placeholder - adjust based on actual domain entities
  Map<String, dynamic> toDomainMap() {
    return {
      'id': examId,
      'name': examName,
      'description': description,
      'conductingBody': conductingBody,
      'comingSoon': comingSoon,
    };
  }
}

extension SubjectDtoMapping on SubjectDto {
  /// Convert SubjectDto to Domain Subject entity
  Map<String, dynamic> toDomainMap() {
    return {
      'id': subjectId,
      'examId': examId,
      'name': subjectName,
      'importanceWeight': importanceWeight,
    };
  }
}

extension TopicDtoMapping on TopicDto {
  /// Convert TopicDto to Domain Topic entity
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

extension ConceptRelationshipDtoMapping on ConceptRelationshipDto {
  /// Convert ConceptRelationshipDto to Domain entity
  Map<String, dynamic> toDomainMap() {
    return {
      'id': relationId,
      'sourceTopicId': sourceTopicId,
      'targetTopicId': targetTopicId,
      'relationshipType': relationshipType,
    };
  }
}

extension QuestionDtoMapping on QuestionDto {
  /// Convert QuestionDto to Domain Question entity
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
    };
  }
}

extension ResourceDtoMapping on ResourceDto {
  /// Convert ResourceDto to Domain Resource entity
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

extension CutoffDatumDtoMapping on CutoffDatumDto {
  /// Convert CutoffDatumDto to Domain entity
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

/// Reverse mappings from domain to DTO (placeholder structure)
// These would be implemented based on actual domain entity structures
