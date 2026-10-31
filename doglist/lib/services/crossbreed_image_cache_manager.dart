import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/crossbreed_models.dart';

/// Shared disk cache for crossbreed thumbnails and originals (separate from the breed-photo cache).
///
/// `stalePeriod` only drives cleanup of unused files; per-file freshness comes from the Hetzner
/// `Cache-Control`/`ETag` headers, so a stale or evicted file is revalidated or redownloaded from the
/// same permanent URL — never regenerated. 804 is a total file cap across both roles.
class CrossbreedImageCacheManager extends CacheManager {
  static const key = 'crossbreedImagesV1';
  static const stalePeriod = Duration(days: 30);
  static const maxNrOfCacheObjects = 804;

  static CrossbreedImageCacheManager? _instance;

  factory CrossbreedImageCacheManager() => _instance ??= CrossbreedImageCacheManager._();

  CrossbreedImageCacheManager._()
      : super(Config(key, stalePeriod: stalePeriod, maxNrOfCacheObjects: maxNrOfCacheObjects));
}

/// Removes both roles of a known hidden/unavailable pair from disk and Flutter's memory image cache.
/// The absolute permanent URL is the cache key, so nothing else needs to be derived.
class CrossbreedMediaCache {
  CrossbreedMediaCache({BaseCacheManager? cacheManager}) : _manager = cacheManager;

  final BaseCacheManager? _manager;

  BaseCacheManager get manager => _manager ?? CrossbreedImageCacheManager();

  Future<void> evict(CrossbreedResult result) async {
    for (final url in [result.thumbnailUrl, result.imageUrl]) {
      try {
        await CachedNetworkImage.evictFromCache(url, cacheKey: url, cacheManager: manager);
      } catch (e) {
        debugPrint('[CrossbreedMediaCache] evict failed: $e');
      }
    }
  }
}
