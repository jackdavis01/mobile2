import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../parameters/ads_config.dart';

typedef RewardedAdCallback = void Function(bool success);

/// Manager for rewarded ads used for unlimited dog likes
class RewardedAdManager {
  static final RewardedAdManager _instance = RewardedAdManager._internal();
  factory RewardedAdManager() => _instance;
  RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  /// Get the appropriate rewarded ad unit ID based on platform and mode
  String get _adUnitId {
    final isTestMode = AdsConfigPublic.adMode == 'test';
    
    if (Platform.isAndroid) {
      return isTestMode 
          ? AdsConfig.testAdmobAndroidRewardedId
          : AdsConfig.productionAdmobAndroidRewardedId;
    } else if (Platform.isIOS) {
      return isTestMode
          ? AdsConfig.testAdmobIosRewardedId
          : AdsConfig.productionAdmobIosRewardedId;
    } else {
      return '';
    }
  }

  /// Load a rewarded ad
  Future<void> loadAd() async {
    if (_isAdLoaded || _isAdLoading) {
      debugPrint('[RewardedAdManager] Ad already loaded or loading, skipping');
      return;
    }

    _isAdLoading = true;
    debugPrint('[RewardedAdManager] Loading rewarded ad...');

    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[RewardedAdManager] Ad loaded successfully');
            _rewardedAd = ad;
            _isAdLoaded = true;
            _isAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[RewardedAdManager] Ad failed to load: ${error.message}');
            _isAdLoaded = false;
            _isAdLoading = false;
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('[RewardedAdManager] Exception while loading ad: $e');
      _isAdLoaded = false;
      _isAdLoading = false;
      _rewardedAd = null;
    }
  }

  /// Show the rewarded ad and invoke callback with reward status
  Future<void> showAd(RewardedAdCallback callback) async {
    if (_rewardedAd == null || !_isAdLoaded) {
      debugPrint('[RewardedAdManager] No ad available to show');
      callback(false);
      return;
    }

    debugPrint('[RewardedAdManager] Showing rewarded ad...');

    bool rewardGranted = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[RewardedAdManager] Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[RewardedAdManager] Ad dismissed, reward granted: $rewardGranted');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        
        // Call the callback after ad is dismissed
        callback(rewardGranted);
        
        // Preload next ad
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[RewardedAdManager] Ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        callback(false);
        
        // Preload next ad
        loadAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[RewardedAdManager] User earned reward: ${reward.amount} ${reward.type}');
        rewardGranted = true;
      },
    );
  }

  /// Check if an ad is ready to show
  bool isAdReady() => _isAdLoaded && _rewardedAd != null;

  /// Dispose of the current ad
  void dispose() {
    debugPrint('[RewardedAdManager] Disposing ad');
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    _isAdLoading = false;
  }
}
