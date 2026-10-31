import 'dart:math';

final Random _secureRandom = Random.secure();

/// Random RFC 4122 version-4 UUID (lowercase) for idempotency and ad-attempt keys.
String newUuidV4([Random? random]) {
  final r = random ?? _secureRandom;
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
