import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/widgets/cards/book_card.dart';

part 'featured_content.freezed.dart';

/// A category row shown on the home screen (e.g. "Personal Finance").
class BookCategory {
  const BookCategory({
    required this.id,
    required this.name,
    required this.books,
  });

  final String id;
  final String name;
  final List<Book> books;
}

/// Snapshot of all data required to render the home screen.
///
/// Fetched once per session refresh — individual sections can be updated
/// independently via the notifier.
@freezed
abstract class FeaturedContent with _$FeaturedContent {
  const factory FeaturedContent({
    /// The single hero book displayed in the full-width banner.
    required Book featuredBook,

    /// All content categories with their books pre-loaded.
    required List<BookCategory> categories,

    /// Books the user has started but not finished (sorted by last-opened).
    required List<Book> continueReading,

    /// Recently added books across all categories.
    required List<Book> newBooks,
  }) = _FeaturedContent;
}
