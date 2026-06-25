import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/home_data_source.dart';
import '../../data/models/featured_content.dart';
import '../../data/repositories/home_repository_impl.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final _homeDataSourceProvider = Provider<HomeDataSource>(
  (ref) => HomeDataSource(ref.watch(supabaseClientProvider)),
  name: '_homeDataSourceProvider',
);

final homeRepositoryProvider = Provider<HomeRepositoryImpl>(
  (ref) => HomeRepositoryImpl(ref.watch(_homeDataSourceProvider)),
  name: 'homeRepositoryProvider',
);

// ---------------------------------------------------------------------------
// Home notifier
// ---------------------------------------------------------------------------

/// Loads and exposes the featured content for the home screen.
///
/// Auto-disposes when the home tab is no longer mounted. The UI triggers a
/// refresh via [ref.invalidate(homeProvider)] on pull-to-refresh.
class HomeNotifier extends AsyncNotifier<FeaturedContent> {
  @override
  FutureOr<FeaturedContent> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    final userId = ref.watch(currentUserIdProvider);

    // Load featured content and continue-reading in parallel.
    final featured = await repo.fetchFeaturedContent();

    if (userId != null) {
      final continueReading = await repo.fetchContinueReading(userId);
      return featured.copyWith(continueReading: continueReading);
    }

    return featured;
  }

  /// Called by pull-to-refresh. Re-runs [build] from scratch.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, FeaturedContent>(
  HomeNotifier.new,
  name: 'homeProvider',
);
