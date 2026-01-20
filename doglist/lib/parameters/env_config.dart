import 'package:envied/envied.dart';

part 'env_config.g.dart';

/// Environment configuration for the Dog Liking feature.
/// Manages API endpoints and keys for dev and production environments.
@Envied(path: '.env')
abstract class EnvConfig {
  @EnviedField(varName: 'ENVIRONMENT')
  static const String environment = _EnvConfig.environment;
  
  @EnviedField(varName: 'API_BASE_URL_DEV')
  static const String apiBaseUrlDev = _EnvConfig.apiBaseUrlDev;
  
  @EnviedField(varName: 'API_BASE_URL_PROD')
  static const String apiBaseUrlProd = _EnvConfig.apiBaseUrlProd;
  
  @EnviedField(varName: 'API_HEADER_KEY_DEV')
  static const String apiHeaderKeyDev = _EnvConfig.apiHeaderKeyDev;
  
  @EnviedField(varName: 'API_HEADER_KEY_PROD')
  static const String apiHeaderKeyProd = _EnvConfig.apiHeaderKeyProd;
  
  @EnviedField(varName: 'API_BODY_KEY_DEV')
  static const String apiBodyKeyDev = _EnvConfig.apiBodyKeyDev;
  
  @EnviedField(varName: 'API_BODY_KEY_PROD')
  static const String apiBodyKeyProd = _EnvConfig.apiBodyKeyProd;
  
  @EnviedField(varName: 'LIKE_CACHE_DURATION_MINUTES', defaultValue: 5)
  static const int likeCacheDurationMinutes = _EnvConfig.likeCacheDurationMinutes;
  
  // Computed properties for environment-aware configuration
  
  /// Returns the appropriate API base URL based on current environment
  static String get apiBaseUrl => 
      environment == 'prod' ? apiBaseUrlProd : apiBaseUrlDev;
      
  /// Returns the appropriate API header key based on current environment
  static String get apiHeaderKey => 
      environment == 'prod' ? apiHeaderKeyProd : apiHeaderKeyDev;
      
  /// Returns the appropriate API body key based on current environment
  static String get apiBodyKey => 
      environment == 'prod' ? apiBodyKeyProd : apiBodyKeyDev;
}
