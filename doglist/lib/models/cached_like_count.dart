import '../parameters/env_config.dart';

/// Represents a cached like count with expiration.
class CachedLikeCount {
  final int count;
  final DateTime cachedAt;
  final int cacheDurationMinutes;

  CachedLikeCount({
    required this.count,
    required this.cachedAt,
    int? cacheDurationMinutes,
  }) : cacheDurationMinutes = cacheDurationMinutes ?? EnvConfig.likeCacheDurationMinutes;

  /// Check if this cached entry has expired.
  bool isExpired() {
    final now = DateTime.now();
    final expirationTime = cachedAt.add(Duration(minutes: cacheDurationMinutes));
    return now.isAfter(expirationTime);
  }

  /// Get the remaining duration until expiration.
  Duration get remainingDuration {
    final now = DateTime.now();
    final expirationTime = cachedAt.add(Duration(minutes: cacheDurationMinutes));
    final remaining = expirationTime.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  String toString() => 'CachedLikeCount(count: $count, cachedAt: $cachedAt, '
      'expired: ${isExpired()})';
}
