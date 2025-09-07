import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Net services parameters
class NS {
  static const String apiDogUrl = 'https://jackdavis01.github.io/open-dog-registry-fork/';
  static const int expirationIntervalDays = 1;
  static const String apiDogJsonUrl = '${apiDogUrl}data/v2.json';
  static const String apiDogImagesPage = 'images/';
}

// Create a custom cache manager
class OneDayCacheManager extends CacheManager {
  static const key = 'oneDayCache';
  OneDayCacheManager()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 1),
            maxNrOfCacheObjects: 804,
          ),
        );
}
