import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_filter.freezed.dart';

/// Difficulty level filter options, mirroring the `difficulty` enum in the DB.
enum DifficultyLevel { beginner, intermediate, advanced }

extension DifficultyLevelExt on DifficultyLevel {
  String get label => switch (this) {
        DifficultyLevel.beginner => 'Beginner',
        DifficultyLevel.intermediate => 'Intermediate',
        DifficultyLevel.advanced => 'Advanced',
      };

  String get dbValue => switch (this) {
        DifficultyLevel.beginner => 'beginner',
        DifficultyLevel.intermediate => 'intermediate',
        DifficultyLevel.advanced => 'advanced',
      };
}

/// Encapsulates all filter parameters for the library book search.
@freezed
abstract class BookFilter with _$BookFilter {
  const factory BookFilter({
    /// Full-text search query (matched against title + author with ilike).
    String? query,

    /// Filter to a single category by its UUID.
    String? categoryId,

    /// Filter by difficulty level.
    DifficultyLevel? difficulty,

    /// When true, show only premium-gated books.
    @Default(false) bool premiumOnly,
  }) = _BookFilter;

  /// An empty filter — returns all published books.
  factory BookFilter.empty() => const BookFilter();
}
