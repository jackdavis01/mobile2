import 'dart:convert';

/// Public crossbreed DTOs (crossbreed-contracts-v1). Parsers are strict about the fields the app
/// relies on (permanent media URLs, dimensions, canonical order) and throw
/// [CrossbreedFormatException] instead of rendering an unexpected shape.

final RegExp _uuidV4 = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

bool isUuidV4(String? value) => value != null && _uuidV4.hasMatch(value);

/// Unsigned UTF-8 byte order, the backend's canonical pair order (lo first).
int compareDogIds(String a, String b) {
  final x = utf8.encode(a);
  final y = utf8.encode(b);
  final n = x.length < y.length ? x.length : y.length;
  for (var i = 0; i < n; i++) {
    if (x[i] != y[i]) return x[i] - y[i];
  }
  return x.length - y.length;
}

List<String> canonicalPair(String a, String b) => compareDogIds(a, b) <= 0 ? [a, b] : [b, a];

class CrossbreedFormatException implements Exception {
  final String message;
  const CrossbreedFormatException(this.message);
  @override
  String toString() => 'CrossbreedFormatException: $message';
}

T _req<T>(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is T) return v;
  throw CrossbreedFormatException('Missing or invalid "$key"');
}

T? _opt<T>(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is T) return v;
  throw CrossbreedFormatException('Invalid "$key"');
}

String _uuid(Map<String, dynamic> json, String key) {
  final v = _req<String>(json, key);
  if (!isUuidV4(v)) throw CrossbreedFormatException('"$key" is not a UUIDv4');
  return v;
}

String? _optUuid(Map<String, dynamic> json, String key) {
  final v = _opt<String>(json, key);
  if (v != null && !isUuidV4(v)) throw CrossbreedFormatException('"$key" is not a UUIDv4');
  return v;
}

List<String> _stringPair(Map<String, dynamic> json, String key) {
  final v = _req<List<dynamic>>(json, key);
  if (v.length != 2 || v.any((e) => e is! String || e.isEmpty)) {
    throw CrossbreedFormatException('"$key" must hold two IDs');
  }
  return List<String>.unmodifiable(v.cast<String>());
}

DateTime _time(Map<String, dynamic> json, String key) {
  final v = DateTime.tryParse(_req<String>(json, key));
  if (v == null || !v.isUtc) throw CrossbreedFormatException('"$key" is not a UTC timestamp');
  return v;
}

int? _optPollSeconds(Map<String, dynamic> json) {
  final v = _opt<int>(json, 'pollAfterSeconds');
  if (v != null && (v < 1 || v > 3600)) throw const CrossbreedFormatException('Invalid pollAfterSeconds');
  return v;
}

String _mediaUrl(Map<String, dynamic> json, String key, String pairId, String file) {
  final raw = _req<String>(json, key);
  final uri = Uri.tryParse(raw);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.userInfo.isNotEmpty ||
      uri.path != '/crossbreeds/$pairId/$file') {
    throw CrossbreedFormatException('"$key" is not a permanent media URL for the pair');
  }
  return raw;
}

enum FulfillmentKind { reused, joined, generated }

enum CrossbreedJobStatus { queued, processing, succeeded, failed }

enum CrossbreedIntentState { created, rewardReported, fulfilled, expired }

enum CrossbreedRewardStatus { none, clientReported, consumed }

E _enum<E extends Enum>(List<E> values, String? wire, String key, {Map<String, E> aliases = const {}}) {
  if (wire == null) throw CrossbreedFormatException('Missing "$key"');
  final alias = aliases[wire];
  if (alias != null) return alias;
  for (final v in values) {
    if (v.name == wire) return v;
  }
  throw CrossbreedFormatException('Unknown $key "$wire"');
}

FulfillmentKind? _optFulfillment(Map<String, dynamic> json) {
  final v = _opt<String>(json, 'fulfillment');
  return v == null ? null : _enum(FulfillmentKind.values, v, 'fulfillment');
}

CrossbreedJobStatus? _optStatus(Map<String, dynamic> json) {
  final v = _opt<String>(json, 'status');
  return v == null ? null : _enum(CrossbreedJobStatus.values, v, 'status');
}

CrossbreedRewardStatus _rewardStatus(String? wire) => _enum(CrossbreedRewardStatus.values, wire, 'rewardStatus',
    aliases: const {'client_reported': CrossbreedRewardStatus.clientReported});

class CrossbreedResultSource {
  final String dogId;
  final String breedName;
  final String sha256;
  final String catalogVersion;

  const CrossbreedResultSource({
    required this.dogId,
    required this.breedName,
    required this.sha256,
    required this.catalogVersion,
  });

  factory CrossbreedResultSource.fromJson(Map<String, dynamic> json) => CrossbreedResultSource(
        dogId: _req<String>(json, 'dogId'),
        breedName: _req<String>(json, 'breedName'),
        sha256: _req<String>(json, 'sha256'),
        catalogVersion: _req<String>(json, 'catalogVersion'),
      );
}

/// A published crossbreed image pair. Image bytes come directly from the permanent Hetzner URLs.
class CrossbreedResult {
  static const int originalSize = 1024;
  static const int thumbnailSize = 256;

  final String pairId;
  final String generationId;
  final List<String> dogIds;
  final List<String> breedNames;
  final String imageUrl;
  final String thumbnailUrl;
  final int imageWidth;
  final int imageHeight;
  final int thumbnailWidth;
  final int thumbnailHeight;
  final bool aiGenerated;
  final List<CrossbreedResultSource> sources;
  final DateTime createdAt;
  final DateTime completedAt;

  const CrossbreedResult({
    required this.pairId,
    required this.generationId,
    required this.dogIds,
    required this.breedNames,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.aiGenerated,
    required this.sources,
    required this.createdAt,
    required this.completedAt,
  });

  factory CrossbreedResult.fromJson(Map<String, dynamic> json) {
    // Media URLs are permanent; an expiry field means signed/expiring media, which must not be cached.
    if (json.containsKey('mediaExpiresAt') || json.containsKey('expiresAt')) {
      throw const CrossbreedFormatException('Result media must not expire');
    }
    final pairId = _uuid(json, 'pairId');
    final dogIds = _stringPair(json, 'dogIds');
    if (compareDogIds(dogIds[0], dogIds[1]) >= 0) {
      throw const CrossbreedFormatException('dogIds are not two distinct IDs in canonical order');
    }
    final result = CrossbreedResult(
      pairId: pairId,
      generationId: _uuid(json, 'generationId'),
      dogIds: dogIds,
      breedNames: _stringPair(json, 'breedNames'),
      imageUrl: _mediaUrl(json, 'imageUrl', pairId, 'original.png'),
      thumbnailUrl: _mediaUrl(json, 'thumbnailUrl', pairId, 'thumbnail.webp'),
      imageWidth: _req<int>(json, 'imageWidth'),
      imageHeight: _req<int>(json, 'imageHeight'),
      thumbnailWidth: _req<int>(json, 'thumbnailWidth'),
      thumbnailHeight: _req<int>(json, 'thumbnailHeight'),
      aiGenerated: _req<bool>(json, 'aiGenerated'),
      sources: _req<List<dynamic>>(json, 'sources')
          .map((e) => CrossbreedResultSource.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      createdAt: _time(json, 'createdAt'),
      completedAt: _time(json, 'completedAt'),
    );
    if (result.imageWidth != originalSize ||
        result.imageHeight != originalSize ||
        result.thumbnailWidth != thumbnailSize ||
        result.thumbnailHeight != thumbnailSize) {
      throw const CrossbreedFormatException('Unexpected result dimensions');
    }
    if (_req<String>(json, 'imageMimeType') != 'image/png' || _req<String>(json, 'thumbnailMimeType') != 'image/webp') {
      throw const CrossbreedFormatException('Unexpected result MIME types');
    }
    if (!result.aiGenerated) throw const CrossbreedFormatException('Result must be labeled AI-generated');
    return result;
  }
}

class CrossbreedPreviewSource {
  final String dogId;
  final String breedName;
  final bool available;
  final String? imageUrl;
  final int? width;
  final int? height;

  const CrossbreedPreviewSource({
    required this.dogId,
    required this.breedName,
    required this.available,
    this.imageUrl,
    this.width,
    this.height,
  });

  factory CrossbreedPreviewSource.fromJson(Map<String, dynamic> json) => CrossbreedPreviewSource(
        dogId: _req<String>(json, 'dogId'),
        breedName: _req<String>(json, 'breedName'),
        available: _req<bool>(json, 'available'),
        imageUrl: _opt<String>(json, 'imageUrl'),
        width: _opt<int>(json, 'width'),
        height: _opt<int>(json, 'height'),
      );
}

class CrossbreedSourcePreview {
  final String catalogVersion;
  final List<String> requestedDogIds;
  final List<String> dogIds;
  final List<CrossbreedPreviewSource> sources;
  final bool generateAllowed;

  /// Typed reason when [generateAllowed] is false, such as `GENERATION_DISABLED`.
  final String? reason;

  const CrossbreedSourcePreview({
    required this.catalogVersion,
    required this.requestedDogIds,
    required this.dogIds,
    required this.sources,
    required this.generateAllowed,
    this.reason,
  });

  factory CrossbreedSourcePreview.fromJson(Map<String, dynamic> json) {
    final eligibility = _req<Map<String, dynamic>>(json, 'eligibility');
    return CrossbreedSourcePreview(
      catalogVersion: _req<String>(json, 'catalogVersion'),
      requestedDogIds: _stringPair(json, 'requestedDogIds'),
      dogIds: _stringPair(json, 'dogIds'),
      sources: _req<List<dynamic>>(json, 'sources')
          .map((e) => CrossbreedPreviewSource.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      generateAllowed: _req<bool>(eligibility, 'generateAllowed'),
      reason: _opt<String>(eligibility, 'reason'),
    );
  }
}

class CrossbreedInstallation {
  final String installationId;
  final String installationToken;

  const CrossbreedInstallation({required this.installationId, required this.installationToken});

  factory CrossbreedInstallation.fromJson(Map<String, dynamic> json) {
    final token = _req<String>(json, 'installationToken');
    if (token.length < 32 || _req<String>(json, 'tokenType') != 'Bearer') {
      throw const CrossbreedFormatException('Invalid installation token');
    }
    return CrossbreedInstallation(installationId: _uuid(json, 'installationId'), installationToken: token);
  }

  @override
  String toString() => 'CrossbreedInstallation($installationId)';
}

/// Owner-only intent state. A fulfilled mapping (fulfillment, pairId, generationId) is immutable.
class CrossbreedIntent {
  final String intentId;
  final String clientIntentId;
  final List<String> dogIds;
  final List<String> canonicalDogIds;
  final CrossbreedIntentState state;
  final CrossbreedRewardStatus rewardStatus;
  final DateTime expiresAt;
  final FulfillmentKind? fulfillment;
  final String? pairId;
  final String? generationId;
  final CrossbreedJobStatus? status;
  final CrossbreedResult? result;
  final int? pollAfterSeconds;

  const CrossbreedIntent({
    required this.intentId,
    required this.clientIntentId,
    required this.dogIds,
    required this.canonicalDogIds,
    required this.state,
    required this.rewardStatus,
    required this.expiresAt,
    this.fulfillment,
    this.pairId,
    this.generationId,
    this.status,
    this.result,
    this.pollAfterSeconds,
  });

  factory CrossbreedIntent.fromJson(Map<String, dynamic> json) {
    final state = _enum(CrossbreedIntentState.values, _req<String>(json, 'state'), 'state',
        aliases: const {'reward_reported': CrossbreedIntentState.rewardReported});
    final resultJson = _opt<Map<String, dynamic>>(json, 'result');
    final intent = CrossbreedIntent(
      intentId: _uuid(json, 'intentId'),
      clientIntentId: _uuid(json, 'clientIntentId'),
      dogIds: _stringPair(json, 'dogIds'),
      canonicalDogIds: _stringPair(json, 'canonicalDogIds'),
      state: state,
      rewardStatus: _rewardStatus(_req<String>(json, 'rewardStatus')),
      expiresAt: _time(json, 'expiresAt'),
      fulfillment: _optFulfillment(json),
      pairId: _optUuid(json, 'pairId'),
      generationId: _optUuid(json, 'generationId'),
      status: _optStatus(json),
      result: resultJson == null ? null : CrossbreedResult.fromJson(resultJson),
      pollAfterSeconds: _optPollSeconds(json),
    );
    final mapping = [intent.fulfillment, intent.pairId, intent.generationId];
    final mapped = mapping.every((v) => v != null);
    if (!mapped && mapping.any((v) => v != null)) {
      throw const CrossbreedFormatException('Partial fulfillment mapping');
    }
    if ((state == CrossbreedIntentState.fulfilled) != mapped) {
      throw const CrossbreedFormatException('Fulfillment mapping does not match intent state');
    }
    if (intent.status == CrossbreedJobStatus.succeeded && intent.result == null) {
      throw const CrossbreedFormatException('Succeeded intent without result');
    }
    return intent;
  }
}

/// Response of a redeem call: reused (200, result ready) or generated/joined (202, poll the job).
class CrossbreedRedeemResult {
  final String intentId;
  final FulfillmentKind fulfillment;
  final String pairId;
  final String generationId;
  final CrossbreedJobStatus status;
  final CrossbreedResult? result;
  final int? pollAfterSeconds;

  const CrossbreedRedeemResult({
    required this.intentId,
    required this.fulfillment,
    required this.pairId,
    required this.generationId,
    required this.status,
    this.result,
    this.pollAfterSeconds,
  });

  factory CrossbreedRedeemResult.fromJson(Map<String, dynamic> json) {
    final status = _enum(CrossbreedJobStatus.values, _req<String>(json, 'status'), 'status');
    final resultJson = _opt<Map<String, dynamic>>(json, 'result');
    final r = CrossbreedRedeemResult(
      intentId: _uuid(json, 'intentId'),
      fulfillment: _enum(FulfillmentKind.values, _req<String>(json, 'fulfillment'), 'fulfillment'),
      pairId: _uuid(json, 'pairId'),
      generationId: _uuid(json, 'generationId'),
      status: status,
      result: resultJson == null ? null : CrossbreedResult.fromJson(resultJson),
      pollAfterSeconds: _optPollSeconds(json),
    );
    if (status == CrossbreedJobStatus.succeeded && r.result == null) {
      throw const CrossbreedFormatException('Succeeded redeem without result');
    }
    final active = status == CrossbreedJobStatus.queued || status == CrossbreedJobStatus.processing;
    if (active && r.pollAfterSeconds == null) {
      throw const CrossbreedFormatException('Active redeem without pollAfterSeconds');
    }
    return r;
  }
}

class CrossbreedJob {
  final String generationId;
  final String pairId;
  final CrossbreedJobStatus status;
  final CrossbreedResult? result;
  final String? failureCode;
  final int? pollAfterSeconds;

  const CrossbreedJob({
    required this.generationId,
    required this.pairId,
    required this.status,
    this.result,
    this.failureCode,
    this.pollAfterSeconds,
  });

  bool get isActive => status == CrossbreedJobStatus.queued || status == CrossbreedJobStatus.processing;

  factory CrossbreedJob.fromJson(Map<String, dynamic> json) {
    final failure = _opt<Map<String, dynamic>>(json, 'failure');
    final resultJson = _opt<Map<String, dynamic>>(json, 'result');
    final job = CrossbreedJob(
      generationId: _uuid(json, 'generationId'),
      pairId: _uuid(json, 'pairId'),
      status: _enum(CrossbreedJobStatus.values, _req<String>(json, 'status'), 'status'),
      result: resultJson == null ? null : CrossbreedResult.fromJson(resultJson),
      failureCode: failure == null ? null : _req<String>(failure, 'code'),
      pollAfterSeconds: _optPollSeconds(json),
    );
    if (job.status == CrossbreedJobStatus.succeeded && job.result == null) {
      throw const CrossbreedFormatException('Succeeded job without result');
    }
    return job;
  }
}

class CrossbreedGalleryPage {
  final List<CrossbreedResult> items;
  final String? nextCursor;
  final int limit;

  const CrossbreedGalleryPage({required this.items, required this.nextCursor, required this.limit});

  factory CrossbreedGalleryPage.fromJson(Map<String, dynamic> json) {
    final limit = _req<int>(json, 'limit');
    if (limit < 1 || limit > 50) throw const CrossbreedFormatException('Invalid gallery limit');
    return CrossbreedGalleryPage(
      items: _req<List<dynamic>>(json, 'items')
          .map((e) => CrossbreedResult.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      nextCursor: _opt<String>(json, 'nextCursor'),
      limit: limit,
    );
  }
}

/// Safe typed API error. Only the typed code and retry/reward hints are kept; message text and
/// unknown fields are dropped so nothing internal is shown to the user.
class CrossbreedApiException implements Exception {
  /// Client-side codes for failures without a typed backend response.
  static const String network = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String invalidResponse = 'INVALID_RESPONSE';

  final int? httpStatus;
  final String code;
  final int? retryAfterSeconds;
  final CrossbreedRewardStatus? rewardStatus;
  final String? currentCatalogVersion;

  const CrossbreedApiException({
    required this.code,
    this.httpStatus,
    this.retryAfterSeconds,
    this.rewardStatus,
    this.currentCatalogVersion,
  });

  factory CrossbreedApiException.fromResponse(int httpStatus, String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic> && json['error'] is String) {
        final retry = json['retryAfterSeconds'];
        final reward = json['rewardStatus'];
        return CrossbreedApiException(
          httpStatus: httpStatus,
          code: json['error'] as String,
          retryAfterSeconds: retry is int ? retry : null,
          rewardStatus: reward is String ? _rewardStatus(reward) : null,
          currentCatalogVersion: json['currentCatalogVersion'] is String ? json['currentCatalogVersion'] as String : null,
        );
      }
    } on FormatException {
      // fall through
    } on CrossbreedFormatException {
      // fall through
    }
    return CrossbreedApiException(httpStatus: httpStatus, code: httpStatus >= 500 ? 'SERVICE_UNAVAILABLE' : invalidResponse);
  }

  /// The same intent can be retried without another ad.
  bool get canRetryWithoutAd => rewardStatus == CrossbreedRewardStatus.clientReported;

  bool get isTransient =>
      code == network || code == timeout || code == 'SERVICE_UNAVAILABLE' || code == 'RATE_LIMITED' || (httpStatus ?? 0) >= 500;

  @override
  String toString() => 'CrossbreedApiException($httpStatus, $code)';
}
