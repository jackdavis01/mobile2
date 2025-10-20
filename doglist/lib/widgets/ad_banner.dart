import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../parameters/ads_config.dart';

/// AdBanner widget that implements AdMob primary and IronSource fallback banner system
/// This follows the modern best practices for banner ad implementation in Flutter
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner>
    with LevelPlayInitListener, LevelPlayBannerAdViewListener {
  
  // AdMob banner ad instance
  BannerAd? _admobBannerAd;
  bool _isAdmobAdLoaded = false;
  
  // IronSource banner ad instance
  LevelPlayBannerAdView? _ironSourceBannerAdView;
  bool _isIronSourceAdLoaded = false;
  bool _isIronSourceInitialized = false;
  
  // Ad state management
  bool _isLoadingAd = false;
  bool _shouldShowAd = false;
  late Orientation _currentOrientation;

  @override
  void initState() {
    super.initState();
    _currentOrientation = Orientation.portrait; // Initialize with default
    
    // Don't initialize ads if they're disabled in configuration
    if (!AdsConfig.areAdsEnabled) {
      return;
    }
    
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeAds();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    
    final orientation = MediaQuery.of(context).orientation;
    if (_currentOrientation != orientation) {
      _currentOrientation = orientation;
      // Reload ad on orientation change for better user experience
      if (_shouldShowAd && !_isLoadingAd && mounted) {
        _loadAdMobBanner();
      }
    }
  }

  /// Initialize advertisement systems
  Future<void> _initializeAds() async {
    if (_isLoadingAd) return;
    
    setState(() {
      _isLoadingAd = true;
    });

    try {
      // Initialize AdMob first (primary ad network)
      await _initializeAdMob();
      
      // Initialize IronSource as fallback
      await _initializeIronSource();
      
      // Load the first ad
      await _loadAdMobBanner();
    } catch (e) {
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: Error initializing ads: $e');
      }
    } finally {
      setState(() {
        _isLoadingAd = false;
      });
    }
  }

  /// Initialize AdMob SDK
  Future<void> _initializeAdMob() async {
    try {
      // Configure test devices if any are available
      final testDeviceIds = AdsConfig.admobTestDeviceIds;
      if (testDeviceIds.isNotEmpty) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDeviceIds),
        );
      }
      
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: AdMob initialized successfully');
      }
    } catch (e) {
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: AdMob initialization failed: $e');
      }
    }
  }

  /// Initialize IronSource SDK
  Future<void> _initializeIronSource() async {
    try {
      final appKey = Platform.isAndroid 
          ? AdsConfig.currentIronSourceAppKeyAndroid
          : AdsConfig.currentIronSourceAppKeyIos;

      // Initialize LevelPlay with current API
      final initRequest = LevelPlayInitRequest.builder(appKey)
          .build();
      
      await LevelPlay.init(initRequest: initRequest, initListener: this);
      
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: IronSource initialization started');
      }
    } catch (e) {
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: IronSource initialization failed: $e');
      }
    }
  }

  /// Load AdMob banner ad (primary ad network)
  Future<void> _loadAdMobBanner() async {
    if (_isAdmobAdLoaded || !mounted) return;

    try {
      // Get adaptive banner size for current orientation
      final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate(),
      );

      if (size == null) {
        if (AdsConfig.isDebugLoggingEnabled) {
          debugPrint('AdBanner: Unable to get adaptive banner size');
        }
        _loadIronSourceBanner(); // Fallback to IronSource
        return;
      }

      // Create and load AdMob banner
      _admobBannerAd = BannerAd(
        adUnitId: Platform.isAndroid 
            ? AdsConfig.currentAdmobAndroidBannerId
            : AdsConfig.currentAdmobIosBannerId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (AdsConfig.isDebugLoggingEnabled) {
              debugPrint('AdBanner: AdMob banner loaded successfully');
            }
            setState(() {
              _isAdmobAdLoaded = true;
              _shouldShowAd = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            if (AdsConfig.isDebugLoggingEnabled) {
              debugPrint('AdBanner: AdMob banner failed to load: $error');
            }
            ad.dispose();
            setState(() {
              _admobBannerAd = null;
              _isAdmobAdLoaded = false;
            });
            // Fallback to IronSource
            _loadIronSourceBanner();
          },
          onAdOpened: (Ad ad) {
            if (AdsConfig.isDebugLoggingEnabled) {
              debugPrint('AdBanner: AdMob banner opened');
            }
          },
          onAdClosed: (Ad ad) {
            if (AdsConfig.isDebugLoggingEnabled) {
              debugPrint('AdBanner: AdMob banner closed');
            }
          },
          onAdClicked: (Ad ad) {
            if (AdsConfig.isDebugLoggingEnabled) {
              debugPrint('AdBanner: AdMob banner clicked');
            }
          },
        ),
      );

      await _admobBannerAd?.load();
    } catch (e) {
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: Error loading AdMob banner: $e');
      }
      _loadIronSourceBanner(); // Fallback to IronSource
    }
  }

  /// Load IronSource banner ad (fallback ad network)
  void _loadIronSourceBanner() {
    if (!_isIronSourceInitialized || _isIronSourceAdLoaded) return;

    try {
      final adUnitId = Platform.isAndroid 
          ? AdsConfig.currentIronSourceAndroidBannerId
          : AdsConfig.currentIronSourceIosBannerId;

      _ironSourceBannerAdView = LevelPlayBannerAdView(
        adUnitId: adUnitId,
        adSize: LevelPlayAdSize.BANNER,
        listener: this,
        placementName: AdsConfig.ironSourcePlacementName,
        onPlatformViewCreated: () {
          _ironSourceBannerAdView?.loadAd();
        },
      );

      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: IronSource banner created and loading');
      }
    } catch (e) {
      if (AdsConfig.isDebugLoggingEnabled) {
        debugPrint('AdBanner: Error creating IronSource banner: $e');
      }
    }
  }

  /// Build the appropriate ad widget
  Widget _buildAdWidget() {
    // Show AdMob banner if loaded
    if (_isAdmobAdLoaded && _admobBannerAd != null) {
      return SizedBox(
        width: _admobBannerAd!.size.width.toDouble(),
        height: _admobBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _admobBannerAd!),
      );
    }
    
    // Show IronSource banner if loaded
    if (_isIronSourceAdLoaded && _ironSourceBannerAdView != null) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: _ironSourceBannerAdView!,
      );
    }

    // Show loading indicator or empty space
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Check if ads are enabled in configuration
    if (!AdsConfig.areAdsEnabled) {
      return const SizedBox.shrink();
    }
    
    // Only show ads on supported platforms
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return const SizedBox.shrink();
    }

    if (!_shouldShowAd) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: _buildAdWidget(),
      ),
    );
  }

  @override
  void dispose() {
    _admobBannerAd?.dispose();
    _ironSourceBannerAdView?.destroy();
    super.dispose();
  }

  // IronSource LevelPlay Init Listener
  @override
  void onInitFailed(LevelPlayInitError error) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource init failed: ${error.errorMessage}');
    }
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource init success');
    }
    setState(() {
      _isIronSourceInitialized = true;
    });
  }

  // IronSource Banner Ad View Listener
  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner loaded');
    }
    setState(() {
      _isIronSourceAdLoaded = true;
      _shouldShowAd = true;
    });
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner load failed: ${error.errorMessage}');
    }
    setState(() {
      _isIronSourceAdLoaded = false;
    });
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner displayed');
    }
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner display failed: ${error.errorMessage}');
    }
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner clicked');
    }
  }

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner expanded');
    }
  }

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner collapsed');
    }
  }

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {
    if (AdsConfig.isDebugLoggingEnabled) {
      debugPrint('AdBanner: IronSource banner left application');
    }
  }
}