/// Cutoff Local Data Source
/// Handles local storage and caching for cutoff intelligence data
library;

import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/cutoff/domain/entities/category_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/yearly_trend.dart';

class CutoffLocalDataSource {
  final DatabaseService _databaseService;

  CutoffLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Build a real ExamCutoff directly from the seeded cutoff_data table —
  /// no live backend exists for this app, and cutoff_data (unlike the
  /// JSON-blob cache this local datasource used to keep, which was never
  /// actually populated) already holds real historical cutoff marks.
  Future<ExamCutoff?> getExamCutoffLocal(String examId) async {
    final db = _databaseService.database;
    final examRow =
        await (db.select(db.exams)..where((e) => e.examId.equals(examId))).getSingleOrNull();
    if (examRow == null) return null;

    final rows = await (db.select(db.cutoffData)..where((c) => c.examId.equals(examId))).get();

    final categoryCutoffs = rows
        .map((r) => CategoryCutoff(
              category: r.category,
              cutoffMark: r.cutoffMark,
              vacancyCount: r.vacancyCount,
              year: r.year,
            ))
        .toList();

    final rowsByYear = <int, List<CategoryCutoff>>{};
    for (final cutoff in categoryCutoffs) {
      rowsByYear.putIfAbsent(cutoff.year, () => []).add(cutoff);
    }

    final averageByYear = {
      for (final entry in rowsByYear.entries)
        entry.key: entry.value.map((c) => c.cutoffMark).reduce((a, b) => a + b) / entry.value.length,
    };
    final averages = averageByYear.values;
    final minAvg = averages.isEmpty ? 0.0 : averages.reduce((a, b) => a < b ? a : b);
    final maxAvg = averages.isEmpty ? 0.0 : averages.reduce((a, b) => a > b ? a : b);
    final avgRange = maxAvg - minAvg;

    final yearlyTrends = rowsByYear.entries.map((entry) {
      final year = entry.key;
      final yearCutoffs = entry.value;
      final averageCutoff = averageByYear[year]!;
      final totalVacancies =
          yearCutoffs.fold<int>(0, (sum, c) => sum + (c.vacancyCount ?? 0));
      // Real historical cutoff marks, normalized against this exam's own
      // observed min/max — not an invented difficulty model. A single-year
      // exam has no range to normalize against, so it's reported neutral.
      final difficultyIndex = avgRange > 0 ? (averageCutoff - minAvg) / avgRange : 0.5;

      return YearlyTrend(
        year: year,
        averageCutoff: averageCutoff,
        totalVacancies: totalVacancies,
        difficultyIndex: difficultyIndex.clamp(0.0, 1.0),
        categoryBreakdown: yearCutoffs,
      );
    }).toList()
      ..sort((a, b) => a.year.compareTo(b.year));

    return ExamCutoff(
      examId: examRow.examId,
      examName: examRow.examName,
      conductingBody: examRow.conductingBody ?? '',
      categoryCutoffs: categoryCutoffs,
      yearlyTrends: yearlyTrends,
    );
  }

  /// All exams that have any local cutoff_data — the seeded, real exam
  /// catalog this app actually has content for.
  Future<List<ExamCutoff>> getAvailableExamsLocal() async {
    final db = _databaseService.database;
    final exams = await db.select(db.exams).get();

    final results = <ExamCutoff>[];
    for (final exam in exams) {
      final cutoff = await getExamCutoffLocal(exam.examId);
      if (cutoff != null && cutoff.categoryCutoffs.isNotEmpty) {
        results.add(cutoff);
      }
    }
    return results;
  }

}
