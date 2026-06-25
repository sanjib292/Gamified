import '../../../../shared/widgets/cards/book_card.dart';
import '../datasources/home_data_source.dart';
import '../models/featured_content.dart';

/// Concrete repository for home-screen data.
///
/// In this iteration it delegates directly to [HomeDataSource]. As the app
/// grows, caching and offline-first logic belong here.
class HomeRepositoryImpl {
  const HomeRepositoryImpl(this._dataSource);

  final HomeDataSource _dataSource;

  Future<FeaturedContent> fetchFeaturedContent() =>
      _dataSource.fetchFeaturedContent();

  Future<List<Book>> fetchContinueReading(String userId) =>
      _dataSource.fetchContinueReading(userId);
}
