/// Total marks per exam — Phase 1B. Previously hardcoded as a bare `200`
/// (wrong) then a bare `300` (correct for Group 2, but still an
/// assumption baked into the call site rather than an exam property).
/// TNPSC exams do not all share one scale — Group 1 (Mains + interview)
/// and Group 4 are structured differently — so this is a lookup keyed by
/// examId, not a single constant, even though only Group 2 is populated
/// right now (the only exam this app's Cutoff/Strategy features actually
/// operate on today).
class ExamScale {
  /// TNPSC Group 2 Prelims: 200 questions (100 Language + 75 General
  /// Studies + 25 Aptitude & Mental Ability) for 300 marks, qualifying
  /// mark 90/300 — verified against multiple independent sources,
  /// Phase 1B. Corrects the earlier incorrect 200-mark assumption.
  static const Map<String, double> _totalMarksByExam = {
    'tnpsc-group2': 300.0,
  };

  /// Falls back to 300 (Group 2's real scale) only because that's the
  /// sole exam this app currently operates on — not a claim that every
  /// TNPSC exam shares it. Add a real entry here before using this for
  /// any other exam.
  static double totalMarksFor(String examId) => _totalMarksByExam[examId] ?? 300.0;

  /// Official minimum qualifying mark, verified alongside the total above.
  ///
  /// This exists so readiness can be measured against a REAL published
  /// figure. It previously benchmarked against `cutoff_data`, whose rows
  /// were never sourced from any TNPSC document — meaning Home, Planner and
  /// the Mock Test result screen were all quoting invented targets at exam
  /// aspirants. The qualifying mark is a lower bar than a real cutoff, so
  /// it must be labelled as such and never called "the cutoff".
  static const Map<String, double> _qualifyingMarkByExam = {
    'tnpsc-group2': 90.0,
  };

  /// Null when no verified qualifying mark is known for the exam — callers
  /// must handle that rather than substituting a guess.
  static double? qualifyingMarkFor(String examId) => _qualifyingMarkByExam[examId];
}
