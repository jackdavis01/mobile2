import 'package:package_info_plus/package_info_plus.dart';

import '../models/crossbreed_models.dart';
import '../platform/platform_info.dart';
import '../services/crossbreed_api_client.dart';
import '../services/crossbreed_token_store.dart';

/// Crossbreed data access used by the coordinator and pages. Installation ownership is handled
/// inside the implementation; callers never see the bearer token.
abstract class CrossbreedRepository {
  Future<CrossbreedSourcePreview> previewSources(String firstDogId, String secondDogId);

  Future<CrossbreedIntent> createIntent({
    required String clientIntentId,
    required List<String> dogIds,
    required String catalogVersion,
  });

  Future<CrossbreedIntent> getIntent(String intentId);

  Future<CrossbreedRedeemResult> redeem({
    required String intentId,
    required String clientAdAttemptId,
    required String confirmedCatalogVersion,
  });

  Future<CrossbreedJob> getJob(String generationId);

  Future<CrossbreedGalleryPage> listGallery({int? limit, String? cursor, List<String>? dogIds});

  Future<CrossbreedResult> getGalleryItem(String pairId);
}

class ApiCrossbreedRepository implements CrossbreedRepository {
  ApiCrossbreedRepository({
    CrossbreedApiClient? client,
    CrossbreedTokenStore? tokenStore,
    Future<String?> Function()? appVersion,
    String Function()? platform,
  })  : _client = client ?? CrossbreedApiClient(),
        _tokens = tokenStore ?? SecureCrossbreedTokenStore(),
        _appVersion = appVersion ?? _packageVersion,
        _platform = platform ?? _currentPlatform;

  /// App-wide instance so the coordinator, result page and gallery share one installation bootstrap.
  static final ApiCrossbreedRepository shared = ApiCrossbreedRepository();

  final CrossbreedApiClient _client;
  final CrossbreedTokenStore _tokens;
  final Future<String?> Function() _appVersion;
  final String Function() _platform;
  Future<CrossbreedInstallation>? _bootstrap;

  static Future<String?> _packageVersion() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      return null;
    }
  }

  static String _currentPlatform() => PlatformInfo.isIOS ? 'ios' : 'android';

  Future<CrossbreedInstallation> _installation() async {
    final stored = await _tokens.read();
    if (stored != null) return stored;
    // Concurrent callers share one bootstrap request.
    return _bootstrap ??= () async {
      try {
        final version = await _appVersion();
        final created = await _client.createInstallation(
          platform: _platform(),
          appVersion: version == null || version.length > 32 ? null : version,
        );
        await _tokens.write(created);
        return created;
      } finally {
        _bootstrap = null;
      }
    }();
  }

  /// Runs [call] with the stored token. A rejected token is cleared so the next new intent bootstraps
  /// a fresh installation; intents owned by the old installation cannot be recovered.
  Future<T> _owned<T>(Future<T> Function(String token) call) async {
    final installation = await _installation();
    try {
      return await call(installation.installationToken);
    } on CrossbreedApiException catch (e) {
      if (e.code == 'INSTALLATION_UNAUTHORIZED') await _tokens.clear();
      rethrow;
    }
  }

  @override
  Future<CrossbreedSourcePreview> previewSources(String firstDogId, String secondDogId) =>
      _client.previewSources(firstDogId, secondDogId);

  @override
  Future<CrossbreedIntent> createIntent({
    required String clientIntentId,
    required List<String> dogIds,
    required String catalogVersion,
  }) async {
    Future<CrossbreedIntent> create() => _owned((token) => _client.createIntent(
          installationToken: token,
          clientIntentId: clientIntentId,
          dogIds: dogIds,
          catalogVersion: catalogVersion,
        ));
    try {
      return await create();
    } on CrossbreedApiException catch (e) {
      if (e.code != 'INSTALLATION_UNAUTHORIZED') rethrow;
      return create();
    }
  }

  @override
  Future<CrossbreedIntent> getIntent(String intentId) =>
      _owned((token) => _client.getIntent(installationToken: token, intentId: intentId));

  @override
  Future<CrossbreedRedeemResult> redeem({
    required String intentId,
    required String clientAdAttemptId,
    required String confirmedCatalogVersion,
  }) =>
      _owned((token) => _client.redeem(
            installationToken: token,
            intentId: intentId,
            clientAdAttemptId: clientAdAttemptId,
            confirmedCatalogVersion: confirmedCatalogVersion,
          ));

  @override
  Future<CrossbreedJob> getJob(String generationId) =>
      _owned((token) => _client.getJob(installationToken: token, generationId: generationId));

  @override
  Future<CrossbreedGalleryPage> listGallery({int? limit, String? cursor, List<String>? dogIds}) =>
      _client.listGallery(limit: limit, cursor: cursor, dogIds: dogIds);

  @override
  Future<CrossbreedResult> getGalleryItem(String pairId) => _client.getGalleryItem(pairId);
}
