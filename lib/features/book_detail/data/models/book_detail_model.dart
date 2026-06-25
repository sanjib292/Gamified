import 'package:flutter/material.dart';

import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';

// ---------------------------------------------------------------------------
// LearningPath — plain Dart class (contains List<Lesson> from shared widget)
// ---------------------------------------------------------------------------

class LearningPath {
  const LearningPath({
    required this.id,
    required this.bookId,
    required this.title,
    required this.description,
    required this.displayOrder,
    this.lessons = const [],
  });

  final String id;
  final String bookId;
  final String title;
  final String description;
  final int displayOrder;
  final List<Lesson> lessons;

  LearningPath copyWith({
    String? id,
    String? bookId,
    String? title,
    String? description,
    int? displayOrder,
    List<Lesson>? lessons,
  }) =>
      LearningPath(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        title: title ?? this.title,
        description: description ?? this.description,
        displayOrder: displayOrder ?? this.displayOrder,
        lessons: lessons ?? this.lessons,
      );
}

// ---------------------------------------------------------------------------
// UserProgress
// ---------------------------------------------------------------------------

class UserProgress {
  const UserProgress({
    required this.userId,
    required this.bookId,
    required this.progressPercent,
    required this.completedLessons,
    required this.lastAccessedAt,
  });

  final String userId;
  final String bookId;
  final double progressPercent;
  final int completedLessons;
  final DateTime lastAccessedAt;
}

// ---------------------------------------------------------------------------
// BookDetail — top-level aggregate
// ---------------------------------------------------------------------------

class BookDetail {
  const BookDetail({
    required this.book,
    required this.paths,
    required this.availableAchievements,
    this.userProgress,
    this.completedLessons = 0,
    this.totalLessons = 0,
  });

  final Book book;
  final List<LearningPath> paths;
  final List<Achievement> availableAchievements;
  final UserProgress? userProgress;
  final int completedLessons;
  final int totalLessons;

  BookDetail copyWith({
    Book? book,
    List<LearningPath>? paths,
    List<Achievement>? availableAchievements,
    UserProgress? userProgress,
    int? completedLessons,
    int? totalLessons,
  }) =>
      BookDetail(
        book: book ?? this.book,
        paths: paths ?? this.paths,
        availableAchievements:
            availableAchievements ?? this.availableAchievements,
        userProgress: userProgress ?? this.userProgress,
        completedLessons: completedLessons ?? this.completedLessons,
        totalLessons: totalLessons ?? this.totalLessons,
      );
}

// ---------------------------------------------------------------------------
// Color helper
// ---------------------------------------------------------------------------

Color hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
