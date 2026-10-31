import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../parameters/ads_config.dart';

typedef RewardedAdCallback = void Function(bool success);

/// Starts one SDK load; the SDK reports the outcome through [callback].
typedef RewardedAdLoader = Future<void> Function(String adUnitId, RewardedAdLoadCallback callback);

Future<void> _sdkLoad(String adUnitId, RewardedAdLoadCallback callback) =>
    RewardedAd.load(adUnitId: adUnitId, request: const AdRequest(), rewardedAdLoadCallback: callback);

/// Who owns a rewarded ad. Each purpose has its own loaded ad, so a like can never consume a
/// crossbreed ad (or the reverse), and completion is reported only to the presenter that showed it.
enum RewardedAdPurpose { like, crossbreed }

enum RewardedShowOutcome {
  /// The full-screen ad was handed to the SDK; earned/dismissed/failed callbacks follow.
  started,
  notLoaded,

  /// Another rewarded ad is currently on screen.
  busy,
}

class _Slot {
  RewardedAd? ad;
  Completer<bool>? loading;
}

/// Shared manager for rewarded ads (dog likes and AI crossbreeds).
class RewardedAdManager {
  static final RewardedAdManager _instance = RewardedAdManager._internal();
  factory RewardedAdManager() => _instance;
  RewardedAdManager._internal();

  final Map<RewardedAdPurpose, _Slot> _slots = {for (final p in RewardedAdPurpose.values) p: _Slot()};
  RewardedAdPurpose? _presenting;

  @visibleForTesting
  RewardedAdLoader loader = _sdkLoad;

  @visibleForTesting
  bool? supportedOverride;

  /// Drops loaded ads and the presentation lease, and restores the SDK loader.
  @visibleForTesting
  void resetForTesting() {
    dispose();
    for (final slot in _slots.values) {
      slot.loading = null;
    }
    _presenting = null;
    loader = _sdkLoad;
    supportedOverride = null;
  }

  bool get isSupported =>
      supportedOverride ?? (!kIsWeb && AdsConfig.areAdsEnabled && (Platform.isAndroid || Platform.isIOS));

  /// Purpose currently on screen, if any.
  RewardedAdPurpose? get presenting => _presenting;

  String _adUnitId(RewardedAdPurpose purpose) {
    final isTestMode = AdsConfigPublic.adMode == 'test';
    String? dedicated;
    String shared;
    if (Platform.isAndroid) {
      shared = isTestMode ? AdsConfig.testAdmobAndroidRewardedId : AdsConfig.productionAdmobAndroidRewardedId;
      if (purpose == RewardedAdPurpose.crossbreed) {
        dedicated = isTestMode
            ? AdsConfig.testAdmobAndroidCrossbreedRewardedId
            : AdsConfig.productionAdmobAndroidCrossbreedRewardedId;
      }
    } else if (Platform.isIOS) {
      shared = isTestMode ? AdsConfig.testAdmobIosRewardedId : AdsConfig.productionAdmobIosRewardedId;
      if (purpose == RewardedAdPurpose.crossbreed) {
        dedicated = isTestMode
            ? AdsConfig.testAdmobIosCrossbreedRewardedId
            : AdsConfig.productionAdmobIosCrossbreedRewardedId;
      }
    } else {
      return '';
    }
    return dedicated == null || dedicated.trim().isEmpty ? shared : dedicated.trim();
  }

  /// Loads an ad for [purpose] and completes with `true` only after the SDK's `onAdLoaded`
  /// (not merely after `RewardedAd.load` returns). Concurrent callers share one request.
  Future<bool> load({RewardedAdPurpose purpose = RewardedAdPurpose.like}) {
    final slot = _slots[purpose]!;
    if (slot.ad != null) return Future.value(true);
    if (slot.loading != null) return slot.loading!.future;
    if (!isSupported) return Future.value(false);

    final completer = slot.loading = Completer<bool>();
    void finish(RewardedAd? ad) {
      slot.ad = ad;
      slot.loading = null;
      if (!completer.isCompleted) completer.complete(ad != null);
    }

    debugPrint('[RewardedAdManager] Loading ${purpose.name} rewarded ad...');
    loader(
      _adUnitId(purpose),
      RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[RewardedAdManager] ${purpose.name} ad loaded');
          finish(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('[RewardedAdManager] ${purpose.name} ad failed to load: ${error.message}');
          finish(null);
        },
      ),
    ).catchError((Object e) {
      debugPrint('[RewardedAdManager] Exception while loading ${purpose.name} ad: $e');
      finish(null);
    });
    return completer.future;
  }

  /// Shows the loaded ad for [purpose] once. The ad object is taken out of its slot before showing,
  /// disposed after dismissal/failure, and only one rewarded ad can be on screen at a time.
  RewardedShowOutcome present(
    RewardedAdPurpose purpose, {
    required void Function() onEarned,
    required void Function() onDismissed,
    required void Function() onFailedToShow,
  }) {
    if (_presenting != null) return RewardedShowOutcome.busy;
    final slot = _slots[purpose]!;
    final ad = slot.ad;
    if (ad == null) return RewardedShowOutcome.notLoaded;
    slot.ad = null;
    _presenting = purpose;

    void release(Ad shown) {
      shown.dispose();
      if (_presenting == purpose) _presenting = null;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shown) {
        debugPrint('[RewardedAdManager] ${purpose.name} ad dismissed');
        release(shown);
        onDismissed();
        if (purpose == RewardedAdPurpose.like) load();
      },
      onAdFailedToShowFullScreenContent: (shown, error) {
        debugPrint('[RewardedAdManager] ${purpose.name} ad failed to show: ${error.message}');
        release(shown);
        onFailedToShow();
        if (purpose == RewardedAdPurpose.like) load();
      },
    );
    debugPrint('[RewardedAdManager] Showing ${purpose.name} rewarded ad...');
    ad
        .show(
          onUserEarnedReward: (_, reward) {
            debugPrint('[RewardedAdManager] ${purpose.name} reward earned');
            onEarned();
          },
        )
        .catchError((Object e) {
          debugPrint('[RewardedAdManager] Exception while showing ${purpose.name} ad: $e');
          release(ad);
          onFailedToShow();
        });
    return RewardedShowOutcome.started;
  }

  bool isReady(RewardedAdPurpose purpose) => _slots[purpose]!.ad != null;

  // ---- Backward-compatible like adapter -------------------------------------------------------

  /// Load the like rewarded ad. Completes after the SDK reports loaded or failed.
  Future<void> loadAd() => load(purpose: RewardedAdPurpose.like);

  /// Show the like rewarded ad and invoke [callback] after dismissal with the earned status.
  Future<void> showAd(RewardedAdCallback callback) async {
    var earned = false;
    final outcome = present(
      RewardedAdPurpose.like,
      onEarned: () => earned = true,
      onDismissed: () => callback(earned),
      onFailedToShow: () => callback(false),
    );
    if (outcome != RewardedShowOutcome.started) {
      debugPrint('[RewardedAdManager] No like ad available to show ($outcome)');
      callback(false);
    }
  }

  /// Check if the like ad is ready to show.
  bool isAdReady() => isReady(RewardedAdPurpose.like);

  /// Dispose of all loaded (not presented) ads.
  void dispose() {
    debugPrint('[RewardedAdManager] Disposing ads');
    for (final slot in _slots.values) {
      slot.ad?.dispose();
      slot.ad = null;
    }
  }
}
