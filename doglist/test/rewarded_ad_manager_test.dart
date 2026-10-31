import 'package:doglist/services/rewarded_ad_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _FakeAd extends Fake implements RewardedAd {
  @override
  FullScreenContentCallback<RewardedAd>? fullScreenContentCallback;
  OnUserEarnedRewardCallback? _earn;
  int shows = 0;
  bool disposed = false;

  @override
  Future<void> show({required OnUserEarnedRewardCallback onUserEarnedReward}) async {
    shows++;
    _earn = onUserEarnedReward;
  }

  @override
  Future<void> dispose() async => disposed = true;

  void reward() => _earn!(this, RewardItem(1, 'reward'));
  void dismiss() => fullScreenContentCallback!.onAdDismissedFullScreenContent!(this);
  void failToShow() => fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(this, AdError(1, 'test', 'show'));
}

/// Records SDK load requests; the test decides when and how each one completes.
class _Sdk {
  final requests = <RewardedAdLoadCallback>[];

  Future<void> load(String adUnitId, RewardedAdLoadCallback callback) async => requests.add(callback);

  _FakeAd fill(int i) {
    final ad = _FakeAd();
    requests[i].onAdLoaded(ad);
    return ad;
  }

  void noFill(int i) => requests[i].onAdFailedToLoad(LoadAdError(3, 'test', 'no fill', null));
}

void main() {
  final manager = RewardedAdManager();
  late _Sdk sdk;

  setUp(() {
    manager.resetForTesting();
    sdk = _Sdk();
    manager
      ..loader = sdk.load
      ..supportedOverride = true;
  });
  tearDown(manager.resetForTesting);

  RewardedShowOutcome present(RewardedAdPurpose p, List<String> log) => manager.present(
    p,
    onEarned: () => log.add('${p.name}:earned'),
    onDismissed: () => log.add('${p.name}:dismissed'),
    onFailedToShow: () => log.add('${p.name}:failed'),
  );

  test(
    'cold load completes only after onAdLoaded; concurrent callers share one SDK request; warm load is free',
    () async {
      var done = false;
      final first = manager.load(purpose: RewardedAdPurpose.crossbreed)..then((_) => done = true);
      final second = manager.load(purpose: RewardedAdPurpose.crossbreed);
      await Future<void>.delayed(Duration.zero);
      expect(sdk.requests, hasLength(1));
      expect(done, isFalse);
      expect(manager.isReady(RewardedAdPurpose.crossbreed), isFalse);

      sdk.fill(0);
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(await manager.load(purpose: RewardedAdPurpose.crossbreed), isTrue);
      expect(sdk.requests, hasLength(1));
    },
  );

  test('no fill completes false and the next load makes a new request', () async {
    final failed = manager.load(purpose: RewardedAdPurpose.crossbreed);
    await Future<void>.delayed(Duration.zero);
    sdk.noFill(0);
    expect(await failed, isFalse);
    expect(present(RewardedAdPurpose.crossbreed, []), RewardedShowOutcome.notLoaded);

    final retry = manager.load(purpose: RewardedAdPurpose.crossbreed);
    await Future<void>.delayed(Duration.zero);
    expect(sdk.requests, hasLength(2));
    sdk.fill(1);
    expect(await retry, isTrue);
  });

  test('unsupported platforms never call the SDK', () async {
    manager.supportedOverride = false;
    expect(await manager.load(purpose: RewardedAdPurpose.crossbreed), isFalse);
    expect(sdk.requests, isEmpty);
  });

  test('like and crossbreed ads use separate slots and never consume each other', () async {
    final like = manager.load();
    final crossbreed = manager.load(purpose: RewardedAdPurpose.crossbreed);
    await Future<void>.delayed(Duration.zero);
    expect(sdk.requests, hasLength(2));
    final likeAd = sdk.fill(0);
    final crossbreedAd = sdk.fill(1);
    await Future.wait([like, crossbreed]);

    final log = <String>[];
    expect(present(RewardedAdPurpose.crossbreed, log), RewardedShowOutcome.started);
    expect(crossbreedAd.shows, 1);
    expect(likeAd.shows, 0);
    expect(manager.isReady(RewardedAdPurpose.like), isTrue);
    expect(manager.isReady(RewardedAdPurpose.crossbreed), isFalse);
  });

  test('only one ad is on screen: a simultaneous like attempt is busy and keeps its ad', () async {
    final loads = [manager.load(), manager.load(purpose: RewardedAdPurpose.crossbreed)];
    await Future<void>.delayed(Duration.zero);
    final likeAd = sdk.fill(0);
    final crossbreedAd = sdk.fill(1);
    await Future.wait(loads);

    final log = <String>[];
    expect(present(RewardedAdPurpose.crossbreed, log), RewardedShowOutcome.started);
    expect(manager.presenting, RewardedAdPurpose.crossbreed);
    expect(present(RewardedAdPurpose.like, log), RewardedShowOutcome.busy);
    expect(present(RewardedAdPurpose.crossbreed, log), RewardedShowOutcome.busy);
    expect(likeAd.shows, 0);
    expect(manager.isReady(RewardedAdPurpose.like), isTrue);

    crossbreedAd
      ..reward()
      ..dismiss();
    expect(log, ['crossbreed:earned', 'crossbreed:dismissed']);
    expect(crossbreedAd.disposed, isTrue);
    expect(manager.presenting, isNull);
    // Crossbreed ads are loaded on demand, not preloaded after dismissal.
    expect(sdk.requests, hasLength(2));

    expect(present(RewardedAdPurpose.like, log), RewardedShowOutcome.started);
    expect(likeAd.shows, 1);
  });

  test('failure to show releases the lease and disposes the ad; a like ad is preloaded again', () async {
    final loads = [manager.load(), manager.load(purpose: RewardedAdPurpose.crossbreed)];
    await Future<void>.delayed(Duration.zero);
    final likeAd = sdk.fill(0);
    final crossbreedAd = sdk.fill(1);
    await Future.wait(loads);

    final log = <String>[];
    present(RewardedAdPurpose.crossbreed, log);
    crossbreedAd.failToShow();
    expect(log, ['crossbreed:failed']);
    expect(crossbreedAd.disposed, isTrue);
    expect(manager.presenting, isNull);
    expect(sdk.requests, hasLength(2));

    present(RewardedAdPurpose.like, log);
    likeAd.dismiss();
    expect(log.last, 'like:dismissed');
    expect(manager.presenting, isNull);
    expect(sdk.requests, hasLength(3), reason: 'the like slot reloads after its ad closes');
  });

  test('legacy like adapter reports success only for an earned and dismissed ad', () async {
    final results = <bool>[];
    await manager.showAd(results.add);
    expect(results, [false], reason: 'no ad loaded');

    final load = manager.loadAd();
    await Future<void>.delayed(Duration.zero);
    final first = sdk.fill(0);
    await load;
    await manager.showAd(results.add);
    first
      ..reward()
      ..dismiss();
    expect(results, [false, true]);

    final reload = manager.loadAd();
    await Future<void>.delayed(Duration.zero);
    final second = sdk.fill(1);
    await reload;
    await manager.showAd(results.add);
    second.dismiss();
    expect(results, [false, true, false], reason: 'closed without reward');
  });
}
