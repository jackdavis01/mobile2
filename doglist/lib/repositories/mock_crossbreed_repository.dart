import 'dart:convert';

import '../models/crossbreed_models.dart';
import 'crossbreed_repository.dart';

/// Loads a contract example by its path relative to `examples/valid/`, e.g.
/// `public/redeem-response/reused-200.json`.
typedef CrossbreedFixtureLoader = Future<String> Function(String relativePath);

/// Offline repository replaying the Part 1 contract examples. A scenario lists the redeem outcome and
/// the job-status sequence; error examples are thrown as [CrossbreedApiException]s.
class MockCrossbreedRepository implements CrossbreedRepository {
  MockCrossbreedRepository({required this.load, MockCrossbreedScenario? scenario})
      : scenario = scenario ?? MockCrossbreedScenario.generated;

  final CrossbreedFixtureLoader load;
  MockCrossbreedScenario scenario;
  int _jobPolls = 0;
  bool _redeemed = false;

  Future<Map<String, dynamic>> _json(String path) async => jsonDecode(await load(path)) as Map<String, dynamic>;

  Future<Map<String, dynamic>> _outcome(String path, int status) async {
    if (path.startsWith('public/error-response/')) {
      throw CrossbreedApiException.fromResponse(status, await load(path));
    }
    return _json(path);
  }

  @override
  Future<CrossbreedSourcePreview> previewSources(String firstDogId, String secondDogId) async =>
      CrossbreedSourcePreview.fromJson(await _json(scenario.sourcePreview));

  @override
  Future<CrossbreedIntent> createIntent({
    required String clientIntentId,
    required List<String> dogIds,
    required String catalogVersion,
  }) async {
    _redeemed = false;
    _jobPolls = 0;
    return CrossbreedIntent.fromJson(await _json('public/intent-response/created.json'));
  }

  @override
  Future<CrossbreedIntent> getIntent(String intentId) async => CrossbreedIntent.fromJson(
      await _json(_redeemed ? scenario.intentAfterRedeem : 'public/intent-response/created.json'));

  @override
  Future<CrossbreedRedeemResult> redeem({
    required String intentId,
    required String clientAdAttemptId,
    required String confirmedCatalogVersion,
  }) async {
    final json = await _outcome(scenario.redeem, scenario.redeemStatus);
    _redeemed = true;
    return CrossbreedRedeemResult.fromJson(json);
  }

  @override
  Future<CrossbreedJob> getJob(String generationId) async {
    final jobs = scenario.jobs;
    final path = jobs[_jobPolls < jobs.length ? _jobPolls : jobs.length - 1];
    _jobPolls++;
    return CrossbreedJob.fromJson(await _json(path));
  }

  @override
  Future<CrossbreedGalleryPage> listGallery({int? limit, String? cursor, List<String>? dogIds}) async =>
      CrossbreedGalleryPage.fromJson(await _json(
          scenario.emptyGallery ? 'public/gallery-list-response/empty.json' : 'public/gallery-list-response/first-page.json'));

  @override
  Future<CrossbreedResult> getGalleryItem(String pairId) async =>
      CrossbreedResult.fromJson(await _json('public/crossbreed-result/bulldog-husky.json'));
}

class MockCrossbreedScenario {
  const MockCrossbreedScenario({
    required this.redeem,
    this.redeemStatus = 200,
    this.jobs = const ['public/job-status-response/succeeded.json'],
    this.intentAfterRedeem = 'public/intent-response/fulfilled-generated-processing.json',
    this.sourcePreview = 'public/source-preview-response/eligible-reversed-selection.json',
    this.emptyGallery = false,
  });

  final String redeem;
  final int redeemStatus;
  final List<String> jobs;
  final String intentAfterRedeem;
  final String sourcePreview;
  final bool emptyGallery;

  static const generated = MockCrossbreedScenario(
    redeem: 'public/redeem-response/generated-202.json',
    jobs: ['public/job-status-response/queued.json', 'public/job-status-response/succeeded.json'],
  );
  static const reused = MockCrossbreedScenario(
    redeem: 'public/redeem-response/reused-200.json',
    intentAfterRedeem: 'public/intent-response/fulfilled-reused.json',
  );
  static const joined = MockCrossbreedScenario(
    redeem: 'public/redeem-response/joined-202.json',
    jobs: ['public/job-status-response/processing-reconciling-internally.json', 'public/job-status-response/succeeded.json'],
  );
  static const generationFailed = MockCrossbreedScenario(
    redeem: 'public/redeem-response/generated-202.json',
    jobs: ['public/job-status-response/failed.json'],
  );
  static const pairUnavailable = MockCrossbreedScenario(redeem: 'public/error-response/pair-unavailable.json', redeemStatus: 409);
  static const rewardedAdRequired =
      MockCrossbreedScenario(redeem: 'public/error-response/rewarded-ad-required.json', redeemStatus: 403);
  static const sourceVersionChanged =
      MockCrossbreedScenario(redeem: 'public/error-response/source-version-changed.json', redeemStatus: 409);
  static const serviceUnavailable = MockCrossbreedScenario(
    redeem: 'public/error-response/service-unavailable.json',
    redeemStatus: 503,
    intentAfterRedeem: 'public/intent-response/reward-reported-unfulfilled.json',
  );
  static const generationDisabled = MockCrossbreedScenario(
    redeem: 'public/redeem-response/reused-200.json',
    sourcePreview: 'public/source-preview-response/generation-disabled.json',
  );
}
