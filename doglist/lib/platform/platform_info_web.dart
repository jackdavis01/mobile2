import 'package:flutter/foundation.dart';

class PlatformInfo {
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isWeb => kIsWeb;
}
