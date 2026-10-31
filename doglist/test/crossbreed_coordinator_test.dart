import 'dart:async';
import 'dart:io';

import 'package:doglist/businesslogic/crossbreed_bloc_cubit.dart';
import 'package:doglist/businesslogic/crossbreed_bloc_state.dart';
import 'package:doglist/models/crossbreed_models.dart';
import 'package:doglist/repositories/mock_crossbreed_repository.dart';
import 'package:doglist/services/crossbreed_coordinator.dart';
import 'package:doglist/services/crossbreed_rewarded_ads.dart';
import 'package:doglist/services/rewarded_ad_manager.dart';
import 'package:doglist/services/crossbreed_state_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _load(String path) async => File('test/fixtures/crossbreed/examples/valid/$path').readAsString();

class _CountingRepository extends MockCrossbreedRepository {
  _CountingRepository(MockCrossbreedScenario scenario) : super(load: _load, scenario: scenario);
  int jobPolls = 0;
  int redeems = 0;
  int intents = 0;

  @override
  Future<CrossbreedJob> getJob(String generationId) {
    jobPolls++;
    return super.getJob(generationId);
  }

  @override
  Future<CrossbreedRedeemResult> redeem(
      {required String intentId, required String clientAdAttemptId, required String confirmedCatalogVersion}) {
    redeems++;
    return super.redeem(
        intentId: intentId, clientAdAttemptId: clientAdAttemptId, confirmedCatalogVersion: confirmedCatalogVersion);
  }

  @override
  Future<CrossbreedIntent> createIntent(
      {required String clientIntentId, required List<String> dogIds, required String catalogVersion}) {
    intents++;
    return super.createIntent(clientIntentId: clientIntentId, dogIds: dogIds, catalogVersion: catalogVersion);
  }
}

class _FakeAds implements CrossbreedAdPresenter {
  @override
  bool isSupported = true;
  bool fill = true;
  RewardedShowOutcome outcome = RewardedShowOutcome.started;
  int loads = 0;
  int shows = 0;
  void Function()? onEarned;
  void Function()? onDismissed;
  void Function()? onFailedToShow;

  @override
  Future<bool> ensureLoaded() async {
    loads++;
    return fill;
  }

  @override
  RewardedShowOutcome show(
      {required void Function() onEarned,
      required void Function() onDismissed,
      required void Function() onFailedToShow}) {
    shows++;
    if (outcome == RewardedShowOutcome.started) {
      this.onEarned = onEarned;
      this.onDismissed = onDismissed;
      this.onFailedToShow = onFailedToShow;
    }
    return outcome;
  }
}

const _dogs = ['siberian-husky', 'bulldog'];
const _queued = 'public/job-status-response/queued.json';
const _succeeded = 'public/job-status-response/succeeded.json';

void main() {
  late List<Duration> delays;
  late InMemoryCrossbreedStateStore store;
  late _FakeAds ads;

  CrossbreedCoordinator coordinator(MockCrossbreedRepository repo, {Future<void> Function(Duration)? delay}) =>
      CrossbreedCoordinator(
        repository: repo,
        store: store,
        ads: ads,
        delay: delay ??
            (d) async {
              delays.add(d);
            },
      );

  Future<CrossbreedFlowState> settle(CrossbreedCoordinator c, CrossbreedPhase phase) =>
      c.state.phase == phase ? Future.value(c.state) : c.stream.firstWhere((s) => s.phase == phase);

  Future<void> watchAd(CrossbreedCoordinator c) async {
    await c.watchAd();
    ads.onEarned!();
    ads.onDismissed!();
    await c.drain();
  }

  setUp(() {
    delays = [];
    store = InMemoryCrossbreedStateStore();
    ads = _FakeAds();
  });

  group('state store', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('round-trips the pending command without credentials', () async {
      SharedPreferences.setMockInitialValues({});
      final prefsStore = PrefsCrossbreedStateStore();
      final command = CrossbreedPendingCommand(
        clientIntentId: '0b6c2f4e-8a1d-4c3b-9e7f-5a2d1c0b9e8f',
        displayDogIds: _dogs,
        catalogVersion: 'v1',
        clientAdAttemptId: '1b6c2f4e-8a1d-4c3b-9e7f-5a2d1c0b9e8f',
        createdAt: DateTime.utc(2026, 11, 1),
        intentId: 'i',
        adEarned: true,
        redeemSubmitted: true,
      ).fulfilled(FulfillmentKind.generated, 'p', 'g');
      await prefsStore.save(command);
      final loaded = (await prefsStore.load())!;
      expect(loaded.toJson(), command.toJson());
      expect(loaded.toJson().keys.where((k) => k.toLowerCase().contains('token')), isEmpty);
      await prefsStore.clear();
      expect(await prefsStore.load(), isNull);
    });

    test('fulfilled mapping is immutable', () {
      final command = CrossbreedPendingCommand(
        clientIntentId: '0b6c2f4e-8a1d-4c3b-9e7f-5a2d1c0b9e8f',
        displayDogIds: _dogs,
        catalogVersion: 'v1',
        clientAdAttemptId: '1b6c2f4e-8a1d-4c3b-9e7f-5a2d1c0b9e8f',
        createdAt: DateTime.utc(2026),
      ).fulfilled(FulfillmentKind.generated, 'p', 'g');
      expect(command.fulfilled(FulfillmentKind.generated, 'p', 'g').pairId, 'p');
      expect(() => command.fulfilled(FulfillmentKind.reused, 'p2', 'g2'), throwsA(isA<CrossbreedFormatException>()));
    });
  });

  group('coordinator', () {
    test('generated: waits for earned+dismissed, then polls 3 s with backoff to 15 s', () async {
      final repo = _CountingRepository(const MockCrossbreedScenario(
        redeem: 'public/redeem-response/generated-202.json',
        jobs: [_queued, _queued, _queued, _queued, _queued, _succeeded],
      ));
      final c = coordinator(repo);
      expect(await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1'), isTrue);
      expect(c.state.phase, CrossbreedPhase.awaitingAd);
      await c.watchAd();
      expect(c.state.phase, CrossbreedPhase.showingAd);
      ads.onEarned!();
      await c.drain();
      expect(repo.redeems, 0);
      final done = settle(c, CrossbreedPhase.succeeded);
      ads.onDismissed!();
      final state = await done;
      expect(repo.redeems, 1);
      expect(state.result, isNotNull);
      expect(state.fulfillment, FulfillmentKind.generated);
      expect(delays.map((d) => d.inSeconds), [3, 6, 12, 15, 15, 15]);
      expect(await store.load(), isNull);
      expect(await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1'), isTrue);
    });

    test('reused result completes without polling', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.reused);
      final c = coordinator(repo);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await watchAd(c);
      expect(c.state.phase, CrossbreedPhase.succeeded);
      expect(c.state.fulfillment, FulfillmentKind.reused);
      expect(repo.jobPolls, 0);
    });

    test('second Generate is refused while one is pending', () async {
      final c = coordinator(_CountingRepository(MockCrossbreedScenario.generated));
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      expect(await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1'), isFalse);
    });

    test('ad closed without reward asks for a new ad with a fresh attempt id', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.generated);
      final c = coordinator(repo);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      final attempt = c.pendingCommand!.clientAdAttemptId;
      await c.watchAd();
      final skipped = c.stream.firstWhere((s) => s.errorCode == 'AD_NOT_COMPLETED');
      ads.onDismissed!();
      await skipped;
      expect(delays, [const Duration(seconds: 2)]);
      expect(c.pendingCommand!.clientAdAttemptId, isNot(attempt));
      expect(repo.redeems, 0);
      expect(await c.cancel(), isTrue);
      expect(c.state.phase, CrossbreedPhase.idle);
    });

    test('earned commands cannot be cancelled', () async {
      final c = coordinator(_CountingRepository(MockCrossbreedScenario.generated));
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await c.watchAd();
      expect(await c.cancel(), isFalse, reason: 'ad on screen');
      ads.onEarned!();
      await c.drain();
      expect(await c.cancel(), isFalse);
    });

    test('polling stops in background and resumes on foreground', () async {
      final gates = <Completer<void>>[];
      final repo = _CountingRepository(MockCrossbreedScenario.generated);
      final c = coordinator(repo, delay: (d) {
        delays.add(d);
        final gate = Completer<void>();
        gates.add(gate);
        return gate.future;
      });
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await watchAd(c);
      expect(c.state.phase, CrossbreedPhase.generating);
      c.setForeground(false);
      gates.single.complete();
      await pumpEventQueue();
      expect(repo.jobPolls, 0);
      final done = settle(c, CrossbreedPhase.succeeded);
      c.setForeground(true);
      await pumpEventQueue();
      expect(repo.jobPolls, 1);
      gates.last.complete();
      await done;
      expect(repo.jobPolls, 2);
    });

    test('relaunch recovers the fulfilled command without a new intent or ad', () async {
      final first = _CountingRepository(MockCrossbreedScenario.generated);
      final a = coordinator(first, delay: (_) => Completer<void>().future);
      await a.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await watchAd(a);
      expect(a.state.phase, CrossbreedPhase.generating);
      final persisted = (await store.load())!;
      expect(persisted.generationId, isNotNull);
      await a.dispose();

      final second = _CountingRepository(const MockCrossbreedScenario(
          redeem: 'public/redeem-response/generated-202.json', jobs: [_succeeded]));
      final b = coordinator(second);
      final done = settle(b, CrossbreedPhase.succeeded);
      await b.recover();
      await done;
      expect(second.intents + second.redeems, 0);
      expect(b.state.displayDogIds, _dogs);
    });

    test('transient redeem failure keeps the claim and retries without another ad', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.serviceUnavailable);
      final c = coordinator(repo);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await watchAd(c);
      expect(c.state.phase, CrossbreedPhase.failed);
      expect(c.state.retryable, isTrue);
      final attempt = c.pendingCommand!.clientAdAttemptId;
      repo.scenario = MockCrossbreedScenario.reused;
      await c.recover();
      expect(c.state.phase, CrossbreedPhase.succeeded);
      expect(repo.redeems, 2);
      expect(repo.intents, 1);
      expect(attempt, isNotNull);
    });

    test('REWARDED_AD_REQUIRED keeps the intent but requires a new ad', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.rewardedAdRequired);
      final c = coordinator(repo);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      final attempt = c.pendingCommand!.clientAdAttemptId;
      await watchAd(c);
      expect(c.state.phase, CrossbreedPhase.awaitingAd);
      expect(c.state.needsNewAd, isTrue);
      expect(c.pendingCommand!.clientAdAttemptId, isNot(attempt));
      expect(c.pendingCommand!.adEarned, isFalse);
    });

    test('terminal conflicts and generation failure clear the command', () async {
      for (final scenario in [
        MockCrossbreedScenario.pairUnavailable,
        MockCrossbreedScenario.sourceVersionChanged,
        MockCrossbreedScenario.generationFailed,
      ]) {
        store = InMemoryCrossbreedStateStore();
        final c = coordinator(_CountingRepository(scenario));
        await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
        final done = settle(c, CrossbreedPhase.failed);
        await watchAd(c);
        final state = await done;
        expect(state.needsNewAd, isTrue, reason: '$scenario');
        expect(await store.load(), isNull);
      }
    });

    test('reward reported after dismissal within the grace period still redeems once', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.reused);
      final grace = Completer<void>();
      final c = coordinator(repo, delay: (_) => grace.future);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await c.watchAd();
      ads.onDismissed!();
      await c.drain();
      expect(repo.redeems, 0);
      ads.onEarned!();
      await c.drain();
      grace.complete();
      await pumpEventQueue();
      expect(c.state.phase, CrossbreedPhase.succeeded);
      expect(repo.redeems, 1);
    });

    test('callbacks of an earlier ad attempt are ignored', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.reused);
      final c = coordinator(repo);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await c.watchAd();
      final staleEarned = ads.onEarned!;
      final skipped = c.stream.firstWhere((s) => s.errorCode == 'AD_NOT_COMPLETED');
      ads.onDismissed!();
      await skipped;
      staleEarned();
      await c.drain();
      expect(c.pendingCommand!.adEarned, isFalse);
      expect(repo.redeems, 0);
      await watchAd(c);
      expect(c.state.phase, CrossbreedPhase.succeeded);
      expect(repo.redeems, 1);
    });

    test('no fill, busy or failure to show keeps the intent and offers the ad again', () async {
      final repo = _CountingRepository(MockCrossbreedScenario.reused);
      final c = coordinator(repo);
      await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      ads.fill = false;
      await c.watchAd();
      expect((c.state.phase, c.state.errorCode, ads.shows), (CrossbreedPhase.awaitingAd, 'AD_UNAVAILABLE', 0));
      ads
        ..fill = true
        ..outcome = RewardedShowOutcome.busy;
      await c.watchAd();
      expect((c.state.phase, c.state.errorCode), (CrossbreedPhase.awaitingAd, 'AD_UNAVAILABLE'));
      ads.outcome = RewardedShowOutcome.started;
      await c.watchAd();
      ads.onFailedToShow!();
      await c.drain();
      expect((c.state.phase, c.state.errorCode), (CrossbreedPhase.awaitingAd, 'AD_UNAVAILABLE'));
      expect((repo.intents, repo.redeems), (1, 0));
      await watchAd(c);
      expect(c.state.phase, CrossbreedPhase.succeeded);
    });

    test('unsupported ads disable Generate without creating an intent', () async {
      ads.isSupported = false;
      final repo = _CountingRepository(MockCrossbreedScenario.reused);
      final c = coordinator(repo);
      expect(c.adsSupported, isFalse);
      expect(await c.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1'), isFalse);
      expect(c.state.errorCode, 'ADS_UNSUPPORTED');
      expect(repo.intents, 0);
      expect(await store.load(), isNull);
    });

    test('a saved reward without dismissal resumes after relaunch without another ad', () async {
      final a = coordinator(_CountingRepository(MockCrossbreedScenario.reused));
      await a.startGenerate(displayDogIds: _dogs, catalogVersion: 'v1');
      await a.watchAd();
      ads.onEarned!();
      await a.drain();
      expect((await store.load())!.adEarned, isTrue);
      await a.dispose();

      ads = _FakeAds();
      final second = _CountingRepository(MockCrossbreedScenario.reused);
      final b = coordinator(second);
      await b.recover();
      expect(b.state.phase, CrossbreedPhase.succeeded);
      expect((second.intents, second.redeems, ads.shows), (0, 1, 0));
    });

    test('cubit mirrors the coordinator and closing it keeps the command', () async {
      final c = coordinator(_CountingRepository(MockCrossbreedScenario.generated), delay: (_) => Completer<void>().future);
      final cubit = CrossbreedCubit(coordinator: c);
      expect(await cubit.generate(displayDogIds: _dogs, catalogVersion: 'v1'), isTrue);
      expect(cubit.state.phase, CrossbreedPhase.showingAd);
      await cubit.close();
      ads.onEarned!();
      ads.onDismissed!();
      await c.drain();
      expect(c.state.phase, CrossbreedPhase.generating);
      expect(c.pendingCommand, isNotNull);
    });
  });
}
