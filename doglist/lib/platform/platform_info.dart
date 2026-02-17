// This file provides platform information in a web-safe way
export 'platform_info_stub.dart'
    if (dart.library.io) 'platform_info_mobile.dart'
    if (dart.library.html) 'platform_info_web.dart';
