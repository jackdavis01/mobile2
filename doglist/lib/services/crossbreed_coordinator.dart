import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../businesslogic/crossbreed_bloc_state.dart';
import '../models/crossbreed_models.dart';
import '../repositories/crossbreed_repository.dart';
import 'crossbreed_ids.dart';
import 'crossbreed_rewarded_ads.dart';
import 'crossbreed_state_store.dart';
import 'rewarded_ad_manager.dart';

/// Owns the single in-flight Generate command. Lives for the whole app session (not tied to a page),
/// persists every step before acting, polls only in the foreground and recovers after resume or relaunch.
class CrossbreedCoordinator with WidgetsBindingObserver {
  CrossbreedCoordinator({
    required CrossbreedRepository repository,
    required CrossbreedStateStore store,
    required CrossbreedAdPresenter ads,
    Future<void> Function(Duration)? delay,
    DateTime Function()? now,
    this.rewardGrace = const Duration(seconds: 2),
  })  : _repo = repository,
        _store = store,
        _ads = ads,
        _delay = delay ?? Future<void>.delayed,
        _now = now ?? DateTime.now;

  static CrossbreedCoordinator? _instance;
  static CrossbreedCoordinator get instance => _instance ??= CrossbreedCoordinator(
      repository: ApiCrossbreedRepository.shared, store: PrefsCrossbreedStateStore(), ads: SdkCrossbreedAdPresenter());

  static const int minPollSeconds = 3;
  static const int maxPollSeconds = 15;
  static const int maxRetryAfterSeconds = 60;

  /// How long a dismissal without reward waits for a late `onUserEarnedReward` of the same attempt.
  final Duration rewardGrace;

  final CrossbreedRepository _repo;
  final CrossbreedStateStore _store;
  final CrossbreedAdPresenter _ads;
  final Future<void> Function(Duration) _delay;
  final DateTime Function() _now;

  final _controller = StreamController<CrossbreedFlowState>.broadcast();
  CrossbreedFlowState _state = CrossbreedFlowState.idle;
  CrossbreedPendingCommand? _command;
  bool _foreground = true;
  bool _restored = false;
  bool _observing = false;
  int _pollGeneration = 0;
  Future<void> _queue = Future.value();

  /// Attempt whose full-screen ad is on screen in this process; recovery waits for its callbacks.
  String? _adInFlight;

  CrossbreedFlowState get state => _state;
  Stream<CrossbreedFlowState> get stream => _controller.stream;
  CrossbreedPendingCommand? get pendingCommand => _command;
  bool get isForeground => _foreground;
  bool get adsSupported => _ads.isSupported;

  void attachLifecycle() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setForeground(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      setForeground(false);
    }
  }

  /// Background stops polling; returning to the foreground resynchronises with the server.
  void setForeground(bool foreground) {
    if (_foreground == foreground) return;
    _foreground = foreground;
    if (foreground) {
      unawaited(recover());
    } else {
      _pollGeneration++;
    }
  }

  Future<T> _serial<T>(Future<T> Function() op) {
    final result = _queue.then((_) => op());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Completes after every operation queued so far (tests).
  @visibleForTesting
  Future<void> drain() => _serial(() async {});

  void _emit(CrossbreedFlowState state) {
    _state = state;
    if (!_controller.isClosed) _controller.add(state);
  }

  CrossbreedFlowState _from(CrossbreedPhase phase,
          {String? errorCode, bool retryable = false, bool needsNewAd = false, int? retryAfterSeconds, CrossbreedResult? result, CrossbreedJobStatus? jobStatus}) =>
      CrossbreedFlowState(
        phase: phase,
        displayDogIds: _command?.displayDogIds ?? _state.displayDogIds,
        fulfillment: _command?.fulfillment ?? _state.fulfillment,
        pairId: _command?.pairId ?? _state.pairId,
        result: result,
        jobStatus: jobStatus,
        errorCode: errorCode,
        retryable: retryable,
        needsNewAd: needsNewAd,
        retryAfterSeconds: retryAfterSeconds,
      );

  Future<void> _save(CrossbreedPendingCommand command) async {
    _command = command;
    await _store.save(command);
  }

  Future<void> _finish(CrossbreedFlowState state) async {
    _pollGeneration++;
    _emit(state);
    _command = null;
    await _store.clear();
  }

  Future<CrossbreedSourcePreview> previewSources(String firstDogId, String secondDogId) =>
      _repo.previewSources(firstDogId, secondDogId);

  /// Starts one Generate action for the pair in display order. Returns false while another command is
  /// pending or when rewarded ads are unsupported/disabled (no free bypass).
  Future<bool> startGenerate({required List<String> displayDogIds, required String catalogVersion}) => _serial(() async {
        await _restoreOnce();
        if (_command != null) return false;
        if (!_ads.isSupported) {
          _emit(const CrossbreedFlowState(phase: CrossbreedPhase.failed, errorCode: 'ADS_UNSUPPORTED'));
          return false;
        }
        if (displayDogIds.length != 2 || displayDogIds[0] == displayDogIds[1]) {
          throw ArgumentError('exactly two different dogs are required');
        }
        await _save(CrossbreedPendingCommand(
          clientIntentId: newUuidV4(),
          displayDogIds: List.unmodifiable(displayDogIds),
          catalogVersion: catalogVersion,
          clientAdAttemptId: newUuidV4(),
          createdAt: _now().toUtc(),
        ));
        await _ensureIntent();
        return true;
      });

  /// Loads and shows the crossbreed rewarded ad for the pending intent. The SDK callbacks are bound to
  /// the attempt ID persisted before showing, so late or out-of-order callbacks cannot complete a
  /// different intent or pair.
  Future<void> watchAd() async {
    final ready = await _serial(() async {
      final c = _command;
      if (c == null || c.intentId == null || c.adEarned || c.redeemSubmitted || _adInFlight != null) return false;
      if (_state.phase != CrossbreedPhase.awaitingAd) return false;
      _emit(_from(CrossbreedPhase.showingAd));
      return true;
    });
    if (!ready) return;
    final loaded = await _ads.ensureLoaded();
    await _serial(() async {
      final c = _command;
      if (c == null || _state.phase != CrossbreedPhase.showingAd) return;
      if (!loaded) return _emit(_from(CrossbreedPhase.awaitingAd, errorCode: 'AD_UNAVAILABLE'));
      final attempt = c.clientAdAttemptId;
      if (c.adDismissed) await _save(c.copyWith(adDismissed: false));
      _adInFlight = attempt;
      final outcome = _ads.show(
        onEarned: () => unawaited(_onAdEarned(attempt)),
        onDismissed: () => unawaited(_onAdDismissed(attempt)),
        onFailedToShow: () => unawaited(_onAdFailed(attempt)),
      );
      if (outcome != RewardedShowOutcome.started) {
        if (_adInFlight == attempt) _adInFlight = null;
        _emit(_from(CrossbreedPhase.awaitingAd, errorCode: 'AD_UNAVAILABLE'));
      }
    });
  }

  Future<void> _onAdEarned(String attempt) => _serial(() async {
        final c = _command;
        if (c == null || c.clientAdAttemptId != attempt || c.adEarned) return;
        await _save(c.copyWith(adEarned: true));
        if (c.adDismissed) await _redeem();
      });

  Future<void> _onAdDismissed(String attempt) async {
    final submit = await _serial(() async {
      if (_adInFlight == attempt) _adInFlight = null;
      final c = _command;
      if (c == null || c.clientAdAttemptId != attempt || c.adDismissed) return false;
      await _save(c.copyWith(adDismissed: true));
      if (c.adEarned) {
        await _redeem();
        return false;
      }
      return true;
    });
    if (!submit) return;
    // Some SDK versions report the reward after dismissal; wait briefly before declaring it skipped.
    await _delay(rewardGrace);
    await _serial(() async {
      final c = _command;
      if (c == null || c.clientAdAttemptId != attempt || c.adEarned) return;
      // Not earned: the attempt never reached the server, so the next ad gets a fresh attempt id.
      await _save(c.copyWith(clientAdAttemptId: newUuidV4(), adDismissed: false));
      _emit(_from(CrossbreedPhase.awaitingAd, errorCode: 'AD_NOT_COMPLETED', needsNewAd: true));
    });
  }

  Future<void> _onAdFailed(String attempt) => _serial(() async {
        if (_adInFlight == attempt) _adInFlight = null;
        final c = _command;
        if (c == null || c.clientAdAttemptId != attempt || c.adEarned) return;
        _emit(_from(CrossbreedPhase.awaitingAd, errorCode: 'AD_UNAVAILABLE'));
      });

  /// Abandons a command before any reward was earned. Earned or submitted commands cannot be cancelled.
  Future<bool> cancel() => _serial(() async {
        final c = _command;
        if (c != null && (c.adEarned || c.redeemSubmitted || _adInFlight != null)) return false;
        await _finish(CrossbreedFlowState.idle);
        return true;
      });

  /// Clears a terminal success/failure from the UI.
  Future<void> acknowledge() => _serial(() async {
        if (_command == null) _emit(CrossbreedFlowState.idle);
      });

  /// Resynchronises the persisted command with the server (relaunch, resume, retry button).
  Future<void> recover() => _serial(() async {
        // An ad on screen (or loading) finishes through its own callbacks.
        if (_adInFlight != null || _state.phase == CrossbreedPhase.showingAd) return;
        _pollGeneration++;
        _restored = true;
        _command ??= await _store.load();
        final c = _command;
        if (c == null) return;
        if (c.intentId == null) return _ensureIntent();
        if (c.isFulfilled) {
          _emit(_from(CrossbreedPhase.generating));
          _startPolling(immediate: true);
          return;
        }
        try {
          await _applyIntent(await _repo.getIntent(c.intentId!), allowRedeem: true);
        } on CrossbreedApiException catch (e) {
          await _handleError(e);
        }
      });

  Future<void> _restoreOnce() async {
    if (_restored) return;
    _restored = true;
    _command ??= await _store.load();
  }

  Future<void> _ensureIntent() async {
    final c = _command!;
    _emit(_from(CrossbreedPhase.preparingIntent));
    try {
      final intent = await _repo.createIntent(
        clientIntentId: c.clientIntentId,
        dogIds: c.displayDogIds,
        catalogVersion: c.catalogVersion,
      );
      await _save(_command!.copyWith(intentId: intent.intentId));
      await _applyIntent(intent, allowRedeem: true);
    } on CrossbreedApiException catch (e) {
      await _handleError(e);
    }
  }

  Future<void> _applyIntent(CrossbreedIntent intent, {required bool allowRedeem}) async {
    final c = _command!;
    if (intent.fulfillment != null && intent.pairId != null && intent.generationId != null) {
      return _applyFulfillment(
          intent.fulfillment!, intent.pairId!, intent.generationId!, intent.status, intent.result, intent.pollAfterSeconds);
    }
    switch (intent.state) {
      case CrossbreedIntentState.expired:
        return _finish(_from(CrossbreedPhase.failed, errorCode: 'INTENT_EXPIRED', needsNewAd: true));
      case CrossbreedIntentState.rewardReported:
        // Our claim is recorded server-side: resubmit the same attempt without another ad.
        if (allowRedeem) return _redeem();
        return _emit(_from(CrossbreedPhase.failed, errorCode: 'SERVICE_UNAVAILABLE', retryable: true));
      case CrossbreedIntentState.created:
        if (allowRedeem && c.adEarned) {
          // Saved local completion. Without an ad in flight, dismissal can no longer arrive (process
          // loss or lost callback), so the earned reward resumes without another ad.
          if (!c.adDismissed) await _save(c.copyWith(adDismissed: true));
          return _redeem();
        }
        if (c.redeemSubmitted || c.adEarned) {
          await _save(c.copyWith(clientAdAttemptId: newUuidV4(), adEarned: false, adDismissed: false, redeemSubmitted: false));
          return _emit(_from(CrossbreedPhase.awaitingAd, errorCode: 'REWARDED_AD_REQUIRED', needsNewAd: true));
        }
        return _emit(_from(CrossbreedPhase.awaitingAd));
      case CrossbreedIntentState.fulfilled:
        return _finish(_from(CrossbreedPhase.failed, errorCode: CrossbreedApiException.invalidResponse));
    }
  }

  Future<void> _redeem() async {
    var c = _command!;
    if (c.intentId == null) return _ensureIntent();
    if (!c.redeemSubmitted) await _save(c = c.copyWith(redeemSubmitted: true));
    _emit(_from(CrossbreedPhase.redeeming));
    try {
      final r = await _repo.redeem(
        intentId: c.intentId!,
        clientAdAttemptId: c.clientAdAttemptId,
        confirmedCatalogVersion: c.catalogVersion,
      );
      await _applyFulfillment(r.fulfillment, r.pairId, r.generationId, r.status, r.result, r.pollAfterSeconds);
    } on CrossbreedApiException catch (e) {
      if (e.code == 'AD_ATTEMPT_ALREADY_USED' || e.code == 'AD_COMPLETION_CONFLICT') {
        try {
          return await _applyIntent(await _repo.getIntent(c.intentId!), allowRedeem: false);
        } on CrossbreedApiException catch (inner) {
          return _handleError(inner);
        }
      }
      await _handleError(e);
    }
  }

  Future<void> _applyFulfillment(FulfillmentKind kind, String pairId, String generationId, CrossbreedJobStatus? status,
      CrossbreedResult? result, int? pollAfterSeconds) async {
    try {
      await _save(_command!.fulfilled(kind, pairId, generationId));
    } on CrossbreedFormatException {
      return _finish(_from(CrossbreedPhase.failed, errorCode: CrossbreedApiException.invalidResponse));
    }
    if (status == CrossbreedJobStatus.succeeded && result != null) {
      return _finish(_from(CrossbreedPhase.succeeded, result: result));
    }
    if (status == CrossbreedJobStatus.failed) {
      return _finish(_from(CrossbreedPhase.failed, errorCode: 'GENERATION_FAILED', needsNewAd: true));
    }
    _emit(_from(CrossbreedPhase.generating, jobStatus: status));
    _startPolling(hintSeconds: pollAfterSeconds);
  }

  Future<void> _handleError(CrossbreedApiException e) async {
    final c = _command;
    switch (e.code) {
      case 'REWARDED_AD_REQUIRED':
        if (c != null) {
          await _save(c.copyWith(clientAdAttemptId: newUuidV4(), adEarned: false, adDismissed: false, redeemSubmitted: false));
        }
        return _emit(_from(CrossbreedPhase.awaitingAd, errorCode: e.code, needsNewAd: true));
      case 'SOURCE_VERSION_CHANGED':
      case 'PAIR_UNAVAILABLE':
      case 'INTENT_EXPIRED':
      case 'INSTALLATION_UNAUTHORIZED':
      case 'IDEMPOTENCY_CONFLICT':
      case 'NOT_FOUND':
        return _finish(_from(CrossbreedPhase.failed, errorCode: e.code, needsNewAd: true));
    }
    if (e.isTransient || e.canRetryWithoutAd) {
      return _emit(_from(CrossbreedPhase.failed,
          errorCode: e.code, retryable: true, retryAfterSeconds: e.retryAfterSeconds));
    }
    await _finish(_from(CrossbreedPhase.failed, errorCode: e.code, needsNewAd: true));
  }

  void _startPolling({int? hintSeconds, bool immediate = false}) {
    final generation = ++_pollGeneration;
    unawaited(_poll(generation, hintSeconds, immediate));
  }

  bool _pollAlive(int generation) => generation == _pollGeneration && _foreground && _command?.generationId != null;

  Future<void> _poll(int generation, int? hintSeconds, bool immediate) async {
    var backoff = minPollSeconds;
    var hint = hintSeconds;
    var first = true;
    while (_pollAlive(generation)) {
      if (!(first && immediate)) {
        final seconds = max(backoff, min(hint ?? 0, maxRetryAfterSeconds)).clamp(minPollSeconds, maxRetryAfterSeconds);
        await _delay(Duration(seconds: seconds));
        if (!_pollAlive(generation)) return;
      }
      first = false;
      final CrossbreedJob job;
      try {
        job = await _repo.getJob(_command!.generationId!);
      } on CrossbreedApiException catch (e) {
        if (!_pollAlive(generation)) return;
        if (!e.isTransient) return _serial(() => _handleError(e));
        backoff = min(backoff * 2, maxPollSeconds);
        hint = e.retryAfterSeconds;
        continue;
      }
      if (!_pollAlive(generation)) return;
      if (job.status == CrossbreedJobStatus.succeeded && job.result != null) {
        return _serial(() => _finish(_from(CrossbreedPhase.succeeded, result: job.result)));
      }
      if (job.status == CrossbreedJobStatus.failed) {
        debugPrint('[Crossbreed] generation failed: ${job.failureCode}');
        return _serial(() => _finish(_from(CrossbreedPhase.failed, errorCode: 'GENERATION_FAILED', needsNewAd: true)));
      }
      if (job.status != _state.jobStatus && _state.phase == CrossbreedPhase.generating) {
        _emit(_from(CrossbreedPhase.generating, jobStatus: job.status));
      }
      backoff = min(backoff * 2, maxPollSeconds);
      hint = job.pollAfterSeconds == null ? null : min(job.pollAfterSeconds!, maxPollSeconds);
    }
  }

  @visibleForTesting
  Future<void> dispose() async {
    _pollGeneration++;
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    await _controller.close();
  }
}
