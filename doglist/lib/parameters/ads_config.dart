import 'package:envied/envied.dart';

part 'ads_config.g.dart';

/// Advertisement configuration using Envied for secure environment variable management
/// Configuration is split between .env.public (ADS_ENABLED, AD_MODE) and .env (credentials)
/// Obfuscation is enabled to protect sensitive production ad unit IDs
@Envied(path: '.env.public', obfuscate: false)
abstract class AdsConfigPublic {
  /// Advertisement Control (from .env.public)
  @EnviedField(varName: 'ADS_ENABLED')
  static final String adsEnabled = _AdsConfigPublic.adsEnabled;

  /// Ad Mode: 'test' or 'production' (from .env.public)
  @EnviedField(varName: 'AD_MODE')
  static final String adMode = _AdsConfigPublic.adMode;
}

@Envied(path: '.env', obfuscate: true)
abstract class AdsConfig {
  /// Test AdMob Configuration (Google's Official Test IDs)
  @EnviedField(varName: 'TEST_ADMOB_APP_ID_ANDROID')
  static final String testAdmobAppIdAndroid = _AdsConfig.testAdmobAppIdAndroid;

  @EnviedField(varName: 'TEST_ADMOB_APP_ID_IOS')
  static final String testAdmobAppIdIos = _AdsConfig.testAdmobAppIdIos;

  @EnviedField(varName: 'TEST_ADMOB_ANDROID_BANNER_ID')
  static final String testAdmobAndroidBannerId = _AdsConfig.testAdmobAndroidBannerId;

  @EnviedField(varName: 'TEST_ADMOB_IOS_BANNER_ID')
  static final String testAdmobIosBannerId = _AdsConfig.testAdmobIosBannerId;

  /// AdMob Production Configuration
  @EnviedField(varName: 'PRODUCTION_ADMOB_APP_ID_ANDROID', obfuscate: true)
  static final String productionAdmobAppIdAndroid = _AdsConfig.productionAdmobAppIdAndroid;

  @EnviedField(varName: 'PRODUCTION_ADMOB_APP_ID_IOS', obfuscate: true)
  static final String productionAdmobAppIdIos = _AdsConfig.productionAdmobAppIdIos;

  @EnviedField(varName: 'PRODUCTION_ADMOB_ANDROID_BANNER_ID', obfuscate: true)
  static final String productionAdmobAndroidBannerId = _AdsConfig.productionAdmobAndroidBannerId;

  @EnviedField(varName: 'PRODUCTION_ADMOB_IOS_BANNER_ID', obfuscate: true)
  static final String productionAdmobIosBannerId = _AdsConfig.productionAdmobIosBannerId;

  /// Test IronSource Configuration
  @EnviedField(varName: 'TEST_IRONSOURCE_APP_KEY_ANDROID')
  static final String testIronSourceAppKeyAndroid = _AdsConfig.testIronSourceAppKeyAndroid;

  @EnviedField(varName: 'TEST_IRONSOURCE_APP_KEY_IOS')
  static final String testIronSourceAppKeyIos = _AdsConfig.testIronSourceAppKeyIos;

  @EnviedField(varName: 'TEST_IRONSOURCE_ANDROID_BANNER_ID')
  static final String testIronSourceAndroidBannerId = _AdsConfig.testIronSourceAndroidBannerId;

  @EnviedField(varName: 'TEST_IRONSOURCE_IOS_BANNER_ID')
  static final String testIronSourceIosBannerId = _AdsConfig.testIronSourceIosBannerId;

  /// IronSource Production Configuration
  @EnviedField(varName: 'PRODUCTION_IRONSOURCE_APP_KEY_ANDROID', obfuscate: true)
  static final String productionIronSourceAppKeyAndroid = _AdsConfig.productionIronSourceAppKeyAndroid;

  @EnviedField(varName: 'PRODUCTION_IRONSOURCE_APP_KEY_IOS', obfuscate: true)
  static final String productionIronSourceAppKeyIos = _AdsConfig.productionIronSourceAppKeyIos;

  @EnviedField(varName: 'PRODUCTION_IRONSOURCE_ANDROID_BANNER_ID', obfuscate: true)
  static final String productionIronSourceAndroidBannerId = _AdsConfig.productionIronSourceAndroidBannerId;

  @EnviedField(varName: 'PRODUCTION_IRONSOURCE_IOS_BANNER_ID', obfuscate: true)
  static final String productionIronSourceIosBannerId = _AdsConfig.productionIronSourceIosBannerId;

  /// Test Device IDs
  @EnviedField(varName: 'TEST_DEVICE_ANDROID_1')
  static final String testDeviceAndroid1 = _AdsConfig.testDeviceAndroid1;

  @EnviedField(varName: 'TEST_DEVICE_ANDROID_2')
  static final String testDeviceAndroid2 = _AdsConfig.testDeviceAndroid2;

  @EnviedField(varName: 'TEST_DEVICE_ANDROID_3')
  static final String testDeviceAndroid3 = _AdsConfig.testDeviceAndroid3;

  @EnviedField(varName: 'TEST_DEVICE_IOS_1')
  static final String testDeviceIos1 = _AdsConfig.testDeviceIos1;

  @EnviedField(varName: 'IRONSOURCE_PLACEMENT_NAME')
  static final String ironSourcePlacementName = _AdsConfig.ironSourcePlacementName;

  /// General Configuration
  @EnviedField(varName: 'AD_REFRESH_RATE_SECONDS')
  static final String adRefreshRateSeconds = _AdsConfig.adRefreshRateSeconds;

  @EnviedField(varName: 'AD_REQUEST_TIMEOUT_SECONDS')
  static final String adRequestTimeoutSeconds = _AdsConfig.adRequestTimeoutSeconds;

  @EnviedField(varName: 'ENABLE_DEBUG_LOGGING')
  static final String enableDebugLogging = _AdsConfig.enableDebugLogging;

  /// Helper methods for type-safe access
  static bool get areAdsEnabled => AdsConfigPublic.adsEnabled.toLowerCase() == 'true';
  static bool get isTestMode => AdsConfigPublic.adMode.toLowerCase() == 'test';
  static bool get isProductionMode => AdsConfigPublic.adMode.toLowerCase() == 'production';
  static int get adRefreshRate => int.tryParse(adRefreshRateSeconds) ?? 60;
  static int get adRequestTimeout => int.tryParse(adRequestTimeoutSeconds) ?? 30;
  static bool get isDebugLoggingEnabled => enableDebugLogging.toLowerCase() == 'true';

  /// Get list of AdMob test device IDs
  static List<String> get admobTestDeviceIds => [
    AdsConfig.testDeviceAndroid1,
    AdsConfig.testDeviceAndroid2,
    AdsConfig.testDeviceAndroid3,
    AdsConfig.testDeviceIos1,
  ].where((id) => id.isNotEmpty && id != 'YOUR_TEST_DEVICE_ID').toList();

  /// Smart getters that switch between test and production based on AD_MODE
  /// These should be used throughout the app instead of direct field access

  // AdMob App IDs
  static String get currentAdmobAppIdAndroid => 
    isTestMode ? AdsConfig.testAdmobAppIdAndroid : AdsConfig.productionAdmobAppIdAndroid;

  static String get currentAdmobAppIdIos => 
    isTestMode ? AdsConfig.testAdmobAppIdIos : AdsConfig.productionAdmobAppIdIos;

  // AdMob Banner Ad Unit IDs
  static String get currentAdmobAndroidBannerId => 
    isTestMode ? AdsConfig.testAdmobAndroidBannerId : AdsConfig.productionAdmobAndroidBannerId;

  static String get currentAdmobIosBannerId => 
    isTestMode ? AdsConfig.testAdmobIosBannerId : AdsConfig.productionAdmobIosBannerId;

  // IronSource App Keys
  static String get currentIronSourceAppKeyAndroid => 
    isTestMode ? AdsConfig.testIronSourceAppKeyAndroid : AdsConfig.productionIronSourceAppKeyAndroid;

  static String get currentIronSourceAppKeyIos => 
    isTestMode ? AdsConfig.testIronSourceAppKeyIos : AdsConfig.productionIronSourceAppKeyIos;

  // IronSource Banner IDs
  static String get currentIronSourceAndroidBannerId => 
    isTestMode ? AdsConfig.testIronSourceAndroidBannerId : AdsConfig.productionIronSourceAndroidBannerId;

  static String get currentIronSourceIosBannerId => 
    isTestMode ? AdsConfig.testIronSourceIosBannerId : AdsConfig.productionIronSourceIosBannerId;
}