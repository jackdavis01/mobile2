import 'rewarded_ad_manager.dart';

/// Rewarded-ad port used by the crossbreed coordinator (fakeable in tests).
abstract class CrossbreedAdPresenter {
  /// False on web, with ads disabled, or on unsupported platforms: Generate is then disabled.
  bool get isSupported;

  /// Completes true once an ad is actually loaded (SDK `onAdLoaded`), false on no fill/failure/timeout.
  Future<bool> ensureLoaded();

  RewardedShowOutcome show({
    required void Function() onEarned,
    required void Function() onDismissed,
    required void Function() onFailedToShow,
  });
}

class SdkCrossbreedAdPresenter implements CrossbreedAdPresenter {
  SdkCrossbreedAdPresenter({RewardedAdManager? manager, this.loadTimeout = const Duration(seconds: 30)})
      : _manager = manager ?? RewardedAdManager();

  final RewardedAdManager _manager;
  final Duration loadTimeout;

  @override
  bool get isSupported => _manager.isSupported;

  @override
  Future<bool> ensureLoaded() =>
      _manager.load(purpose: RewardedAdPurpose.crossbreed).timeout(loadTimeout, onTimeout: () => false);

  @override
  RewardedShowOutcome show({
    required void Function() onEarned,
    required void Function() onDismissed,
    required void Function() onFailedToShow,
  }) =>
      _manager.present(RewardedAdPurpose.crossbreed,
          onEarned: onEarned, onDismissed: onDismissed, onFailedToShow: onFailedToShow);
}
